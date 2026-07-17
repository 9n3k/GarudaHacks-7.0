import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    // Android 13+ permission
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> dangerNotification() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'danger_alert',

      'Danger Alerts',

      description: 'Vehicle danger detection warnings',

      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'danger_alert',

          'Danger Alerts',

          channelDescription: 'Vehicle danger detection warnings',

          importance: Importance.max,

          priority: Priority.high,

          playSound: true,

          enableVibration: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      999,

      '⚠️ Vehicle Detected',

      'Move away from the road immediately',

      details,
    );
  }
}
