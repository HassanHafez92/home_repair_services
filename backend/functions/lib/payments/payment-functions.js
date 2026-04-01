"use strict";
/**
 * Fixawy Platform — Payment Cloud Functions
 *
 * Handles:
 * - Payment processing (Paymob integration)
 * - Webhook handler for Paymob callbacks
 * - Commission calculation and wallet updates
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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
var _a, _b, _c, _d;
Object.defineProperty(exports, "__esModule", { value: true });
exports.handlePaymobWebhook = exports.processPayment = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const axios_1 = __importDefault(require("axios"));
const db = admin.firestore();
// ═══════════════════════════════════════════════════════════════════════
// PAYMOB CONFIGURATION
// ═══════════════════════════════════════════════════════════════════════
// These should be stored in Firebase Functions config in production
const PAYMOB_API_KEY = ((_a = functions.config().paymob) === null || _a === void 0 ? void 0 : _a.api_key) || "YOUR_PAYMOB_API_KEY";
const PAYMOB_INTEGRATION_ID = ((_b = functions.config().paymob) === null || _b === void 0 ? void 0 : _b.integration_id) || "YOUR_INTEGRATION_ID";
const PAYMOB_IFRAME_ID = ((_c = functions.config().paymob) === null || _c === void 0 ? void 0 : _c.iframe_id) || "YOUR_IFRAME_ID";
const PAYMOB_HMAC_SECRET = ((_d = functions.config().paymob) === null || _d === void 0 ? void 0 : _d.hmac_secret) || "YOUR_HMAC_SECRET";
const PAYMOB_BASE_URL = "https://accept.paymob.com/api";
const PLATFORM_COMMISSION_RATE = 0.15;
const RISK_FUND_CONTRIBUTION_RATE = 0.02; // 2% goes to risk fund
// ═══════════════════════════════════════════════════════════════════════
// PROCESS PAYMENT
// ═══════════════════════════════════════════════════════════════════════
/**
 * Initiates a payment via Paymob for a completed job.
 * Returns a payment token / URL for the customer to complete payment.
 */
exports.processPayment = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    var _a, _b;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Not authenticated.");
    }
    const customerId = context.auth.uid;
    const { jobId, paymentMethod } = data;
    if (!jobId) {
        throw new functions.https.HttpsError("invalid-argument", "Job ID required.");
    }
    const jobRef = db.collection("jobs").doc(jobId);
    const jobDoc = await jobRef.get();
    if (!jobDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Job not found.");
    }
    const jobData = jobDoc.data();
    if (jobData.customerId !== customerId) {
        throw new functions.https.HttpsError("permission-denied", "Not your job.");
    }
    if (jobData.status !== "approved" && jobData.status !== "completed") {
        throw new functions.https.HttpsError("failed-precondition", "Job must be approved or completed to process payment.");
    }
    // If cash payment, just mark as paid and process commission
    if (paymentMethod === "cash") {
        await processCashPayment(jobId, jobData);
        return { success: true, paymentMethod: "cash" };
    }
    // For electronic payment via Paymob
    try {
        // Step 1: Get authentication token
        const authResponse = await axios_1.default.post(`${PAYMOB_BASE_URL}/auth/tokens`, {
            api_key: PAYMOB_API_KEY,
        });
        const authToken = authResponse.data.token;
        // Step 2: Create order
        const orderResponse = await axios_1.default.post(`${PAYMOB_BASE_URL}/ecommerce/orders`, {
            auth_token: authToken,
            delivery_needed: false,
            amount_cents: Math.round(jobData.totalAmount * 100), // Convert to cents
            currency: "EGP",
            items: [
                {
                    name: `Fixawy Job #${jobId.substring(0, 8)}`,
                    amount_cents: Math.round(jobData.totalAmount * 100),
                    description: `${jobData.serviceCategory} service`,
                    quantity: 1,
                },
            ],
            merchant_order_id: jobId,
        });
        const orderId = orderResponse.data.id;
        // Step 3: Get payment key
        const customerDoc = await db.collection("users").doc(customerId).get();
        const customerData = customerDoc.data();
        const paymentKeyResponse = await axios_1.default.post(`${PAYMOB_BASE_URL}/acceptance/payment_keys`, {
            auth_token: authToken,
            amount_cents: Math.round(jobData.totalAmount * 100),
            expiration: 3600,
            order_id: orderId,
            billing_data: {
                first_name: ((_a = customerData === null || customerData === void 0 ? void 0 : customerData.displayName) === null || _a === void 0 ? void 0 : _a.split(" ")[0]) || "Customer",
                last_name: ((_b = customerData === null || customerData === void 0 ? void 0 : customerData.displayName) === null || _b === void 0 ? void 0 : _b.split(" ")[1]) || "Fixawy",
                email: (customerData === null || customerData === void 0 ? void 0 : customerData.email) || "customer@fixawy.com",
                phone_number: (customerData === null || customerData === void 0 ? void 0 : customerData.phone) || "+201000000000",
                apartment: "NA",
                floor: "NA",
                street: "NA",
                building: "NA",
                shipping_method: "NA",
                postal_code: "NA",
                city: "Cairo",
                country: "EG",
                state: "Cairo",
            },
            currency: "EGP",
            integration_id: parseInt(PAYMOB_INTEGRATION_ID),
        });
        const paymentToken = paymentKeyResponse.data.token;
        const iframeUrl = `https://accept.paymob.com/api/acceptance/iframes/${PAYMOB_IFRAME_ID}?payment_token=${paymentToken}`;
        // Update job with payment info
        await jobRef.update({
            paymentMethod,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        functions.logger.info(`Payment initiated for job ${jobId}, order ${orderId}`);
        return {
            success: true,
            paymentUrl: iframeUrl,
            paymentToken,
            orderId,
        };
    }
    catch (error) {
        functions.logger.error(`Payment processing error for job ${jobId}:`, error);
        throw new functions.https.HttpsError("internal", "Payment processing failed. Please try again.");
    }
});
// ═══════════════════════════════════════════════════════════════════════
// PAYMOB WEBHOOK HANDLER
// ═══════════════════════════════════════════════════════════════════════
/**
 * Handles Paymob payment callbacks (success, failure, etc.)
 */
