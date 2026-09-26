const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendDistanceNotification = onDocumentCreated(
  "notification/{notificationId}",
  async (event) => {
    const data = event.data.data();

    if (!data) {
      return;
    }

    const message = {
      notification: {
        title: data.title || "Navigator",
        body: data.message || "100 metr yo‘l bosdingiz",
      },
      topic: "navigator",
    };

    await admin.messaging().send(message);

    console.log("FCM notification yuborildi");
  },
);