import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    const channel = AndroidNotificationChannel(
      'distance_channel',
      'Distance notifications',
      description: 'Notifications for every 100 meters',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showDistanceNotification(
      double distance,
      ) async {
    await _notifications.show(
      distance.toInt(),
      'Navigator',
      'Siz ${(distance / 1000).toStringAsFixed(2)} km yurdingiz',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'distance_channel',
          'Distance notifications',
          channelDescription:
          'Notifications for every 100 meters',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}