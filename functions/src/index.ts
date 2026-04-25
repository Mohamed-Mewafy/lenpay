/**
 * IMPORTANT: These are Callable Functions (onCall), NOT HTTP triggers (onRequest).
 * They can ONLY be invoked via the Firebase SDK (e.g., cloud_functions Flutter package).
 * Testing via browser GET/POST or curl will fail with "Invalid request, unable to process."
 * To test locally, ensure all emulators (functions, auth, firestore) are running,
 * and the Flutter app is configured to use them via useFunctionsEmulator(),
 * useAuthEmulator(), and useFirestoreEmulator().
 */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { Timestamp, FieldValue } from "firebase-admin/firestore";
import * as nodemailer from "nodemailer";

admin.initializeApp();
const db = admin.firestore();

// Configure Gmail SMTP transport
// Use App Password (not your regular Gmail password)
// Generate App Password at: https://myaccount.google.com/apppasswords
const gmailUser = functions.config().email?.user || process.env.EMAIL_USER || "1xx3011@gmail.com";
const gmailPass = functions.config().email?.password || process.env.EMAIL_PASSWORD;

const mailTransport = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 465,
    secure: true, // SSL
    auth: {
        user: gmailUser,
        pass: gmailPass,
    },
});

const APP_NAME = "LenPay";
const OTP_EXPIRY_MINUTES = 10;

function generateOTP(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
}

function getEmailTemplate(otp: string, name: string): string {
    return `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
      <h2 style="color: #673AB7;">Verify Your Email</h2>
      <p>Hi ${name},</p>
      <p>Thank you for signing up for ${APP_NAME}. Use the verification code below to activate your account:</p>
      <div style="background: #f5f5f5; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
        <span style="font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #333;">${otp}</span>
      </div>
      <p>This code will expire in ${OTP_EXPIRY_MINUTES} minutes.</p>
      <p>If you didn't request this, please ignore this email.</p>
      <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
      <p style="color: #999; font-size: 12px;">${APP_NAME} Team</p>
    </div>
  `;
}

export const generateEmailOTP = functions.https.onCall(async (request) => {
    // Ensure user is authenticated
    if (!request.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
    }

    const { email, name } = request.data;
    if (!email || typeof email !== "string") {
        throw new functions.https.HttpsError("invalid-argument", "Email is required.");
    }

    const otp = generateOTP();
    const expiry = Timestamp.fromDate(
        new Date(Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000)
    );

    // Store OTP in Firestore
    await db.collection("emailOTPs").doc(email.toLowerCase()).set({
        otp,
        expiry,
        uid: request.auth.uid,
        attempts: 0,
        createdAt: FieldValue.serverTimestamp(),
    });

    // Send email
    const mailOptions = {
        from: `${APP_NAME} <${gmailUser}>`,
        to: email,
        subject: `Your ${APP_NAME} Verification Code`,
        html: getEmailTemplate(otp, name || "User"),
    };

    try {
        await mailTransport.sendMail(mailOptions);
        return { success: true, message: "OTP sent successfully" };
    } catch (error) {
        console.error("Failed to send email:", error);
        throw new functions.https.HttpsError("internal", "Failed to send verification email.");
    }
});

export const verifyEmailOTP = functions.https.onCall(async (request) => {
    // Ensure user is authenticated
    if (!request.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
    }

    const { email, otp } = request.data;
    if (!email || !otp) {
        throw new functions.https.HttpsError("invalid-argument", "Email and OTP are required.");
    }

    const docRef = db.collection("emailOTPs").doc(email.toLowerCase());
    const doc = await docRef.get();

    if (!doc.exists) {
        throw new functions.https.HttpsError("not-found", "No verification code found. Please request a new one.");
    }

    const dataDoc = doc.data()!;
    const now = Timestamp.now();

    // Check expiry
    if (dataDoc.expiry.toMillis() < now.toMillis()) {
        await docRef.delete();
        throw new functions.https.HttpsError("deadline-exceeded", "Verification code has expired. Please request a new one.");
    }

    // Check max attempts (5)
    const attempts = (dataDoc.attempts || 0) + 1;
    if (attempts > 5) {
        await docRef.delete();
        throw new functions.https.HttpsError("resource-exhausted", "Too many failed attempts. Please request a new code.");
    }

    // Update attempts
    await docRef.update({ attempts });

    // Verify OTP
    if (dataDoc.otp !== otp) {
        throw new functions.https.HttpsError("invalid-argument", "Invalid verification code.");
    }

    // OTP is correct - mark email as verified using Admin SDK
    try {
        await admin.auth().updateUser(request.auth.uid, {
            emailVerified: true,
        });
    } catch (authError: any) {
        // If user doesn't exist in Auth (e.g., emulator/prod mismatch), log warning
        // but still consider OTP verification successful.
        if (authError.code === "auth/user-not-found") {
            console.warn(
                `User ${request.auth.uid} not found in Auth. ` +
                "Skipping emailVerified update. User may need to re-authenticate with emulators."
            );
        } else {
            throw authError;
        }
    }

    // Delete the OTP document
    await docRef.delete();

    return { success: true, message: "Email verified successfully" };
});

