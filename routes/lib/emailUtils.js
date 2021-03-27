// Import the Mongoose Code model for database interaction
const Code = require('../../models/verificationCode'); 

// Crypto module for generating more secure numbers than Math.random can provide
const crypto = require('crypto');

// Nodemailer module for actual emailing
const nodemailer = require('nodemailer');

// Mail transporter object
const transporter = (process.env.DO_EMAIL == 1) ? nodemailer.createTransport({
    host: process.env.MAIL_SERVER,
    port: process.env.MAIL_PORT,
    secure: false,
    auth: {
        user: process.env.MAIL_USERNAME,
        pass: process.env.MAIL_PASSWORD
    }
}) : null;


// Generate a verification code of N digits to be sent to a user
function generateVerificationCode(digits, id, purpose) {
    const generatedCode = crypto.randomInt(0, Math.pow(10, digits)).toString(10);

    const code = new Code({
        code: generatedCode,
        user: id,
        purpose: purpose
    });

    code.save().catch(function(err) {
        console.log(err);
    });

    return generatedCode;
}

// Send a verification email to the specified user
async function sendVerificationEmail(id, name, email) {
    const verifCode = generateVerificationCode(process.env.CODE_LENGTH, id, "Email Verification");

    // Do not email on development machines
    if (process.env.DO_EMAIL == 0)
        return;
    
    let info = await transporter.sendMail({
        from: '"PantryPal" <no-reply@pantry.pal>',
        to: email,
        subject: 'Email Verification Requested',
        text: `Hello ${name}, your verification code is ${verifCode}`,
        html: `Hello ${name}, your verification code is ${verifCode}`
    });

    // Keep info for logging later

    return;
}

module.exports = {
    sendVerificationEmail: sendVerificationEmail
}