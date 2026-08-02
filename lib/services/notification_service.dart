import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Background me aaye FCM messages ka handler (top-level hona zaroori hai).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Notification-payload wale messages ko OS khud dikhata hai (background/killed).
  // Yahan sirf handler registered rakhte hain.
}

/// FCM + local notifications wrapper.
///
/// Notifications ka **channel + custom sound natively MainActivity.kt me** banta
/// hai (id: `bitebox_orders`, sound: raw/notification_sound.mp3). Yahan bas usi
/// channel id ko reference karte hain:
///  - Foreground: `onMessage` par local notification dikhate hain.
///  - Background/killed: FCM notification-payload OS khud dikhata hai (usi channel
///    ka custom sound bajta hai).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// MainActivity.kt me isi id ka channel custom sound ke saath banaya jaata hai.
  static const String channelId = 'bitebox_orders';

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> init() async {
    // Local notifications init (channel yahan nahi banate — native banata hai).
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _local.initialize(settings: initSettings);

    // FCM permission + foreground handling.
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      final n = message.notification;
      _show(
        title: n?.title ?? 'New order',
        body: n?.body ?? 'You have a new order',
        id: message.messageId.hashCode,
      );
    });

    try {
      _fcmToken = await messaging.getToken();
    } catch (_) {
      _fcmToken = null;
    }
  }

  Future<void> _show({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await _local.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'New orders',
          channelDescription: 'Alerts when a new order arrives',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          // Channel ka custom sound (native) primary hai; ye foreground/older
          // Android ke liye explicit fallback.
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          enableVibration: true,
        ),
      ),
    );
  }
}
