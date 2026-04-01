/**
 * Fixawy Platform — Admin Cloud Functions
 *
 * Handles:
 * - Dashboard statistics
 * - User management (block/unblock, role changes)
 * - Pricing management (server-controlled)
 * - Geofence zone management (admin-configurable)
 */
import * as functions from "firebase-functions";
/**
 * Returns aggregated dashboard statistics for the admin panel.
 */
export declare const getAdminDashboardStats: functions.HttpsFunction & functions.Runnable<any>;
/**
 * Admin manages a user: block/unblock, change role, etc.
 */
export declare const manageUser: functions.HttpsFunction & functions.Runnable<any>;
/**
 * Updates server-controlled pricing for a service category.
 */
export declare const updatePricing: functions.HttpsFunction & functions.Runnable<any>;
/**
 * Creates or updates a geofence zone (admin-configurable).
 */
export declare const updateGeofenceZone: functions.HttpsFunction & functions.Runnable<any>;
//# sourceMappingURL=admin-functions.d.ts.map