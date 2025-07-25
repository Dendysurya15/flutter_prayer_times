import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Sound preference with SharedPreferences
  var soundEnabled = true.obs;
  late SharedPreferences _prefs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initPreferences();
    await _configureTimeZone();
    await initializeNotifications();
  }

  Future<void> _initPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      // Load saved sound preference (default: true)
      soundEnabled.value = _prefs.getBool('notification_sound_enabled') ?? true;
      print('🔊 Loaded sound preference: ${soundEnabled.value}');
    } catch (e) {
      print('❌ Error loading preferences: $e');
      soundEnabled.value = true; // Default to enabled
    }
  }

  Future<void> _saveSoundPreference(bool enabled) async {
    try {
      await _prefs.setBool('notification_sound_enabled', enabled);
      print('💾 Saved sound preference: $enabled');
    } catch (e) {
      print('❌ Error saving sound preference: $e');
    }
  }

  Future<void> _configureTimeZone() async {
    try {
      print('🌍 Initializing timezone...');
      tz.initializeTimeZones();

      try {
        final String timeZoneName = await FlutterTimezone.getLocalTimezone();
        print('🌍 Local timezone: $timeZoneName');
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        print('⚠️ Could not get local timezone, using UTC: $e');
        tz.setLocalLocation(tz.UTC);
      }

      print('✅ Timezone configured successfully');
    } catch (e) {
      print('❌ Timezone configuration failed: $e');
      // Fallback to UTC
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // Create notification channels
    await _createNotificationChannels();

    // Request permissions for scheduled notifications
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
  }

  Future<void> _createNotificationChannels() async {
    final simpleChannel = AndroidNotificationChannel(
      'simple_channel',
      'Simple Notifications',
      description: 'Basic notifications',
      importance: Importance.high,
      playSound: soundEnabled.value,
      enableVibration: true,
      showBadge: true,
    );

    final scheduledChannel = AndroidNotificationChannel(
      'scheduled_channel',
      'Scheduled Notifications',
      description: 'Notifications scheduled for future',
      importance: Importance.high,
      playSound: soundEnabled.value,
      enableVibration: true,
      showBadge: true,
    );

    final prayerChannel = AndroidNotificationChannel(
      'prayer_channel',
      'Prayer Times',
      description: 'Prayer time notifications',
      importance: Importance.max,
      playSound: soundEnabled.value,
      enableVibration: true,
      showBadge: true,
    );

    final reminderChannel = AndroidNotificationChannel(
      'reminder_channel',
      'Prayer Reminders',
      description: 'Prayer reminder notifications',
      importance: Importance.high,
      playSound: soundEnabled.value,
      enableVibration: true,
      showBadge: true,
    );

    final androidImpl =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(simpleChannel);
      await androidImpl.createNotificationChannel(scheduledChannel);
      await androidImpl.createNotificationChannel(prayerChannel);
      await androidImpl.createNotificationChannel(reminderChannel);
    }
  }

  // Simple notification for testing
  Future<void> showSimpleNotification() async {
    print('🔔 Sending simple notification...');
    print('🔊 Sound enabled: ${soundEnabled.value}');

    final androidDetails = AndroidNotificationDetails(
      'simple_channel',
      'Simple Notifications',
      channelDescription: 'Basic notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: soundEnabled.value,
      enableVibration: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: soundEnabled.value,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      'Test Notification',
      'This is a simple test notification! 🔔',
      notificationDetails,
    );

    print('✅ Simple notification sent!');
  }

  // REAL SCHEDULING - Works when app is closed!
  Future<void> scheduleNotification({required int seconds}) async {
    try {
      print('⏰ REAL scheduling notification for $seconds seconds from now...');
      print('🔊 Sound enabled: ${soundEnabled.value}');

      final scheduledTime = DateTime.now().add(Duration(seconds: seconds));

      // Convert to TZDateTime
      tz.TZDateTime scheduledTZTime;
      try {
        scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);
        print('🌍 Converted to TZ time: $scheduledTZTime');
      } catch (e) {
        print('⚠️ TZ conversion failed, retrying: $e');
        await _configureTimeZone();
        scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);
      }

      final androidDetails = AndroidNotificationDetails(
        'scheduled_channel',
        'Scheduled Notifications',
        channelDescription: 'Notifications scheduled for future',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: soundEnabled.value,
        enableVibration: true,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: soundEnabled.value,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        2, // Unique ID for test notifications
        'Scheduled Notification ⏰',
        'This notification was scheduled $seconds seconds ago! 🎉 (Works when app closed)',
        scheduledTZTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('✅ REAL notification scheduled for: $scheduledTZTime');
      print('🚀 This will work even if app is closed!');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      throw e;
    }
  }

  // REAL PRAYER NOTIFICATIONS - Work when app is closed!
  Future<void> schedulePrayerNotification({
    required int seconds,
    required String title,
    required String body,
  }) async {
    try {
      print(
        '🕌 REAL scheduling prayer notification: $title in $seconds seconds',
      );
      print('🔊 Sound enabled: ${soundEnabled.value}');

      final scheduledTime = DateTime.now().add(Duration(seconds: seconds));

      // Convert to TZDateTime
      tz.TZDateTime scheduledTZTime;
      try {
        scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);
      } catch (e) {
        await _configureTimeZone();
        scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);
      }

      final androidDetails = AndroidNotificationDetails(
        'prayer_channel',
        'Prayer Times',
        channelDescription: 'Prayer time notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: soundEnabled.value,
        enableVibration: true,
        ongoing: false,
        autoCancel: true,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: soundEnabled.value,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Generate unique ID based on time and prayer name
      final notificationId =
          (DateTime.now().millisecondsSinceEpoch % 100000) +
          (title.hashCode % 1000);

      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledTZTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print(
        '✅ REAL prayer notification scheduled: $title for $scheduledTZTime',
      );
      print('🚀 Will work even when app is closed!');
    } catch (e) {
      print('❌ Error scheduling prayer notification: $e');
      throw e;
    }
  }

  Future<void> scheduleReminderNotification({
    required int seconds,
    required String title,
    required String body,
  }) async {
    try {
      print(
        '⏰ REAL scheduling reminder notification: $title in $seconds seconds',
      );
      print('🔊 Sound enabled: ${soundEnabled.value}');

      final scheduledTime = DateTime.now().add(Duration(seconds: seconds));

      // Convert to TZDateTime
      tz.TZDateTime scheduledTZTime;
      try {
        scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);
      } catch (e) {
        await _configureTimeZone();
        scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);
      }

      final androidDetails = AndroidNotificationDetails(
        'reminder_channel',
        'Prayer Reminders',
        channelDescription: 'Prayer reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: soundEnabled.value,
        enableVibration: true,
        ongoing: false,
        autoCancel: true,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: soundEnabled.value,
        interruptionLevel: InterruptionLevel.active,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Generate unique ID based on time and reminder name
      final notificationId =
          (DateTime.now().millisecondsSinceEpoch % 100000) +
          (title.hashCode % 1000) +
          50000;

      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledTZTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print(
        '✅ REAL reminder notification scheduled: $title for $scheduledTZTime',
      );
      print('🚀 Will work even when app is closed!');
    } catch (e) {
      print('❌ Error scheduling reminder notification: $e');
      throw e;
    }
  }

  // Sound control methods with persistence
  Future<void> enableSound() async {
    soundEnabled.value = true;
    await _saveSoundPreference(true);
    await _recreateNotificationChannels();
    print('🔊 Sound enabled and saved');
    Get.snackbar(
      'Sound On',
      'Notification sounds are now enabled 🔊',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> disableSound() async {
    soundEnabled.value = false;
    await _saveSoundPreference(false);
    await _recreateNotificationChannels();
    print('🔇 Sound disabled and saved');
    Get.snackbar(
      'Sound Off',
      'Notification sounds are now disabled 🔇',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  Future<void> toggleSound() async {
    if (soundEnabled.value) {
      await disableSound();
    } else {
      await enableSound();
    }
  }

  Future<void> _recreateNotificationChannels() async {
    print(
      '🔄 Recreating notification channels with sound: ${soundEnabled.value}',
    );

    final androidImpl =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImpl != null) {
      try {
        await androidImpl.deleteNotificationChannel('simple_channel');
        await androidImpl.deleteNotificationChannel('scheduled_channel');
        await androidImpl.deleteNotificationChannel('prayer_channel');
        await androidImpl.deleteNotificationChannel('reminder_channel');
      } catch (e) {
        print('⚠️ Error deleting channels: $e');
      }
    }

    await _createNotificationChannels();
  }

  // Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('🗑️ All REAL scheduled notifications cancelled');
  }

  // Get pending notifications (now these will show real scheduled ones!)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Method to open app notification settings
  Future<void> openNotificationSettings() async {
    try {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      Get.snackbar(
        'Settings',
        'Opening notification settings...',
        backgroundColor: Colors.teal,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error opening settings: $e');
      Get.snackbar(
        'Error',
        'Could not open notification settings',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
