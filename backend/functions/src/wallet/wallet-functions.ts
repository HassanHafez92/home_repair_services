/**
 * Fixawy Platform — Wallet Cloud Functions
 *
 * Handles:
 * - Wallet balance updates (atomic operations)
 * - Transaction history retrieval
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Updates a wallet balance atomically. Admin-only.
 * Used for payouts, manual adjustments, etc.
 */
export const updateWalletBalance = functions
  .region("europe-west1")
  .https.onCall(async (data, context) => {
    if (!context.auth?.token.admin) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can directly update wallets."
      );
    }

    const { userId, amount, type, description } = data;

    if (!userId || amount === undefined || !type) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "userId, amount, and type are required."
      );
    }

    const walletRef = db.collection("wallets").doc(userId);
    const walletDoc = await walletRef.get();

    if (!walletDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Wallet not found.");
    }

    const batch = db.batch();

    // Update wallet balance
    batch.update(walletRef, {
      balance: admin.firestore.FieldValue.increment(amount),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Create transaction record
    const txRef = db.collection("transactions").doc();
    batch.set(txRef, {
      walletId: userId,
      userId,
      jobId: data.jobId || null,
      amount,
      type,
      description: description || `Manual ${type} by admin`,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await batch.commit();

    const updatedWallet = await walletRef.get();

    functions.logger.info(
      `Wallet ${userId} updated by ${amount} (${type}). New balance: ${updatedWallet.data()?.balance}`
    );

    return {
      success: true,
      newBalance: updatedWallet.data()?.balance,
    };
  });

/**
 * Retrieves paginated transaction history for a user.
 */
export const getTransactionHistory = functions
  .region("europe-west1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Not authenticated.");
    }

    const userId = context.auth.uid;
    const { limit: queryLimit, startAfter } = data;

    const pageSize = Math.min(queryLimit || 20, 50);

    let query = db
      .collection("transactions")
      .where("userId", "==", userId)
      .orderBy("createdAt", "desc")
      .limit(pageSize);

    if (startAfter) {
      const startDoc = await db.collection("transactions").doc(startAfter).get();
      if (startDoc.exists) {
        query = query.startAfter(startDoc);
      }
    }

    const snapshot = await query.get();
    const transactions = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
      createdAt: doc.data().createdAt?.toDate()?.toISOString(),
    }));

    return {
      transactions,
      hasMore: transactions.length === pageSize,
      lastDocId: snapshot.docs.length > 0
        ? snapshot.docs[snapshot.docs.length - 1].id
        : null,
    };
  });
