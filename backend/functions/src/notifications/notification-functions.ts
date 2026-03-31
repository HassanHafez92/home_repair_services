/**
 * Fixawy Platform — Notification Cloud Functions
 *
 * Handles:
 * - Sending FCM push notifications
 * - Automatic notifications on job status changes (Firestore trigger)
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Sends a push notification to a specific user via FCM.
 */
export const sendPushNotification = functions
  .region("europe-west1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Not authenticated.");
    }

    const { userId, title, titleAr, body, bodyAr, type, jobId, metadata } = data;

    if (!userId || !title || !body) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "userId, title, and body are required."
      );
    }

    // Get user's FCM token
    const userDoc = await db.collection("users").doc(userId).get();

    if (!userDoc.exists) {
      throw new functions.https.HttpsError("not-found", "User not found.");
    }

    const fcmToken = userDoc.data()?.fcmToken;

    // Store notification in Firestore regardless of FCM token
    const notifRef = db.collection("notifications").doc();
    await notifRef.set({
      userId,
      title,
      titleAr: titleAr || title,
      body,
      bodyAr: bodyAr || body,
      type: type || "general",
      jobId: jobId || null,
      isRead: false,
      metadata: metadata || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Send FCM push if token exists
    if (fcmToken) {
      try {
        await admin.messaging().send({
          token: fcmToken,
          notification: {
            title,
            body,
          },
          data: {
            type: type || "general",
            jobId: jobId || "",
            notificationId: notifRef.id,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          android: {
            priority: "high",
            notification: {
              channelId: "fixawy_notifications",
              priority: "high",
              defaultSound: true,
              defaultVibrateTimings: true,
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
              },
            },
          },
        });

        functions.logger.info(`Push notification sent to ${userId}`);
      } catch (error) {
        functions.logger.warn(
          `Failed to send push to ${userId}. Token may be invalid.`,
          error
        );

        // Clear invalid token
        await db.collection("users").doc(userId).update({
          fcmToken: null,
        });
      }
    }

    return { success: true, notificationId: notifRef.id };
  });

/**
 * Firestore trigger: Automatically sends notifications when job status changes.
 */
export const onJobStatusChange = functions
  .region("europe-west1")
  .firestore.document("jobs/{jobId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const jobId = context.params.jobId;

    // Only trigger on status change
    if (before.status === after.status) {
      return;
    }

    const newStatus = after.status;
    const customerId = after.customerId;
    const technicianId = after.technicianId;

    // Notification configs for each status transition
    const notificationMap: Record<
      string,
      {
        userId: string;
        title: string;
        titleAr: string;
        body: string;
        bodyAr: string;
        type: string;
      }
    > = {
      accepted: {
        userId: customerId,
        title: "Technician Found!",
        titleAr: "تم إيجاد فني!",
        body: "A technician has accepted your request and is on the way.",
        bodyAr: "فني قبل طلبك و في الطريق إليك.",
        type: "jobAccepted",
      },
      enRoute: {
        userId: customerId,
        title: "Technician En Route",
        titleAr: "الفني في الطريق",
        body: "Your technician is heading to your location.",
        bodyAr: "الفني في الطريق إلى موقعك.",
        type: "techEnRoute",
      },
      arrived: {
        userId: customerId,
        title: "Technician Arrived",
        titleAr: "الفني وصل",
        body: "Your technician has arrived at the location.",
        bodyAr: "الفني وصل عندك.",
        type: "techArrived",
      },
      invoiced: {
        userId: customerId,
        title: "Invoice Ready",
        titleAr: "الفاتورة جاهزة",
        body: "Please review and approve the service invoice.",
        bodyAr: "من فضلك راجع الفاتورة ووافق عليها.",
        type: "invoiceSent",
      },
      approved: {
        userId: technicianId || "",
        title: "Invoice Approved",
        titleAr: "الفاتورة تمت الموافقة عليها",
        body: "The customer has approved the invoice.",
        bodyAr: "العميل وافق على الفاتورة.",
        type: "invoiceApproved",
      },
      completed: {
        userId: customerId,
        title: "Job Completed",
        titleAr: "الخدمة اكتملت",
        body: "Your service has been completed. Please rate your experience.",
        bodyAr: "الخدمة اكتملت. من فضلك قيّم تجربتك.",
        type: "jobCompleted",
      },
      disputed: {
        userId: customerId,
        title: "Job Disputed",
        titleAr: "تم فتح نزاع",
        body: "A dispute has been opened for this job. An admin will review.",
        bodyAr: "تم فتح نزاع لهذه الخدمة. واحد من الإدارة هيراجعها.",
        type: "disputeOpened",
      },
      cancelled: {
        userId: technicianId || customerId,
        title: "Job Cancelled",
        titleAr: "تم إلغاء الخدمة",
        body: "The job has been cancelled.",
        bodyAr: "الخدمة اتلغت.",
        type: "cancellationNotice",
      },
    };

    const notifConfig = notificationMap[newStatus];

    if (notifConfig && notifConfig.userId) {
      // Get user's FCM token
      const userDoc = await db.collection("users").doc(notifConfig.userId).get();
      const fcmToken = userDoc.data()?.fcmToken;

      // Store notification
      const notifRef = db.collection("notifications").doc();
      await notifRef.set({
        userId: notifConfig.userId,
        title: notifConfig.title,
        titleAr: notifConfig.titleAr,
        body: notifConfig.body,
        bodyAr: notifConfig.bodyAr,
        type: notifConfig.type,
        jobId,
        isRead: false,
        metadata: null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Send FCM push
      if (fcmToken) {
        try {
          await admin.messaging().send({
            token: fcmToken,
            notification: {
              title: notifConfig.title,
              body: notifConfig.body,
            },
            data: {
              type: notifConfig.type,
              jobId,
              click_action: "FLUTTER_NOTIFICATION_CLICK",
            },
            android: {
              priority: "high",
              notification: {
                channelId: "fixawy_notifications",
                priority: "high",
                defaultSound: true,
              },
            },
          });
        } catch (error) {
          functions.logger.warn(
            `Failed to send auto-notification to ${notifConfig.userId}`,
            error
          );
        }
      }
    }

    functions.logger.info(
      `Job ${jobId} status changed: ${before.status} → ${newStatus}`
    );
  });
