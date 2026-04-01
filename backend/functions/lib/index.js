"use strict";
/**
 * Fixawy Platform — Cloud Functions Entry Point
 *
 * Exports all Cloud Functions for the Fixawy platform:
 * - Auth: User creation triggers, custom claims
 * - Jobs: Lifecycle management (create, accept, complete, cancel)
 * - Payments: Paymob integration, wallet operations
 * - Disputes: Dispute creation, resolution, Risk Fund
 * - Notifications: FCM push notifications
 * - Admin: Dashboard operations, user management
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
exports.updateGeofenceZone = exports.updatePricing = exports.manageUser = exports.getAdminDashboardStats = exports.onJobStatusChange = exports.sendPushNotification = exports.getTransactionHistory = exports.updateWalletBalance = exports.resolveDispute = exports.createDispute = exports.handlePaymobWebhook = exports.processPayment = exports.rateJob = exports.cancelJob = exports.rejectInvoice = exports.approveInvoice = exports.submitInvoice = exports.updateJobStatus = exports.acceptJob = exports.createEmergencyJob = exports.setCustomClaims = exports.onUserCreated = void 0;
const admin = __importStar(require("firebase-admin"));
// Initialize Firebase Admin SDK
admin.initializeApp();
// Export all function groups
var auth_functions_1 = require("./auth/auth-functions");
Object.defineProperty(exports, "onUserCreated", { enumerable: true, get: function () { return auth_functions_1.onUserCreated; } });
Object.defineProperty(exports, "setCustomClaims", { enumerable: true, get: function () { return auth_functions_1.setCustomClaims; } });
var job_functions_1 = require("./jobs/job-functions");
Object.defineProperty(exports, "createEmergencyJob", { enumerable: true, get: function () { return job_functions_1.createEmergencyJob; } });
Object.defineProperty(exports, "acceptJob", { enumerable: true, get: function () { return job_functions_1.acceptJob; } });
Object.defineProperty(exports, "updateJobStatus", { enumerable: true, get: function () { return job_functions_1.updateJobStatus; } });
Object.defineProperty(exports, "submitInvoice", { enumerable: true, get: function () { return job_functions_1.submitInvoice; } });
Object.defineProperty(exports, "approveInvoice", { enumerable: true, get: function () { return job_functions_1.approveInvoice; } });
Object.defineProperty(exports, "rejectInvoice", { enumerable: true, get: function () { return job_functions_1.rejectInvoice; } });
Object.defineProperty(exports, "cancelJob", { enumerable: true, get: function () { return job_functions_1.cancelJob; } });
Object.defineProperty(exports, "rateJob", { enumerable: true, get: function () { return job_functions_1.rateJob; } });
var payment_functions_1 = require("./payments/payment-functions");
Object.defineProperty(exports, "processPayment", { enumerable: true, get: function () { return payment_functions_1.processPayment; } });
Object.defineProperty(exports, "handlePaymobWebhook", { enumerable: true, get: function () { return payment_functions_1.handlePaymobWebhook; } });
var dispute_functions_1 = require("./disputes/dispute-functions");
Object.defineProperty(exports, "createDispute", { enumerable: true, get: function () { return dispute_functions_1.createDispute; } });
Object.defineProperty(exports, "resolveDispute", { enumerable: true, get: function () { return dispute_functions_1.resolveDispute; } });
var wallet_functions_1 = require("./wallet/wallet-functions");
Object.defineProperty(exports, "updateWalletBalance", { enumerable: true, get: function () { return wallet_functions_1.updateWalletBalance; } });
Object.defineProperty(exports, "getTransactionHistory", { enumerable: true, get: function () { return wallet_functions_1.getTransactionHistory; } });
var notification_functions_1 = require("./notifications/notification-functions");
Object.defineProperty(exports, "sendPushNotification", { enumerable: true, get: function () { return notification_functions_1.sendPushNotification; } });
Object.defineProperty(exports, "onJobStatusChange", { enumerable: true, get: function () { return notification_functions_1.onJobStatusChange; } });
var admin_functions_1 = require("./admin/admin-functions");
Object.defineProperty(exports, "getAdminDashboardStats", { enumerable: true, get: function () { return admin_functions_1.getAdminDashboardStats; } });
Object.defineProperty(exports, "manageUser", { enumerable: true, get: function () { return admin_functions_1.manageUser; } });
Object.defineProperty(exports, "updatePricing", { enumerable: true, get: function () { return admin_functions_1.updatePricing; } });
Object.defineProperty(exports, "updateGeofenceZone", { enumerable: true, get: function () { return admin_functions_1.updateGeofenceZone; } });
//# sourceMappingURL=index.js.map