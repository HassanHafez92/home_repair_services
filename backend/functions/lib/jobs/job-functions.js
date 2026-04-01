"use strict";
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
exports.rateJob = exports.cancelJob = exports.rejectInvoice = exports.approveInvoice = exports.submitInvoice = exports.updateJobStatus = exports.acceptJob = exports.createEmergencyJob = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const uuid_1 = require("uuid");
const db = admin.firestore();
// ═══════════════════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════════════════
const INSPECTION_FEE = 75.0;
const PLATFORM_COMMISSION_RATE = 0.15;
const CANCELLATION_GRACE_PERIOD_MS = 5 * 60 * 1000; // 5 minutes
const LATE_CANCELLATION_PENALTY = 30.0;
const MATERIAL_APPROVAL_THRESHOLD = 500.0;
// ═══════════════════════════════════════════════════════════════════════
// CREATE EMERGENCY JOB
// ═══════════════════════════════════════════════════════════════════════
/**
 * Creates a new emergency service request.
 * Validates customer account, creates job document, and triggers
 * technician search via FCM notifications.
 */
exports.createEmergencyJob = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    var _a, _b, _c;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Must be authenticated to create a job.");
    }
    const customerId = context.auth.uid;
    const { serviceCategory, latitude, longitude, addressText, voiceNoteUrl, } = data;
    // Validate required fields
    if (!serviceCategory || !latitude || !longitude) {
        throw new functions.https.HttpsError("invalid-argument", "Service category and location are required.");
    }
    // Check if customer account is blocked
    const customerDoc = await db.collection("users").doc(customerId).get();
    if (!customerDoc.exists || ((_a = customerDoc.data()) === null || _a === void 0 ? void 0 : _a.isBlocked)) {
        throw new functions.https.HttpsError("permission-denied", "Your account is blocked. Please contact support.");
    }
    // Check for active jobs (prevent double-booking)
    const activeJobs = await db
        .collection("jobs")
        .where("customerId", "==", customerId)
        .where("status", "in", [
        "searching", "accepted", "enRoute", "arrived", "inProgress", "invoiced",
    ])
        .limit(1)
        .get();
    if (!activeJobs.empty) {
        throw new functions.https.HttpsError("already-exists", "You already have an active job. Please wait for it to complete.");
    }
    // Check for surge pricing
    const pricingDoc = await db
        .collection("pricing")
        .doc(serviceCategory)
        .get();
    const isSurge = pricingDoc.exists && ((_b = pricingDoc.data()) === null || _b === void 0 ? void 0 : _b.isSurgeActive) === true;
    const surgeMultiplier = isSurge
        ? (((_c = pricingDoc.data()) === null || _c === void 0 ? void 0 : _c.surgeMultiplier) || 1.0)
        : 1.0;
    const jobId = (0, uuid_1.v4)();
    const jobData = {
        customerId,
        technicianId: null,
        serviceCategory,
        status: "searching",
        location: new admin.firestore.GeoPoint(latitude, longitude),
        addressText: addressText || "",
        voiceNoteUrl: voiceNoteUrl || null,
        inspectionFee: INSPECTION_FEE,
        laborItems: [],
        materialsCost: 0,
        receiptImageUrl: null,
        totalAmount: 0,
        platformFee: 0,
        isSurge,
        surgeMultiplier,
        paymentMethod: null,
        isPaid: false,
        rating: null,
        review: null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        acceptedAt: null,
        arrivedAt: null,
        completedAt: null,
        cancelledAt: null,
        cancellationReason: null,
        cancelledBy: null,
        isSynced: true,
    };
    await db.collection("jobs").doc(jobId).set(jobData);
    // TODO: Find nearby technicians using geohash and send FCM notifications
    // This would query tech_telemetry for online techs in the same geofence zone
    functions.logger.info(`Emergency job ${jobId} created by ${customerId} for ${serviceCategory}`);
    return {
        success: true,
        data: {
            jobId,
            status: "searching",
            isSurge,
            surgeMultiplier,
            inspectionFee: INSPECTION_FEE * surgeMultiplier,
        },
    };
});
// ═══════════════════════════════════════════════════════════════════════
// ACCEPT JOB
// ═══════════════════════════════════════════════════════════════════════
/**
 * Technician accepts a job ping.
 * Updates job status to 'accepted' and assigns technician.
 */
