const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const pool = require('../config/db');

const migrationsDir = path.join(__dirname, '..', 'migrations');
const command = process.argv[2] || 'up';

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

const getMigrationFiles = () => {
    if (!fs.existsSync(migrationsDir)) {
        return [];
    }

    return fs
        .readdirSync(migrationsDir)
        .filter((fileName) => fileName.endsWith('.sql'))
        .sort()
        .map((fileName) => {
            const filePath = path.join(migrationsDir, fileName);
            const sql = fs.readFileSync(filePath, 'utf8');
            const [version] = fileName.split('_');

            return {
                version,
                name: fileName,
                sql,
                checksum: crypto.createHash('sha256').update(sql).digest('hex')
            };
        });
};

const getAppliedMigrations = async (client) => {
    const result = await client.query(
        'SELECT version, name, checksum, applied_at FROM schema_migrations ORDER BY version'
    );

    return new Map(result.rows.map((row) => [row.version, row]));
};

const printStatus = async (client, migrations, appliedMigrations) => {
    migrations.forEach((migration) => {
        const applied = appliedMigrations.get(migration.version);
        const status = applied ? 'applied' : 'pending';
        console.log(`${migration.version} ${status} ${migration.name}`);
    });
};

const migrateUp = async (client, migrations, appliedMigrations) => {
    let appliedCount = 0;

    for (const migration of migrations) {
        const applied = appliedMigrations.get(migration.version);

        if (applied) {
            if (applied.checksum !== migration.checksum) {
                throw new Error(
                    `Migration ${migration.name} was already applied with a different checksum.`
                );
            }
            continue;
        }

        console.log(`Applying ${migration.name}`);
        await client.query('BEGIN');
        try {
            await client.query(migration.sql);
            await client.query(
                'INSERT INTO schema_migrations (version, name, checksum) VALUES ($1, $2, $3)',
                [migration.version, migration.name, migration.checksum]
            );
            await client.query('COMMIT');
            appliedCount += 1;
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        }
    }

    console.log(
        appliedCount === 0
            ? 'No pending migrations.'
            : `Applied ${appliedCount} migration${appliedCount === 1 ? '' : 's'}.`
    );
};

const main = async () => {
    if (!['up', 'status'].includes(command)) {
        throw new Error('Unknown command. Use "up" or "status".');
    }

    const client = await pool.connect();
    try {
        await ensureMigrationsTable(client);
        const migrations = getMigrationFiles();
        const appliedMigrations = await getAppliedMigrations(client);

        if (command === 'status') {
            await printStatus(client, migrations, appliedMigrations);
            return;
        }

        await migrateUp(client, migrations, appliedMigrations);
    } finally {
        client.release();
        await pool.end();
    }
};

main().catch((error) => {
    console.error(error.message);
    process.exit(1);
});
