/**
 * BiteBox Cloud Functions.
 *
 * Jab client app naya order Firestore me likhta hai (orders/{id}), ye function
 * us store ke saare FCM device tokens pe ek push **notification** bhejta hai.
 * OS is notification ko foreground/background/**killed** sab me dikha deta hai —
 * saath me sound (channel "new_orders").
 */
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

exports.notifyStoreOnNewOrder = onDocumentCreated(
    "orders/{orderId}",
    async (event) => {
      const snap = event.data;
      if (!snap) return;
      const order = snap.data() || {};

      const storeId = order.storeId;
      if (!storeId) return;

      // Sirf naye (pending) orders pe notify karo.
      if (order.status && order.status !== "pending") return;

      // Store ke FCM tokens le aao.
      const db = getFirestore();
      const storeSnap = await db.collection("stores").doc(storeId).get();
      const tokens = ((storeSnap.data() || {}).fcmTokens || [])
          .filter((t) => typeof t === "string" && t.length > 0);
      if (tokens.length === 0) {
        console.log(`No FCM tokens for store ${storeId}`);
        return;
      }

      const total = order.total || 0;
      const items = order.items || [];
      const itemsCount = items.reduce(
          (sum, i) => sum + (i.quantity || 0), 0);
      const customer = order.customerName || "Customer";

      const message = {
        tokens: tokens,
        notification: {
          title: `New order · ₹${total}`,
          body: `${customer} · ${itemsCount} item(s)`,
        },
        data: {
          type: "new_order",
          orderId: event.params.orderId,
        },
        android: {
          priority: "high",
          notification: {
            // MainActivity.kt me isi channel me custom sound set hai.
            channelId: "bitebox_orders",
            // Android <8 (no channels) ke liye raw sound; O+ pe channel wins.
            sound: "notification_sound",
            priority: "high",
            defaultVibrateTimings: true,
          },
        },
      };

      const resp = await getMessaging().sendEachForMulticast(message);
      console.log(
          `Sent to ${tokens.length} token(s): ` +
        `${resp.successCount} ok, ${resp.failureCount} failed`);

      // Invalid/expired tokens hata do (cleanup).
      const invalid = [];
      resp.responses.forEach((r, idx) => {
        if (!r.success) {
          const code = r.error && r.error.code;
          if (
            code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token" ||
          code === "messaging/invalid-argument"
          ) {
            invalid.push(tokens[idx]);
          }
        }
      });
      if (invalid.length > 0) {
        await db.collection("stores").doc(storeId).update({
          fcmTokens: FieldValue.arrayRemove(...invalid),
        });
        console.log(`Removed ${invalid.length} invalid token(s)`);
      }
    },
);
