const nodemailer = require('nodemailer');

const requiredKeys = [
    'SMTP_HOST',
    'SMTP_PORT',
    'SMTP_USER',
    'SMTP_PASS',
    'MAIL_FROM'
];

const assertEmailConfig = () => {
    const missingKeys = requiredKeys.filter((key) => !process.env[key]);

    if (missingKeys.length > 0) {
        throw new Error(`Missing email configuration: ${missingKeys.join(', ')}`);
    }
};

const createTransporter = () => {
    assertEmailConfig();

    return nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: Number(process.env.SMTP_PORT),
        secure: process.env.SMTP_SECURE === 'true',
        connectionTimeout: Number(process.env.SMTP_TIMEOUT_MS || 5000),
        greetingTimeout: Number(process.env.SMTP_TIMEOUT_MS || 5000),
        socketTimeout: Number(process.env.SMTP_TIMEOUT_MS || 5000),
        auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS
        }
    });
};

exports.sendVerificationEmail = async (email, verificationCode) => {
    const transporter = createTransporter();

    await transporter.sendMail({
        from: process.env.MAIL_FROM,
        to: email,
        subject: 'InSight verification code',
        text: `Your InSight verification code is ${verificationCode}. This code expires in 10 minutes.`,
        html: `
            <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; line-height: 1.5;">
                <h2>Verify your InSight account</h2>
                <p>Your verification code is:</p>
                <p style="font-size: 28px; font-weight: 700; letter-spacing: 4px;">${verificationCode}</p>
                <p>This code expires in 10 minutes.</p>
            </div>
        `
    });
};
