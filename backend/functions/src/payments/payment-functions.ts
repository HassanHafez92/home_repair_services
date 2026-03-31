/**
 * Fixawy Platform — Payment Cloud Functions
 *
 * Handles:
 * - Payment processing (Paymob integration)
 * - Webhook handler for Paymob callbacks
 * - Commission calculation and wallet updates
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";

const db = admin.firestore();

// ═══════════════════════════════════════════════════════════════════════
// PAYMOB CONFIGURATION
// ═══════════════════════════════════════════════════════════════════════
// These should be stored in Firebase Functions config in production
const PAYMOB_API_KEY = functions.config().paymob?.api_key || "YOUR_PAYMOB_API_KEY";
const PAYMOB_INTEGRATION_ID = functions.config().paymob?.integration_id || "YOUR_INTEGRATION_ID";
const PAYMOB_IFRAME_ID = functions.config().paymob?.iframe_id || "YOUR_IFRAME_ID";
const PAYMOB_HMAC_SECRET = functions.config().paymob?.hmac_secret || "YOUR_HMAC_SECRET";
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
export const processPayment = functions
  .region("europe-west1")
  .https.onCall(async (data, context) => {
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

    const jobData = jobDoc.data()!;

    if (jobData.customerId !== customerId) {
      throw new functions.https.HttpsError("permission-denied", "Not your job.");
    }

    if (jobData.status !== "approved" && jobData.status !== "completed") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Job must be approved or completed to process payment."
      );
    }

    // If cash payment, just mark as paid and process commission
    if (paymentMethod === "cash") {
      await processCashPayment(jobId, jobData);
      return { success: true, paymentMethod: "cash" };
    }

    // For electronic payment via Paymob
    try {
      // Step 1: Get authentication token
      const authResponse = await axios.post(`${PAYMOB_BASE_URL}/auth/tokens`, {
        api_key: PAYMOB_API_KEY,
      });
      const authToken = authResponse.data.token;

      // Step 2: Create order
      const orderResponse = await axios.post(
        `${PAYMOB_BASE_URL}/ecommerce/orders`,
        {
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
        }
      );
      const orderId = orderResponse.data.id;

      // Step 3: Get payment key
      const customerDoc = await db.collection("users").doc(customerId).get();
      const customerData = customerDoc.data();

      const paymentKeyResponse = await axios.post(
        `${PAYMOB_BASE_URL}/acceptance/payment_keys`,
        {
          auth_token: authToken,
          amount_cents: Math.round(jobData.totalAmount * 100),
          expiration: 3600,
          order_id: orderId,
          billing_data: {
            first_name: customerData?.displayName?.split(" ")[0] || "Customer",
            last_name: customerData?.displayName?.split(" ")[1] || "Fixawy",
            email: customerData?.email || "customer@fixawy.com",
            phone_number: customerData?.phone || "+201000000000",
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
        }
      );

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
    } catch (error) {
      functions.logger.error(`Payment processing error for job ${jobId}:`, error);
      throw new functions.https.HttpsError(
        "internal",
        "Payment processing failed. Please try again."
      );
    }
  });

// ═══════════════════════════════════════════════════════════════════════
// PAYMOB WEBHOOK HANDLER
// ═══════════════════════════════════════════════════════════════════════

/**
 * Handles Paymob payment callbacks (success, failure, etc.)
 */
export const handlePaymobWebhook = functions
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
      const merchantOrderId = order?.merchant_order_id;

      if (!merchantOrderId) {
        res.status(400).send("Missing merchant order ID");
        return;
      }

      // TODO: Verify HMAC signature with PAYMOB_HMAC_SECRET for security

      const jobRef = db.collection("jobs").doc(merchantOrderId);
      const jobDoc = await jobRef.get();

      if (!jobDoc.exists) {
        functions.logger.error(
          `Webhook: Job not found for order ${merchantOrderId}`
        );
        res.status(404).send("Job not found");
        return;
      }

      if (success) {
        // Payment successful — process commission split
        const jobData = jobDoc.data()!;
        await processElectronicPayment(merchantOrderId, jobData, transactionId);

        functions.logger.info(
          `Payment successful for job ${merchantOrderId}, tx ${transactionId}`
        );
      } else {
        // Payment failed
        functions.logger.warn(
          `Payment failed for job ${merchantOrderId}, tx ${transactionId}`
        );

        await jobRef.update({
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      res.status(200).send("OK");
    } catch (error) {
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
async function processCashPayment(
  jobId: string,
  jobData: FirebaseFirestore.DocumentData
): Promise<void> {
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
  batch.set(
    riskFundRef,
    {
      balance: admin.firestore.FieldValue.increment(riskFundContribution),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  await batch.commit();
}

/**
 * Processes electronic payment: marks job as paid and splits funds.
 */
async function processElectronicPayment(
  jobId: string,
  jobData: FirebaseFirestore.DocumentData,
  paymobTransactionId: string
): Promise<void> {
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
  batch.set(
    riskFundRef,
    {
      balance: admin.firestore.FieldValue.increment(riskFundContribution),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  await batch.commit();
}
