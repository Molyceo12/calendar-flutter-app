const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Runs every 5 minutes to check for pending notifications
exports.triggerScheduledNotifications = functions.pubsub
    .schedule("every 5 minutes")
    .onRun(async (context) => {
      const now = admin.firestore.Timestamp.now();
      const notificationsRef = admin
          .firestore()
          .collection("scheduled_notifications");

      // Find notifications due to be sent
      const querySnapshot = await notificationsRef
          .where("scheduledTime", "<=", now)
          .where("triggered", "==", false)
          .limit(100) // Process max 100 at a time
          .get();

      const batch = admin.firestore().batch();
      const messagingPromises = [];

      for (const doc of querySnapshot.docs) {
        const notification = doc.data();

        try {
        // Get user's FCM token
          const userDoc = await admin
              .firestore()
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
                admin
                    .messaging()
                    .send(message)
                    .then(() => {
                      // Mark as triggered in batch
                      batch.update(doc.ref, {triggered: true});
                    })
                    .catch((error) => {
                      console.error(
                          `Failed to send to ${notification.userId}:`,
                          error,
                      );
                      // For transient errors, don't mark as triggered
                      if (
                        error.code ===
                          "messaging/registration-token-not-registered"
                      ) {
                        // Remove invalid token
                        batch.update(userDoc.ref, {fcmToken: null});
                      }
                    }),
            );
          } else {
          // No FCM token - mark as triggered to avoid retrying
            batch.update(doc.ref, {triggered: true});
          }
        } catch (error) {
          console.error(`Error processing ${doc.id}:`, error);
        }
      }

      // Wait for all messages to be processed
      await Promise.all(messagingPromises);

      // Commit all Firestore updates
      await batch.commit();

      return null;
    });
