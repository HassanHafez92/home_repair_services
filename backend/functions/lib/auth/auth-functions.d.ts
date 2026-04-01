/**
 * Fixawy Platform — Authentication Cloud Functions
 *
 * Handles:
 * - User creation trigger (creates user profile + wallet)
 * - Custom claims management (admin, technician roles)
 */
import * as functions from "firebase-functions";
/**
 * Triggered when a new user is created via Firebase Auth.
 * Creates the user profile document and an empty wallet.
 */
export declare const onUserCreated: functions.CloudFunction<import("firebase-admin/auth").UserRecord>;
/**
 * Callable function to set custom claims for role-based access.
 * Only admins can call this function.
 */
export declare const setCustomClaims: functions.HttpsFunction & functions.Runnable<any>;
//# sourceMappingURL=auth-functions.d.ts.map