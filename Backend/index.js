require('dotenv').config({ path: require('path').join(__dirname, '.env') });

const express = require('express');
const authRoutes = require('./routes/authRoutes');
const profileRoutes = require('./routes/profileRoutes');
const contentRoutes = require('./routes/contentRoutes');
const scanRoutes = require('./routes/scanRoutes');
const pool = require('./config/db');
const {
    attachRequestID,
    applySecurityHeaders,
    applyNoStoreForPrivateResponses,
    validateClientHeaders
} = require('./middleware/headerMiddleware');

const app = express();
const PORT = 3000;
const IP_ADDRESS = '192.168.1.135';

app.use(attachRequestID);
app.use(applySecurityHeaders);
app.use(validateClientHeaders);
app.use(express.json());
app.use(applyNoStoreForPrivateResponses);

app.use('/auth', authRoutes);
app.use('/profiles', profileRoutes);
app.use('/content', contentRoutes);
app.use('/scan', scanRoutes);

app.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok' });
});

const server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 The server was launched with a modular structure.!`);
    console.log(`🔗 Local: http://localhost:${PORT}/auth/register`);
    console.log(`🌐 From Network: http://${IP_ADDRESS}:${PORT}/auth/register`);
});

server.on('error', (error) => {
    if (error.code === 'EADDRINUSE') {
        console.error(`Port ${PORT} is already in use.`);
    } else {
        console.error('Server failed to start:', error);
    }

    process.exit(1);
});

const shutdown = () => {
    server.close(async () => {
        await pool.end();
        process.exit(0);
    });
};

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
