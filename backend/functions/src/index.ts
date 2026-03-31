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

import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
admin.initializeApp();

// Export all function groups
export { onUserCreated, setCustomClaims } from "./auth/auth-functions";
export {
  createEmergencyJob,
  acceptJob,
  updateJobStatus,
  submitInvoice,
  approveInvoice,
  rejectInvoice,
  cancelJob,
  rateJob,
} from "./jobs/job-functions";
export {
  processPayment,
  handlePaymobWebhook,
} from "./payments/payment-functions";
export {
  createDispute,
  resolveDispute,
} from "./disputes/dispute-functions";
export {
  updateWalletBalance,
  getTransactionHistory,
} from "./wallet/wallet-functions";
export {
  sendPushNotification,
  onJobStatusChange,
} from "./notifications/notification-functions";
export {
  getAdminDashboardStats,
  manageUser,
  updatePricing,
  updateGeofenceZone,
} from "./admin/admin-functions";
