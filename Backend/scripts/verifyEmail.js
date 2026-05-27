require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const { verifyEmailConfiguration, sendVerificationEmail } = require('../services/emailService');

const main = async () => {
    const testRecipient = process.argv[2];

    await verifyEmailConfiguration();
    console.log('SMTP configuration verified successfully.');

    if (testRecipient) {
        await sendVerificationEmail(testRecipient, '123456');
        console.log(`Test verification email sent to ${testRecipient}.`);
    }
};

main().catch((error) => {
    console.error('Email verification failed:', error.message);
    process.exit(1);
});
