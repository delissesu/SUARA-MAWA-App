import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static AndroidNotificationChannel createChannel({
    required String id,
    required String name,
    required Importance importance,
    required String description,
    required String soundName,
  }) {
    return AndroidNotificationChannel(
      id,
      name,
      description: description,
      importance: importance,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(soundName),
    );
  }

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'report_urgent';
  static const String _channelName = 'Importance Reports';
  static const String _channelDescription = 'Notification for reports that has max importance';
  static final AndroidNotificationChannel _channel = createChannel(
    id: _channelId,
    name: _channelName,
    importance: Importance.max,
    description: _channelDescription,
    soundName: 'notif',
  );

  static final AndroidNotificationChannel _channel2 = createChannel(
    id: 'report_general',
    name: 'General Reports',
    importance: Importance.defaultImportance,
    description: 'Notification for reports that has moderate importance',
    soundName: 'notif',
  );

  static Future<void> initialize() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
    );

    await _plugin.initialize(settings: initializationSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
      await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel2);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      // Note for Android 8 (API<26) we didn't need to specify others attribut.
      // Because its already defined by the channel, so we just need to use channelName.
      // Also for 26+ once channel defined, it cant be changed so it wont overwrite it
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notif_imut'),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: id, // Use the same id will overwrite the notification
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
}
