// functions/index.js
const { onCall } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { setGlobalOptions } = require("firebase-functions/v2");
const { onUserCreated } = require("firebase-functions/v2/identity"); // ✅ CORRECTED: Changed from /v2/auth to /v2/identity
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

setGlobalOptions({ maxInstances: 10 });

// Scheduled function (runs every 5 minutes)
exports.triggerScheduledNotifications = onSchedule(
  { schedule: "every 5 minutes", timeZone: "UTC" },
  async (event) => {
    const now = admin.firestore.Timestamp.now();
    const notificationsRef = db.collection("scheduled_notifications");

    const querySnapshot = await notificationsRef
      .where("scheduledTime", "<=", now)
      .where("triggered", "==", false)
      .limit(100)
      .get();

    const batch = db.batch();
    const messagingPromises = [];

    for (const doc of querySnapshot.docs) {
      const notification = doc.data();

      try {
        const userDoc = await db
          .collection("users")
          .doc(notification.userId)
          .get();

        if (userDoc.exists && userDoc.data().fcmToken) {
          const message = {
            token: userDoc.data().fcmToken,
            notification: {
              title: notification.title,
              body: notification.body,
            },
            data: {
              eventId: notification.eventId,
              click_action: "FLUTTER_NOTIFICATION_CLICK",
              type: "event_reminder",
            },
            android: {
              priority: "high",
              notification: {
                channelId: "event_reminders",
                sound: "default",
              },
            },
            apns: {
              payload: {
                aps: {
                  sound: "default",
                },
              },
            },
          };

          messagingPromises.push(
            messaging
              .send(message)
              .then(() => batch.update(doc.ref, { triggered: true }))
              .catch((error) => {
                console.error(
                  `Failed to send to ${notification.userId}:`,
                  error
                );
                if (
                  error.code === "messaging/registration-token-not-registered"
                ) {
                  batch.update(userDoc.ref, { fcmToken: null });
                }
              })
          );
        } else {
          batch.update(doc.ref, { triggered: true });
        }
      } catch (error) {
        console.error(`Error processing ${doc.id}:`, error);
      }
    }

    await Promise.all(messagingPromises);
    await batch.commit();

    return { success: true };
  }
);

// Callable function to send login notification
exports.sendLoginNotification = onCall(async (req) => {
  const { userId } = req.data;
  if (!userId) {
    throw new Error("Missing userId");
  }

  const devicesSnapshot = await db
    .collection("users")
    .doc(userId)
    .collection("devices")
    .get();
  const tokens = devicesSnapshot.docs
    .map((doc) => doc.data().fcmToken)
    .filter((token) => token);

  if (tokens.length === 0) {
    console.log(`No device tokens found for user ${userId}`);
    return { success: false, message: "No device tokens found" };
  }

  const message = {
    notification: {
      title: "Login Alert",
      body: "You have successfully logged in.",
    },
    tokens,
    android: {
      priority: "high",
      notification: { channelId: "login_notifications", sound: "default" },
    },
    apns: { payload: { aps: { sound: "default" } } },
  };

  const response = await messaging.sendMulticast(message);
  console.log(
    `Login notification sent to user ${userId} with success count: ${response.successCount}`
  );

  return { success: true, message: "Login notification sent" };
});

// Callable function to trigger scheduled notifications manually
exports.triggerScheduledNotificationsNow = onCall(async () => {
  try {
    const now = admin.firestore.Timestamp.now();
    const notificationsRef = db.collection("scheduled_notifications");

    const querySnapshot = await notificationsRef
      .where("scheduledTime", "<=", now)
      .where("triggered", "==", false)
      .limit(100)
      .get();

    const batch = db.batch();
    const messagingPromises = [];

    for (const doc of querySnapshot.docs) {
      const notification = doc.data();

      try {
        const userDoc = await db
          .collection("users")
          .doc(notification.userId)
          .get();

        if (userDoc.exists && userDoc.data().fcmToken) {
          const message = {
            token: userDoc.data().fcmToken,
            notification: {
              title: notification.title,
              body: notification.body,
            },
            data: {
              eventId: notification.eventId,
              click_action: "FLUTTER_NOTIFICATION_CLICK",
              type: "event_reminder",
            },
            android: {
              priority: "high",
              notification: { channelId: "event_reminders", sound: "default" },
            },
            apns: { payload: { aps: { sound: "default" } } },
          };

          messagingPromises.push(
            messaging
              .send(message)
              .then(() => batch.update(doc.ref, { triggered: true }))
              .catch((error) => {
                console.error(
                  `Failed to send to ${notification.userId}:`,
                  error
                );
                if (
                  error.code === "messaging/registration-token-not-registered"
                ) {
                  batch.update(userDoc.ref, { fcmToken: null });
                }
              })
          );
        } else {
          batch.update(doc.ref, { triggered: true });
        }
      } catch (error) {
        console.error(`Error processing ${doc.id}:`, error);
      }
    }

    await Promise.all(messagingPromises);
    await batch.commit();

    return { success: true };
  } catch (error) {
    console.error("Error triggering scheduled notifications:", error);
    return { success: false, message: error.message };
  }
});

// Example usage of onUserCreated (if you need it)
// exports.onUserRegistered = onUserCreated((event) => {
//   const user = event.data;
//   console.log(`New user created: ${user.uid}`);
//   // Add your user creation logic here
//   return null;
// });
