/**
 * Fixawy Platform — Authentication Cloud Functions
 *
 * Handles:
 * - User creation trigger (creates user profile + wallet)
 * - Custom claims management (admin, technician roles)
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Triggered when a new user is created via Firebase Auth.
 * Creates the user profile document and an empty wallet.
 */
export const onUserCreated = functions
  .region("europe-west1")
  .auth.user()
  .onCreate(async (user) => {
    const { uid, phoneNumber, email, displayName, photoURL } = user;

    const batch = db.batch();

    // Create user profile document
    const userRef = db.collection("users").doc(uid);
    batch.set(userRef, {
      phone: phoneNumber || "",
      email: email || null,
      role: "customer", // Default role
      displayName: displayName || phoneNumber || "User",
      photoUrl: photoURL || null,
      isActive: true,
      isBlocked: false,
      fcmToken: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Create wallet for the user
    const walletRef = db.collection("wallets").doc(uid);
    batch.set(walletRef, {
      balance: 0,
      creditLimit: 2000,
      currency: "EGP",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    try {
      await batch.commit();
      functions.logger.info(`User profile and wallet created for ${uid}`);
    } catch (error) {
      functions.logger.error(`Error creating user profile for ${uid}:`, error);
      throw error;
    }
  });

/**
 * Callable function to set custom claims for role-based access.
 * Only admins can call this function.
 */
export const setCustomClaims = functions
  .region("europe-west1")
  .https.onCall(async (data, context) => {
    // Verify the caller is an admin
    if (!context.auth?.token.admin) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can set custom claims."
      );
    }

    const { uid, role } = data;

    if (!uid || !role) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "UID and role are required."
      );
    }

    const validRoles = ["customer", "technician", "admin"];
    if (!validRoles.includes(role)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        `Invalid role. Must be one of: ${validRoles.join(", ")}`
      );
    }

    try {
      // Set custom claims
      const claims: Record<string, boolean | string> = { role };
      if (role === "admin") {
        claims.admin = true;
      }
      await admin.auth().setCustomUserClaims(uid, claims);

      // Update the user document
      await db.collection("users").doc(uid).update({
        role,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // If setting as technician, create a technician profile
      if (role === "technician") {
        const techRef = db.collection("technician_profiles").doc(uid);
        const techDoc = await techRef.get();
        if (!techDoc.exists) {
          await techRef.set({
            specialties: [],
            verificationStatus: "pending",
            idFrontUrl: null,
            idBackUrl: null,
            criminalRecordUrl: null,
            averageRating: 0,
            totalJobs: 0,
            totalReviews: 0,
            isOnline: false,
            currentZone: null,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }

      functions.logger.info(`Custom claims set for ${uid}: role=${role}`);
      return { success: true, message: `Role set to ${role} for user ${uid}` };
    } catch (error) {
      functions.logger.error(`Error setting custom claims for ${uid}:`, error);
      throw new functions.https.HttpsError("internal", "Failed to set claims.");
    }
  });