exports.acceptJob = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Not authenticated.");
    }
    const technicianId = context.auth.uid;
    const { jobId } = data;
    if (!jobId) {
        throw new functions.https.HttpsError("invalid-argument", "Job ID required.");
    }
    const jobRef = db.collection("jobs").doc(jobId);
    // Use a transaction to prevent race conditions
    const result = await db.runTransaction(async (transaction) => {
        var _a;
        const jobDoc = await transaction.get(jobRef);
        if (!jobDoc.exists) {
            throw new functions.https.HttpsError("not-found", "Job not found.");
        }
        const jobData = jobDoc.data();
        if (jobData.status !== "searching") {
            throw new functions.https.HttpsError("failed-precondition", "Job is no longer available.");
        }
        // Verify technician is approved
        const techProfile = await transaction.get(db.collection("technician_profiles").doc(technicianId));
        if (!techProfile.exists ||
            ((_a = techProfile.data()) === null || _a === void 0 ? void 0 : _a.verificationStatus) !== "approved") {
            throw new functions.https.HttpsError("permission-denied", "Your account is not approved for jobs.");
        }
        transaction.update(jobRef, {
            technicianId,
            status: "accepted",
            acceptedAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return { success: true };
    });
    functions.logger.info(`Job ${jobId} accepted by technician ${technicianId}`);
    return result;
});
// ═══════════════════════════════════════════════════════════════════════
// UPDATE JOB STATUS
// ═══════════════════════════════════════════════════════════════════════
/**
 * Updates the job status (en_route, arrived, in_progress).
 * Validates the state machine transitions.
 */
exports.updateJobStatus = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Not authenticated.");
    }
    const { jobId, newStatus } = data;
    const userId = context.auth.uid;
    const validTransitions = {
        accepted: ["enRoute", "cancelled"],
        enRoute: ["arrived", "cancelled"],
        arrived: ["inProgress", "cancelled"],
        inProgress: ["invoiced"],
        invoiced: ["approved", "cancelled"],
        approved: ["completed"],
    };
    const jobRef = db.collection("jobs").doc(jobId);
    const jobDoc = await jobRef.get();
    if (!jobDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Job not found.");
    }
    const jobData = jobDoc.data();
    const currentStatus = jobData.status;
    // Verify user is involved in this job
    if (jobData.customerId !== userId && jobData.technicianId !== userId) {
        throw new functions.https.HttpsError("permission-denied", "You are not involved in this job.");
    }
    // Validate state transition
    if (!validTransitions[currentStatus] ||
        !validTransitions[currentStatus].includes(newStatus)) {
        throw new functions.https.HttpsError("failed-precondition", `Cannot transition from ${currentStatus} to ${newStatus}.`);
    }
    const updateData = {
        status: newStatus,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    // Set timestamps for specific status changes
    if (newStatus === "arrived") {
        updateData.arrivedAt = admin.firestore.FieldValue.serverTimestamp();
    }
    else if (newStatus === "completed") {
        updateData.completedAt = admin.firestore.FieldValue.serverTimestamp();
    }
    await jobRef.update(updateData);
    functions.logger.info(`Job ${jobId} status updated: ${currentStatus} → ${newStatus}`);
    return { success: true, jobId, status: newStatus };
});
// ═══════════════════════════════════════════════════════════════════════
// SUBMIT INVOICE
// ═══════════════════════════════════════════════════════════════════════
/**
 * Technician submits the invoice with labor items, materials cost,
 * and live receipt image. Server validates prices against pricing database.
 */
