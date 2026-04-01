"use strict";
/**
 * Fixawy Platform — Admin Cloud Functions
 *
 * Handles:
 * - Dashboard statistics
 * - User management (block/unblock, role changes)
 * - Pricing management (server-controlled)
 * - Geofence zone management (admin-configurable)
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
exports.updateGeofenceZone = exports.updatePricing = exports.manageUser = exports.getAdminDashboardStats = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const db = admin.firestore();
/**
 * Returns aggregated dashboard statistics for the admin panel.
 */
exports.getAdminDashboardStats = functions
    .region("europe-west1")
    .https.onCall(async (_data, context) => {
    var _a, _b;
    if (!((_a = context.auth) === null || _a === void 0 ? void 0 : _a.token.admin)) {
        throw new functions.https.HttpsError("permission-denied", "Admin access required.");
    }
    const now = new Date();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    // Parallel queries for efficiency
    const [totalUsersSnap, totalTechsSnap, activeJobsSnap, todayJobsSnap, weekJobsSnap, openDisputesSnap, riskFundSnap,] = await Promise.all([
        db.collection("users").where("role", "==", "customer").count().get(),
        db.collection("technician_profiles").count().get(),
        db.collection("jobs")
            .where("status", "in", [
            "searching", "accepted", "enRoute", "arrived", "inProgress", "invoiced",
        ])
            .count()
            .get(),
        db.collection("jobs")
            .where("createdAt", ">=", todayStart)
            .count()
            .get(),
        db.collection("jobs")
            .where("createdAt", ">=", weekAgo)
            .where("status", "==", "completed")
            .count()
            .get(),
        db.collection("disputes")
            .where("status", "==", "open")
            .count()
            .get(),
        db.collection("risk_fund").doc("main").get(),
    ]);
    return {
        totalCustomers: totalUsersSnap.data().count,
        totalTechnicians: totalTechsSnap.data().count,
        activeJobs: activeJobsSnap.data().count,
        todayJobs: todayJobsSnap.data().count,
        weekCompletedJobs: weekJobsSnap.data().count,
        openDisputes: openDisputesSnap.data().count,
        riskFundBalance: ((_b = riskFundSnap.data()) === null || _b === void 0 ? void 0 : _b.balance) || 0,
    };
});
/**
 * Admin manages a user: block/unblock, change role, etc.
 */
exports.manageUser = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    var _a;
    if (!((_a = context.auth) === null || _a === void 0 ? void 0 : _a.token.admin)) {
        throw new functions.https.HttpsError("permission-denied", "Admin access required.");
    }
    const { userId, action, newRole } = data;
    if (!userId || !action) {
        throw new functions.https.HttpsError("invalid-argument", "userId and action required.");
    }
    const userRef = db.collection("users").doc(userId);
    const userDoc = await userRef.get();
    if (!userDoc.exists) {
        throw new functions.https.HttpsError("not-found", "User not found.");
    }
    switch (action) {
        case "block":
            await userRef.update({
                isBlocked: true,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            break;
        case "unblock":
            await userRef.update({
                isBlocked: false,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            break;
        case "changeRole":
            if (!newRole) {
                throw new functions.https.HttpsError("invalid-argument", "newRole required for role change.");
            }
            // Update custom claims
            const claims = { role: newRole };
            if (newRole === "admin")
                claims.admin = true;
            await admin.auth().setCustomUserClaims(userId, claims);
            await userRef.update({
                role: newRole,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            break;
        case "approveTech":
            await db.collection("technician_profiles").doc(userId).update({
                verificationStatus: "approved",
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            break;
        case "rejectTech":
            await db.collection("technician_profiles").doc(userId).update({
                verificationStatus: "rejected",
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            break;
        default:
            throw new functions.https.HttpsError("invalid-argument", `Unknown action: ${action}`);
    }
    functions.logger.info(`Admin ${context.auth.uid} performed ${action} on user ${userId}`);
    return { success: true, action, userId };
});
/**
 * Updates server-controlled pricing for a service category.
 */
exports.updatePricing = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    var _a;
    if (!((_a = context.auth) === null || _a === void 0 ? void 0 : _a.token.admin)) {
        throw new functions.https.HttpsError("permission-denied", "Admin access required.");
    }
    const { serviceCategory, items, inspectionFee, surgeMultiplier, isSurgeActive } = data;
    if (!serviceCategory) {
        throw new functions.https.HttpsError("invalid-argument", "Service category required.");
    }
    const pricingRef = db.collection("pricing").doc(serviceCategory);
    const updateData = {
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    if (items !== undefined)
        updateData.items = items;
    if (inspectionFee !== undefined)
        updateData.inspectionFee = inspectionFee;
    if (surgeMultiplier !== undefined)
        updateData.surgeMultiplier = surgeMultiplier;
    if (isSurgeActive !== undefined)
        updateData.isSurgeActive = isSurgeActive;
    await pricingRef.set(updateData, { merge: true });
    functions.logger.info(`Pricing updated for ${serviceCategory} by admin ${context.auth.uid}`);
    return { success: true };
});
/**
 * Creates or updates a geofence zone (admin-configurable).
 */
exports.updateGeofenceZone = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    var _a;
    if (!((_a = context.auth) === null || _a === void 0 ? void 0 : _a.token.admin)) {
        throw new functions.https.HttpsError("permission-denied", "Admin access required.");
    }
    const { zoneId, name, nameAr, center, radiusKm, isActive } = data;
    if (!zoneId || !name || !center) {
        throw new functions.https.HttpsError("invalid-argument", "zoneId, name, and center coordinates required.");
    }
    const zoneRef = db.collection("geofence_zones").doc(zoneId);
    await zoneRef.set({
        name,
        nameAr: nameAr || name,
        center: new admin.firestore.GeoPoint(center.lat, center.lng),
        radiusKm: radiusKm || 10,
        isActive: isActive !== undefined ? isActive : true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    functions.logger.info(`Geofence zone ${zoneId} updated by admin ${context.auth.uid}`);
    return { success: true };
});
//# sourceMappingURL=admin-functions.js.map