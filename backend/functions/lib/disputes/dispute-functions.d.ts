/**
 * Fixawy Platform — Dispute Cloud Functions
 *
 * Handles:
 * - Dispute/panic button creation
 * - Dispute resolution with Risk Fund payout
 * - Customer account blocking on confirmed disputes
 */
import * as functions from "firebase-functions";
/**
 * Creates a new dispute. Triggered by the technician's panic button.
 * - Flags the job as disputed
 * - Blocks the customer's account
 * - Compensates the technician from the Risk Fund
 */
export declare const createDispute: functions.HttpsFunction & functions.Runnable<any>;
/**
 * Admin resolves a dispute.
 */
export declare const resolveDispute: functions.HttpsFunction & functions.Runnable<any>;
//# sourceMappingURL=dispute-functions.d.ts.map