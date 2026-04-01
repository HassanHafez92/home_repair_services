/**
 * Fixawy Platform — Job Lifecycle Cloud Functions
 *
 * Handles the complete job lifecycle:
 * - Emergency job creation with technician dispatching
 * - Job acceptance by technician
 * - Status updates (en_route, arrived, in_progress)
 * - Invoice submission with receipt validation
 * - Invoice approval/rejection by customer
 * - Job cancellation with penalty logic
 * - Post-job rating
 */
import * as functions from "firebase-functions";
/**
 * Creates a new emergency service request.
 * Validates customer account, creates job document, and triggers
 * technician search via FCM notifications.
 */
export declare const createEmergencyJob: functions.HttpsFunction & functions.Runnable<any>;
/**
 * Technician accepts a job ping.
 * Updates job status to 'accepted' and assigns technician.
 */
export declare const acceptJob: functions.HttpsFunction & functions.Runnable<any>;
/**
 * Updates the job status (en_route, arrived, in_progress).
 * Validates the state machine transitions.
 */
export declare const updateJobStatus: functions.HttpsFunction & functions.Runnable<any>;
/**
 * Technician submits the invoice with labor items, materials cost,
 * and live receipt image. Server validates prices against pricing database.
 */
export declare const submitInvoice: functions.HttpsFunction & functions.Runnable<any>;
/**
 * Customer approves the invoice and work begins / payment is processed.
 */
export declare const approveInvoice: functions.HttpsFunction & functions.Runnable<any>;
/**
 * Customer rejects the invoice. Triggers a re-negotiation flow.
 */
export declare const rejectInvoice: functions.HttpsFunction & functions.Runnable<any>;
/**
 * Cancels a job with penalty logic based on timing and status.
 */
export declare const cancelJob: functions.HttpsFunction & functions.Runnable<any>;
/**
 * Customer rates the completed job with stars and optional review text.
 */
export declare const rateJob: functions.HttpsFunction & functions.Runnable<any>;
//# sourceMappingURL=job-functions.d.ts.map