exports.submitInvoice = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Not authenticated.");
    }
    const technicianId = context.auth.uid;
    const { jobId, laborItemIds, materialsCost, receiptImageUrl } = data;
    if (!jobId || !laborItemIds || laborItemIds.length === 0) {
        throw new functions.https.HttpsError("invalid-argument", "Job ID and at least one labor item are required.");
    }
    // Validate receipt image for materials
    if (materialsCost > 0 && !receiptImageUrl) {
        throw new functions.https.HttpsError("invalid-argument", "Live receipt image is required when materials are charged.");
    }
    const jobRef = db.collection("jobs").doc(jobId);
    const jobDoc = await jobRef.get();
    if (!jobDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Job not found.");
    }
    const jobData = jobDoc.data();
    if (jobData.technicianId !== technicianId) {
        throw new functions.https.HttpsError("permission-denied", "This job is not assigned to you.");
    }
    if (jobData.status !== "inProgress") {
        throw new functions.https.HttpsError("failed-precondition", "Job must be in progress to submit an invoice.");
    }
    // Fetch server-side pricing to validate labor items
    const pricingDoc = await db
        .collection("pricing")
        .doc(jobData.serviceCategory)
        .get();
    if (!pricingDoc.exists) {
        throw new functions.https.HttpsError("internal", "Pricing data not found for this category.");
    }
    const pricingData = pricingDoc.data();
    const pricingItems = pricingData.items;
    // Build validated labor items using SERVER prices (not client-submitted)
    const validatedLaborItems = laborItemIds.map((itemId) => {
        const serverItem = pricingItems.find((p) => p.itemId === itemId);
        if (!serverItem) {
            throw new functions.https.HttpsError("invalid-argument", `Invalid labor item: ${itemId}`);
        }
        return {
            itemId: serverItem.itemId,
            name: serverItem.name,
            nameAr: serverItem.nameAr,
            fixedPrice: serverItem.fixedPrice,
        };
    });
    // Calculate totals server-side
    const totalLabor = validatedLaborItems.reduce((sum, item) => sum + item.fixedPrice, 0);
    const surgeMultiplier = jobData.surgeMultiplier || 1.0;
    const totalAmount = (totalLabor + (materialsCost || 0) - INSPECTION_FEE) * surgeMultiplier;
    const platformFee = totalLabor * PLATFORM_COMMISSION_RATE * surgeMultiplier;
    const needsApproval = (materialsCost || 0) > MATERIAL_APPROVAL_THRESHOLD;
    await jobRef.update({
        laborItems: validatedLaborItems,
        materialsCost: materialsCost || 0,
        receiptImageUrl: receiptImageUrl || null,
        totalAmount: Math.max(0, totalAmount),
        platformFee,
        status: "invoiced",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    functions.logger.info(`Invoice submitted for job ${jobId}: labor=${totalLabor}, materials=${materialsCost}, total=${totalAmount}`);
    return {
        success: true,
        jobId,
        totalAmount: Math.max(0, totalAmount),
        needsApproval,
    };
});
// ═══════════════════════════════════════════════════════════════════════
// APPROVE / REJECT INVOICE
// ═══════════════════════════════════════════════════════════════════════
/**
 * Customer approves the invoice and work begins / payment is processed.
 */
exports.approveInvoice = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    var _a, _b;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Not authenticated.");
    }
    const customerId = context.auth.uid;
    const { jobId, paymentMethod } = data;
    const jobRef = db.collection("jobs").doc(jobId);
    const jobDoc = await jobRef.get();
    if (!jobDoc.exists || ((_a = jobDoc.data()) === null || _a === void 0 ? void 0 : _a.customerId) !== customerId) {
        throw new functions.https.HttpsError("permission-denied", "Not your job.");
    }
    if (((_b = jobDoc.data()) === null || _b === void 0 ? void 0 : _b.status) !== "invoiced") {
        throw new functions.https.HttpsError("failed-precondition", "Invoice is not pending approval.");
    }
    await jobRef.update({
        status: "approved",
        paymentMethod: paymentMethod || "cash",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { success: true, jobId };
});
/**
 * Customer rejects the invoice. Triggers a re-negotiation flow.
 */
exports.rejectInvoice = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    var _a;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Not authenticated.");
    }
    const customerId = context.auth.uid;
    const { jobId, reason } = data;
    const jobRef = db.collection("jobs").doc(jobId);
    const jobDoc = await jobRef.get();
    if (!jobDoc.exists || ((_a = jobDoc.data()) === null || _a === void 0 ? void 0 : _a.customerId) !== customerId) {
        throw new functions.https.HttpsError("permission-denied", "Not your job.");
    }
    // Move back to in_progress for re-negotiation
    await jobRef.update({
        status: "inProgress",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    functions.logger.info(`Invoice rejected for job ${jobId}. Reason: ${reason || "Not specified"}`);
    return { success: true, jobId };
});
// ═══════════════════════════════════════════════════════════════════════
// CANCEL JOB
// ═══════════════════════════════════════════════════════════════════════
/**
 * Cancels a job with penalty logic based on timing and status.
 */