exports.handlePaymobWebhook = functions
    .region("europe-west1")
    .https.onRequest(async (req, res) => {
    if (req.method !== "POST") {
        res.status(405).send("Method not allowed");
        return;
    }
    try {
        const { obj } = req.body;
        if (!obj) {
            res.status(400).send("Invalid webhook payload");
            return;
        }
        const { success, order, id: transactionId } = obj;
        const merchantOrderId = order === null || order === void 0 ? void 0 : order.merchant_order_id;
        if (!merchantOrderId) {
            res.status(400).send("Missing merchant order ID");
            return;
        }
        // TODO: Verify HMAC signature with PAYMOB_HMAC_SECRET for security
        const jobRef = db.collection("jobs").doc(merchantOrderId);
        const jobDoc = await jobRef.get();
        if (!jobDoc.exists) {
            functions.logger.error(`Webhook: Job not found for order ${merchantOrderId}`);
            res.status(404).send("Job not found");
            return;
        }
        if (success) {
            // Payment successful — process commission split
            const jobData = jobDoc.data();
            await processElectronicPayment(merchantOrderId, jobData, transactionId);
            functions.logger.info(`Payment successful for job ${merchantOrderId}, tx ${transactionId}`);
        }
        else {
            // Payment failed
            functions.logger.warn(`Payment failed for job ${merchantOrderId}, tx ${transactionId}`);
            await jobRef.update({
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        res.status(200).send("OK");
    }
    catch (error) {
        functions.logger.error("Webhook processing error:", error);
        res.status(500).send("Internal error");
    }
});
// ═══════════════════════════════════════════════════════════════════════
// INTERNAL HELPERS
// ═══════════════════════════════════════════════════════════════════════
/**
 * Processes cash payment: marks job as paid and handles commission.
 */
async function processCashPayment(jobId, jobData) {
    const batch = db.batch();
    const jobRef = db.collection("jobs").doc(jobId);
    const totalAmount = jobData.totalAmount;
    const platformFee = jobData.platformFee;
    const techEarning = totalAmount - platformFee;
    const riskFundContribution = platformFee * RISK_FUND_CONTRIBUTION_RATE;
    // Mark job as paid and completed
    batch.update(jobRef, {
        isPaid: true,
        paymentMethod: "cash",
        status: "completed",
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Technician collected cash — they owe the platform the commission
    // Decrease tech wallet by the platform fee (they keep the rest)
    if (jobData.technicianId) {
        const techWalletRef = db.collection("wallets").doc(jobData.technicianId);
        batch.update(techWalletRef, {
            balance: admin.firestore.FieldValue.increment(-platformFee),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        // Log commission deduction transaction
        const txRef = db.collection("transactions").doc();
        batch.set(txRef, {
            walletId: jobData.technicianId,
            userId: jobData.technicianId,
            jobId,
            amount: -platformFee,
            type: "commissionDeduction",
            description: `Commission for job ${jobId.substring(0, 8)} (cash)`,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        // Log earning transaction
        const earningTxRef = db.collection("transactions").doc();
        batch.set(earningTxRef, {
            walletId: jobData.technicianId,
            userId: jobData.technicianId,
            jobId,
            amount: techEarning,
            type: "earning",
            description: `Earning for job ${jobId.substring(0, 8)} (cash collected)`,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    }
    // Risk fund contribution
    const riskFundRef = db.collection("risk_fund").doc("main");
    batch.set(riskFundRef, {
        balance: admin.firestore.FieldValue.increment(riskFundContribution),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    await batch.commit();
}
/**
 * Processes electronic payment: marks job as paid and splits funds.
 */
async function processElectronicPayment(jobId, jobData, paymobTransactionId) {
    const batch = db.batch();
    const jobRef = db.collection("jobs").doc(jobId);
    const totalAmount = jobData.totalAmount;
    const platformFee = jobData.platformFee;
    const techEarning = totalAmount - platformFee;
    const riskFundContribution = platformFee * RISK_FUND_CONTRIBUTION_RATE;
    // Mark job as paid and completed
    batch.update(jobRef, {
        isPaid: true,
        status: "completed",
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Credit technician wallet with their earnings
    if (jobData.technicianId) {
        const techWalletRef = db.collection("wallets").doc(jobData.technicianId);
        batch.update(techWalletRef, {
            balance: admin.firestore.FieldValue.increment(techEarning),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        const txRef = db.collection("transactions").doc();
        batch.set(txRef, {
            walletId: jobData.technicianId,
            userId: jobData.technicianId,
            jobId,
            amount: techEarning,
            type: "earning",
            description: `Earning for job ${jobId.substring(0, 8)} (electronic)`,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    }
    // Risk fund contribution
    const riskFundRef = db.collection("risk_fund").doc("main");
    batch.set(riskFundRef, {
        balance: admin.firestore.FieldValue.increment(riskFundContribution),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    await batch.commit();
}
//# sourceMappingURL=payment-functions.js.map