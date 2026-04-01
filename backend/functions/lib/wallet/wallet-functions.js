"use strict";
/**
 * Fixawy Platform — Wallet Cloud Functions
 *
 * Handles:
 * - Wallet balance updates (atomic operations)
 * - Transaction history retrieval
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.getTransactionHistory = exports.updateWalletBalance = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const db = admin.firestore();
/**
 * Updates a wallet balance atomically. Admin-only.
 * Used for payouts, manual adjustments, etc.
 */
exports.updateWalletBalance = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    var _a, _b, _c;
    if (!((_a = context.auth) === null || _a === void 0 ? void 0 : _a.token.admin)) {
        throw new functions.https.HttpsError("permission-denied", "Only admins can directly update wallets.");
    }
    const { userId, amount, type, description } = data;
    if (!userId || amount === undefined || !type) {
        throw new functions.https.HttpsError("invalid-argument", "userId, amount, and type are required.");
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
    functions.logger.info(`Wallet ${userId} updated by ${amount} (${type}). New balance: ${(_b = updatedWallet.data()) === null || _b === void 0 ? void 0 : _b.balance}`);
    return {
        success: true,
        newBalance: (_c = updatedWallet.data()) === null || _c === void 0 ? void 0 : _c.balance,
    };
});
/**
 * Retrieves paginated transaction history for a user.
 */
exports.getTransactionHistory = functions
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
    const transactions = snapshot.docs.map((doc) => {
        var _a, _b;
        return ({
            id: doc.id,
            ...doc.data(),
            createdAt: (_b = (_a = doc.data().createdAt) === null || _a === void 0 ? void 0 : _a.toDate()) === null || _b === void 0 ? void 0 : _b.toISOString(),
        });
    });
    return {
        transactions,
        hasMore: transactions.length === pageSize,
        lastDocId: snapshot.docs.length > 0
            ? snapshot.docs[snapshot.docs.length - 1].id
            : null,
    };
});
//# sourceMappingURL=wallet-functions.js.map