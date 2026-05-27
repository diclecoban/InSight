const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { Pool } = require('pg');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const migrationsDir = path.join(__dirname, '..', 'migrations');

const quoteIdentifier = (value) => `"${String(value).replaceAll('"', '""')}"`;

const baseConfig = () => {
    if (process.env.DATABASE_URL) {
        const url = new URL(process.env.DATABASE_URL);
        const targetDatabase = url.pathname.replace(/^\//, '') || 'postgres';
        url.pathname = '/postgres';

        return {
            admin: { connectionString: url.toString() },
            targetDatabase
        };
    }

    return {
        admin: {
            user: process.env.DB_USER,
            host: process.env.DB_HOST,
            database: 'postgres',
            password: process.env.DB_PASSWORD,
            port: Number(process.env.DB_PORT || 5432)
        },
        targetDatabase: process.env.DB_NAME || 'postgres'
    };
};

const targetConfig = (database) => {
    if (process.env.DATABASE_URL) {
        const url = new URL(process.env.DATABASE_URL);
        url.pathname = `/${database}`;
        return { connectionString: url.toString() };
    }

    return {
        user: process.env.DB_USER,
        host: process.env.DB_HOST,
        database,
        password: process.env.DB_PASSWORD,
        port: Number(process.env.DB_PORT || 5432)
    };
};

const getMigrationFiles = () => fs
    .readdirSync(migrationsDir)
    .filter((fileName) => fileName.endsWith('.sql'))
    .sort()
    .map((fileName) => {
        const sql = fs.readFileSync(path.join(migrationsDir, fileName), 'utf8');
        const [version] = fileName.split('_');

        return {
            version,
            name: fileName,
            sql,
            checksum: crypto.createHash('sha256').update(sql).digest('hex')
        };
    });

const ensureMigrationsTable = async (client) => {
    await client.query(`
        CREATE TABLE IF NOT EXISTS schema_migrations (
            version text PRIMARY KEY,
            name text NOT NULL,
            checksum text NOT NULL,
            applied_at timestamptz NOT NULL DEFAULT NOW()
        )
    `);
};

const verifyFreshMigrations = async () => {
    const config = baseConfig();
    const databaseName = `insight_migration_test_${Date.now()}`;
    const adminPool = new Pool(config.admin);
    const adminClient = await adminPool.connect();

    try {
        await adminClient.query(`CREATE DATABASE ${quoteIdentifier(databaseName)}`);
    } finally {
        adminClient.release();
        await adminPool.end();
    }

    const targetPool = new Pool(targetConfig(databaseName));
    const targetClient = await targetPool.connect();

    try {
        await ensureMigrationsTable(targetClient);

        for (const migration of getMigrationFiles()) {
            console.log(`Applying ${migration.name}`);
            await targetClient.query('BEGIN');
            try {
                await targetClient.query(migration.sql);
                await targetClient.query(
                    'INSERT INTO schema_migrations (version, name, checksum) VALUES ($1, $2, $3)',
                    [migration.version, migration.name, migration.checksum]
                );
                await targetClient.query('COMMIT');
            } catch (error) {
                await targetClient.query('ROLLBACK');
                throw error;
            }
        }

        const result = await targetClient.query('SELECT COUNT(*)::int AS count FROM schema_migrations');
        console.log(`Fresh migration verification passed (${result.rows[0].count} migrations).`);
    } finally {
        targetClient.release();
        await targetPool.end();

        const cleanupPool = new Pool(config.admin);
        const cleanupClient = await cleanupPool.connect();
        try {
            await cleanupClient.query(
                'SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = $1',
                [databaseName]
            );
            await cleanupClient.query(`DROP DATABASE IF EXISTS ${quoteIdentifier(databaseName)}`);
        } finally {
            cleanupClient.release();
            await cleanupPool.end();
        }
    }
};

verifyFreshMigrations().catch((error) => {
    console.error(error.message);
    process.exit(1);
});
