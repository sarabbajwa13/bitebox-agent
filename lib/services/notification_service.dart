import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/app_config.dart';
import '../models/order.dart';

/// Background me aaye FCM messages ka handler (top-level hona zaroori hai).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // App band/background me push OS khud dikhata hai (notification payload).
  // Yahan sirf ensure karte hain ki handler registered hai.
}

/// Local notifications + FCM ka wrapper.
///
/// - App khuli ho: Firestore listener naya order detect karke [showNewOrder]
///   call karta hai (loud heads-up + sound).
/// - App band/background: FCM push (Cloud Function se — Phase 3) OS dikhata hai.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'new_orders',
    'New orders',
    description: 'Alerts when a new order arrives',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> init() async {
    // ---- Local notifications ----
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _local.initialize(settings: initSettings);
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // ---- FCM permission + foreground handling ----
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // App khuli ho aur push aaye → khud local notification dikhao.
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

  /// Naya order aane par heads-up notification + sound.
  Future<void> showNewOrder(AgentOrder order) async {
    await _show(
      title: 'New order · ${AppConfig.currencySymbol}${order.total.toStringAsFixed(0)}',
      body: '${order.customerName} · ${order.totalQuantity} items',
      id: order.id.hashCode,
    );
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
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          category: AndroidNotificationCategory.call,
        ),
      ),
    );
  }
}
