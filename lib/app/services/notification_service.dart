import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'dart:typed_data'; // Add this import for Int64List
import '../data/models/prayer_times_model.dart';

class NotificationService extends GetxService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  var isNotificationEnabled = true.obs;
  var reminderMinutes = 10.obs; // 10 minutes before prayer time

  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeNotifications();
    await _configureTimeZone();
  }

  Future<void> initializeNotifications() async {
    // Android initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
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

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request notification permissions for iOS
    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Request notification permissions for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> _configureTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
    // Navigate to prayer times screen or show specific prayer info
    Get.toNamed('/home'); // Navigate to home when notification is tapped
  }

  Future<void> schedulePrayerNotifications(PrayerTimesModel prayerTimes) async {
    if (!isNotificationEnabled.value) return;

    // Cancel all existing notifications first
    await cancelAllNotifications();

    final prayers = [
      {'name': 'Fajr', 'time': prayerTimes.fajr},
      {'name': 'Dhuhr', 'time': prayerTimes.dhuhr},
      {'name': 'Asr', 'time': prayerTimes.asr},
      {'name': 'Maghrib', 'time': prayerTimes.maghrib},
      {'name': 'Isha', 'time': prayerTimes.isha},
    ];

    final now = DateTime.now();

    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      final prayerTime = _parseTimeToday(prayer['time']!);

      // Skip if prayer time has already passed today
      if (prayerTime.isBefore(now)) {
        // Schedule for tomorrow
        final tomorrowPrayerTime = prayerTime.add(const Duration(days: 1));
        await _scheduleNotification(
          id: i * 2, // Even IDs for prayer time notifications
          title: '🕌 ${prayer['name']} Prayer Time',
          body:
              'It\'s time for ${prayer['name']} prayer. May Allah accept your prayers.',
          scheduledTime: tomorrowPrayerTime,
          payload: 'prayer_${prayer['name']?.toLowerCase()}',
        );

        // Schedule reminder notification (10 minutes before)
        final reminderTime = tomorrowPrayerTime.subtract(
          Duration(minutes: reminderMinutes.value),
        );
        if (reminderTime.isAfter(now)) {
          await _scheduleNotification(
            id: i * 2 + 1, // Odd IDs for reminder notifications
            title: '⏰ ${prayer['name']} Prayer Reminder',
            body:
                '${prayer['name']} prayer in ${reminderMinutes.value} minutes. Please prepare for prayer.',
            scheduledTime: reminderTime,
            payload: 'reminder_${prayer['name']?.toLowerCase()}',
          );
        }
      } else {
        // Schedule for today
        await _scheduleNotification(
          id: i * 2,
          title: '🕌 ${prayer['name']} Prayer Time',
          body:
              'It\'s time for ${prayer['name']} prayer. May Allah accept your prayers.',
          scheduledTime: prayerTime,
          payload: 'prayer_${prayer['name']?.toLowerCase()}',
        );

        // Schedule reminder notification (10 minutes before)
        final reminderTime = prayerTime.subtract(
          Duration(minutes: reminderMinutes.value),
        );
        if (reminderTime.isAfter(now)) {
          await _scheduleNotification(
            id: i * 2 + 1,
            title: '⏰ ${prayer['name']} Prayer Reminder',
            body:
                '${prayer['name']} prayer in ${reminderMinutes.value} minutes. Please prepare for prayer.',
            scheduledTime: reminderTime,
            payload: 'reminder_${prayer['name']?.toLowerCase()}',
          );
        }
      }
    }

    Get.snackbar(
      'Notifications Scheduled',
      'Prayer time notifications have been set up successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Define vibration pattern outside const
    final vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

    final androidDetails = AndroidNotificationDetails(
      'prayer_times_channel',
      'Prayer Times',
      channelDescription: 'Notifications for prayer times and reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: const RawResourceAndroidNotificationSound(
        'adhan',
      ), // You can add custom sound
      enableVibration: true,
      vibrationPattern: vibrationPattern, // Now it works!
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'adhan.caf', // You can add custom sound
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Try this version without UILocalNotificationDateInterpretation
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Remove this line if still causing issues
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print('Notification scheduled: $title at $scheduledTime');
  }

  DateTime _parseTimeToday(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('All notifications cancelled');
  }

  Future<void> toggleNotifications(bool enabled) async {
    isNotificationEnabled.value = enabled;
    if (!enabled) {
      await cancelAllNotifications();
      Get.snackbar(
        'Notifications Disabled',
        'Prayer time notifications have been turned off',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Notifications Enabled',
        'Please refresh prayer times to schedule notifications',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void setReminderMinutes(int minutes) {
    reminderMinutes.value = minutes;
    Get.snackbar(
      'Reminder Updated',
      'Prayer reminders will now be sent $minutes minutes before prayer time',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
