/**
 * Fixawy Platform — Wallet Cloud Functions
 *
 * Handles:
 * - Wallet balance updates (atomic operations)
 * - Transaction history retrieval
 */
import * as functions from "firebase-functions";
/**
 * Updates a wallet balance atomically. Admin-only.
 * Used for payouts, manual adjustments, etc.
 */
export declare const updateWalletBalance: functions.HttpsFunction & functions.Runnable<any>;
/**
 * Retrieves paginated transaction history for a user.
 */
export declare const getTransactionHistory: functions.HttpsFunction & functions.Runnable<any>;
//# sourceMappingURL=wallet-functions.d.ts.map