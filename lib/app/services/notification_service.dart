import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'dart:async';

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

  // Schedule test notification using Timer
  Timer? _scheduledTimer;

  Future<void> scheduleNotification({required int seconds}) async {
    try {
      print(
        '⏰ Scheduling notification for $seconds seconds from now using Timer...',
      );
      print('🔊 Sound enabled: ${soundEnabled.value}');

      // Cancel any existing timer
      _scheduledTimer?.cancel();

      // Create a timer that will fire the notification
      _scheduledTimer = Timer(Duration(seconds: seconds), () async {
        print('🔔 Timer fired! Sending scheduled notification...');

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

        await _notifications.show(
          2,
          'Scheduled Notification ⏰',
          'This notification was scheduled $seconds seconds ago! 🎉',
          notificationDetails,
        );

        print('✅ Scheduled notification sent!');
      });

      print('✅ Timer scheduled successfully for $seconds seconds');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      throw e;
    }
  }

  // Prayer notification methods
  Future<void> schedulePrayerNotification({
    required int seconds,
    required String title,
    required String body,
  }) async {
    try {
      print('🕌 Scheduling prayer notification: $title in $seconds seconds');
      print('🔊 Sound enabled: ${soundEnabled.value}');

      Timer(Duration(seconds: seconds), () async {
        print('🔔 Prayer time! Sending: $title');

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

        await _notifications.show(
          DateTime.now().millisecondsSinceEpoch % 10000,
          title,
          body,
          notificationDetails,
        );

        print('✅ Prayer notification sent: $title');
      });

      print('✅ Prayer notification scheduled successfully');
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
      print('⏰ Scheduling reminder notification: $title in $seconds seconds');
      print('🔊 Sound enabled: ${soundEnabled.value}');

      Timer(Duration(seconds: seconds), () async {
        print('🔔 Reminder time! Sending: $title');

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

        await _notifications.show(
          DateTime.now().millisecondsSinceEpoch % 10000,
          title,
          body,
          notificationDetails,
        );

        print('✅ Reminder notification sent: $title');
      });

      print('✅ Reminder notification scheduled successfully');
    } catch (e) {
      print('❌ Error scheduling reminder notification: $e');
      throw e;
    }
  }

  // Sound control methods with persistence
  Future<void> enableSound() async {
    soundEnabled.value = true;
    await _saveSoundPreference(true);
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

  // Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    _scheduledTimer?.cancel();
    await _notifications.cancelAll();
    print('🗑️ All notifications and timers cancelled');
  }

  // Method to open app notification settings
  Future<void> openNotificationSettings() async {
    try {
      // This opens the app's notification settings page
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
