/**
 * Fixawy Platform — Notification Cloud Functions
 *
 * Handles:
 * - Sending FCM push notifications
 * - Automatic notifications on job status changes (Firestore trigger)
 */
import * as functions from "firebase-functions";
/**
 * Sends a push notification to a specific user via FCM.
 */
export declare const sendPushNotification: functions.HttpsFunction & functions.Runnable<any>;
/**
 * Firestore trigger: Automatically sends notifications when job status changes.
 */
export declare const onJobStatusChange: functions.CloudFunction<functions.Change<functions.firestore.QueryDocumentSnapshot>>;
//# sourceMappingURL=notification-functions.d.ts.map