exports.cancelJob = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    var _a;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Not authenticated.");
    }
    const userId = context.auth.uid;
    const { jobId, reason } = data;
    const jobRef = db.collection("jobs").doc(jobId);
    const jobDoc = await jobRef.get();
    if (!jobDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Job not found.");
    }
    const jobData = jobDoc.data();
    const cancelableStatuses = [
        "searching", "accepted", "enRoute", "arrived", "invoiced",
    ];
    if (!cancelableStatuses.includes(jobData.status)) {
        throw new functions.https.HttpsError("failed-precondition", "Job cannot be cancelled in its current state.");
    }
    let penalty = 0;
    const isCustomer = jobData.customerId === userId;
    const isTech = jobData.technicianId === userId;
    if (isCustomer) {
        const acceptedAt = (_a = jobData.acceptedAt) === null || _a === void 0 ? void 0 : _a.toDate();
        const now = new Date();
        if (acceptedAt) {
            const elapsed = now.getTime() - acceptedAt.getTime();
            if (elapsed > CANCELLATION_GRACE_PERIOD_MS) {
                penalty = LATE_CANCELLATION_PENALTY;
            }
            // Full inspection fee if tech has arrived
            if (jobData.status === "arrived" || jobData.status === "invoiced") {
                penalty = INSPECTION_FEE;
            }
        }
    }
    const batch = db.batch();
    // Update job status
    batch.update(jobRef, {
        status: "cancelled",
        cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
        cancelledBy: userId,
        cancellationReason: reason || "No reason provided",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Apply penalty via wallet transactions if applicable
    if (penalty > 0 && isCustomer) {
        // Debit customer wallet
        const customerWalletRef = db.collection("wallets").doc(userId);
        batch.update(customerWalletRef, {
            balance: admin.firestore.FieldValue.increment(-penalty),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        // Log transaction
        const txRef = db.collection("transactions").doc();
        batch.set(txRef, {
            walletId: userId,
            userId,
            jobId,
            amount: -penalty,
            type: "penalty",
            description: `Late cancellation penalty for job ${jobId}`,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        // Compensate technician if assigned
        if (jobData.technicianId) {
            const techWalletRef = db
                .collection("wallets")
                .doc(jobData.technicianId);
            batch.update(techWalletRef, {
                balance: admin.firestore.FieldValue.increment(penalty),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            const techTxRef = db.collection("transactions").doc();
            batch.set(techTxRef, {
                walletId: jobData.technicianId,
                userId: jobData.technicianId,
                jobId,
                amount: penalty,
                type: "riskFundPayout",
                description: `Cancellation compensation for job ${jobId}`,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
    }
    await batch.commit();
    functions.logger.info(`Job ${jobId} cancelled by ${userId}. Penalty: ${penalty} EGP`);
    return { success: true, jobId, penalty };
});
// ═══════════════════════════════════════════════════════════════════════
// RATE JOB
// ═══════════════════════════════════════════════════════════════════════
/**
 * Customer rates the completed job with stars and optional review text.
 */
exports.rateJob = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    var _a, _b, _c;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Not authenticated.");
    }
    const customerId = context.auth.uid;
    const { jobId, rating, review } = data;
    if (!jobId || !rating || rating < 1 || rating > 5) {
        throw new functions.https.HttpsError("invalid-argument", "Job ID and rating (1-5) required.");
    }
    const jobRef = db.collection("jobs").doc(jobId);
    const jobDoc = await jobRef.get();
    if (!jobDoc.exists || ((_a = jobDoc.data()) === null || _a === void 0 ? void 0 : _a.customerId) !== customerId) {
        throw new functions.https.HttpsError("permission-denied", "Not your job.");
    }
    if (((_b = jobDoc.data()) === null || _b === void 0 ? void 0 : _b.status) !== "completed") {
        throw new functions.https.HttpsError("failed-precondition", "Job must be completed before rating.");
    }
    const technicianId = (_c = jobDoc.data()) === null || _c === void 0 ? void 0 : _c.technicianId;
    const batch = db.batch();
    // Update job with rating
    batch.update(jobRef, {
        rating,
        review: review || null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Update technician's average rating
    if (technicianId) {
        const techRef = db.collection("technician_profiles").doc(technicianId);
        const techDoc = await techRef.get();
        if (techDoc.exists) {
            const techData = techDoc.data();
            const currentTotal = techData.averageRating * techData.totalReviews;
            const newTotalReviews = techData.totalReviews + 1;
            const newAverage = (currentTotal + rating) / newTotalReviews;
            batch.update(techRef, {
                averageRating: Math.round(newAverage * 10) / 10,
                totalReviews: newTotalReviews,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
    }
    await batch.commit();
    functions.logger.info(`Job ${jobId} rated ${rating}/5 by ${customerId}`);
    return { success: true };
});
//# sourceMappingURL=job-functions.js.map