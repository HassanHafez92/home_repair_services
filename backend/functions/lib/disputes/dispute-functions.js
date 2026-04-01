"use strict";
/**
 * Fixawy Platform — Dispute Cloud Functions
 *
 * Handles:
 * - Dispute/panic button creation
 * - Dispute resolution with Risk Fund payout
 * - Customer account blocking on confirmed disputes
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
exports.resolveDispute = exports.createDispute = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const db = admin.firestore();
/**
 * Creates a new dispute. Triggered by the technician's panic button.
 * - Flags the job as disputed
 * - Blocks the customer's account
 * - Compensates the technician from the Risk Fund
 */
exports.createDispute = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Not authenticated.");
    }
    const reportedBy = context.auth.uid;
    const { jobId, reason, description } = data;
    if (!jobId || !reason) {
        throw new functions.https.HttpsError("invalid-argument", "Job ID and reason are required.");
    }
    const jobRef = db.collection("jobs").doc(jobId);
    const jobDoc = await jobRef.get();
    if (!jobDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Job not found.");
    }
    const jobData = jobDoc.data();
    // Verify the reporter is involved in this job
    if (jobData.customerId !== reportedBy &&
        jobData.technicianId !== reportedBy) {
        throw new functions.https.HttpsError("permission-denied", "You are not involved in this job.");
    }
    const reportedAgainst = jobData.customerId === reportedBy
        ? jobData.technicianId
        : jobData.customerId;
    const batch = db.batch();
    // Create dispute document
    const disputeRef = db.collection("disputes").doc();
    batch.set(disputeRef, {
        jobId,
        reportedBy,
        reportedAgainst,
        reason,
        description: description || null,
        status: "open",
        resolution: null,
        adminNotes: null,
        handledBy: null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Mark job as disputed
    batch.update(jobRef, {
        status: "disputed",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // If technician reported "customer refused to pay"
    if (reason === "customerRefusedToPay" && jobData.technicianId === reportedBy) {
        // Block customer account
        const customerRef = db.collection("users").doc(jobData.customerId);
        batch.update(customerRef, {
            isBlocked: true,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        // Add negative debt to customer wallet
        const totalOwed = jobData.totalAmount || 0;
        if (totalOwed > 0) {
            const customerWalletRef = db
                .collection("wallets")
                .doc(jobData.customerId);
            batch.update(customerWalletRef, {
                balance: admin.firestore.FieldValue.increment(-totalOwed),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            // Log customer debt transaction
            const customerTxRef = db.collection("transactions").doc();
            batch.set(customerTxRef, {
                walletId: jobData.customerId,
                userId: jobData.customerId,
                jobId,
                amount: -totalOwed,
                type: "penalty",
                description: `Unpaid job debt - Account blocked (Job ${jobId.substring(0, 8)})`,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        // Compensate technician from Risk Fund
        const techEarning = (jobData.totalAmount || 0) - (jobData.platformFee || 0);
        if (techEarning > 0) {
            const techWalletRef = db
                .collection("wallets")
                .doc(jobData.technicianId);
            batch.update(techWalletRef, {
                balance: admin.firestore.FieldValue.increment(techEarning),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            const techTxRef = db.collection("transactions").doc();
            batch.set(techTxRef, {
                walletId: jobData.technicianId,
                userId: jobData.technicianId,
                jobId,
                amount: techEarning,
                type: "riskFundPayout",
                description: `Risk Fund compensation - customer refused to pay (Job ${jobId.substring(0, 8)})`,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            // Deduct from Risk Fund
            const riskFundRef = db.collection("risk_fund").doc("main");
            batch.set(riskFundRef, {
                balance: admin.firestore.FieldValue.increment(-techEarning),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true });
        }
    }
    await batch.commit();
    functions.logger.info(`Dispute created for job ${jobId} by ${reportedBy}. Reason: ${reason}`);
    return { success: true, disputeId: disputeRef.id };
});
/**
 * Admin resolves a dispute.
 */
exports.resolveDispute = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    var _a;
    if (!((_a = context.auth) === null || _a === void 0 ? void 0 : _a.token.admin)) {
        throw new functions.https.HttpsError("permission-denied", "Only admins can resolve disputes.");
    }
    const { disputeId, resolution, adminNotes, unblockCustomer } = data;
    if (!disputeId || !resolution) {
        throw new functions.https.HttpsError("invalid-argument", "Dispute ID and resolution are required.");
    }
    const disputeRef = db.collection("disputes").doc(disputeId);
    const disputeDoc = await disputeRef.get();
    if (!disputeDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Dispute not found.");
    }
    const disputeData = disputeDoc.data();
    const batch = db.batch();
    // Update dispute status
    batch.update(disputeRef, {
        status: "resolved",
        resolution,
        adminNotes: adminNotes || null,
        handledBy: context.auth.uid,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Unblock customer if requested
    if (unblockCustomer && disputeData.reportedAgainst) {
        const customerRef = db
            .collection("users")
            .doc(disputeData.reportedAgainst);
        batch.update(customerRef, {
            isBlocked: false,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    }
    await batch.commit();
    functions.logger.info(`Dispute ${disputeId} resolved by admin ${context.auth.uid}`);
    return { success: true };
});
//# sourceMappingURL=dispute-functions.js.map