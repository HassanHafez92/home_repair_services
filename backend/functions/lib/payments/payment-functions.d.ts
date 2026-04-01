/**
 * Fixawy Platform — Payment Cloud Functions
 *
 * Handles:
 * - Payment processing (Paymob integration)
 * - Webhook handler for Paymob callbacks
 * - Commission calculation and wallet updates
 */
import * as functions from "firebase-functions";
/**
 * Initiates a payment via Paymob for a completed job.
 * Returns a payment token / URL for the customer to complete payment.
 */
export declare const processPayment: functions.HttpsFunction & functions.Runnable<any>;
/**
 * Handles Paymob payment callbacks (success, failure, etc.)
 */
export declare const handlePaymobWebhook: functions.HttpsFunction;
//# sourceMappingURL=payment-functions.d.ts.map