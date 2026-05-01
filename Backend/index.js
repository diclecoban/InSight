const express = require('express');
const authRoutes = require('./routes/authRoutes');

const app = express();
const PORT = 3000;
const IP_ADDRESS = '192.168.1.135';
app.use(express.json());
app.use('/auth', authRoutes);

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 The server was launched with a modular structure.!`);
    console.log(`🔗 Local: http://localhost:${PORT}/auth/register`);
    console.log(`🌐 From Network: http://${IP_ADDRESS}:${PORT}/auth/register`);
});
