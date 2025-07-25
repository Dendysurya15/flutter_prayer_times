import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import '../../../data/models/prayer_times_model.dart';
import '../../../services/notification_service.dart';

class PrayerTimesController extends GetxController {
  var isLoading = true.obs;
  var prayerTimes = Rxn<PrayerTimesModel>();
  var currentLocation = ''.obs;
  var nextPrayer = ''.obs;
  var nextPrayerTime = ''.obs;

  // Get notification service instance
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  @override
  void onInit() {
    super.onInit();
    getPrayerTimes();
  }

  Future<void> getPrayerTimes() async {
    try {
      isLoading(true);

      // Try to get location
      try {
        Position position = await getCurrentLocation();
        currentLocation.value = "Current Location";

        // Fetch prayer times using coordinates
        final response = await http.get(
          Uri.parse(
            'https://api.aladhan.com/v1/timings?latitude=${position.latitude}&longitude=${position.longitude}&method=2',
          ),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          prayerTimes.value = PrayerTimesModel.fromJson(data);
          calculateNextPrayer();

          // 🕌 SCHEDULE REAL PRAYER NOTIFICATIONS
          await _scheduleAllPrayerNotifications();
        } else {
          Get.snackbar('Error', 'Failed to fetch prayer times');
        }
      } catch (locationError) {
        // If location fails, use default location (Jakarta, Indonesia as fallback)
        print('Location error: $locationError');
        await getPrayerTimesByCity('Jakarta', 'Indonesia');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get prayer times. Please check your internet connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<Position> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Show dialog to enable location services
        Get.dialog(
          AlertDialog(
            title: const Text('Location Services Disabled'),
            content: const Text(
              'Please enable location services to get prayer times for your area.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Get.back();
                  await Geolocator.openLocationSettings();
                },
                child: const Text('Settings'),
              ),
            ],
          ),
        );
        throw Exception('Location services are disabled');
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Show manual location input dialog
          _showManualLocationDialog();
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, show dialog to go to settings
        Get.dialog(
          AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'Location permission is permanently denied. Please enable it in app settings to get accurate prayer times for your location.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  _showManualLocationDialog();
                },
                child: const Text('Enter Manually'),
              ),
              TextButton(
                onPressed: () async {
                  Get.back();
                  await Geolocator.openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position with timeout and accuracy settings
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Location error: $e');
      rethrow;
    }
  }

  void _showManualLocationDialog() {
    final TextEditingController cityController = TextEditingController();
    final TextEditingController countryController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Enter Your Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your city and country to get prayer times:'),
            const SizedBox(height: 16),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                hintText: 'e.g., Jakarta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: countryController,
              decoration: const InputDecoration(
                labelText: 'Country',
                hintText: 'e.g., Indonesia',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (cityController.text.isNotEmpty &&
                  countryController.text.isNotEmpty) {
                Get.back();
                getPrayerTimesByCity(
                  cityController.text,
                  countryController.text,
                );
              } else {
                Get.snackbar('Error', 'Please enter both city and country');
              }
            },
            child: const Text('Get Prayer Times'),
          ),
        ],
      ),
    );
  }

  Future<void> getPrayerTimesByCity(String city, String country) async {
    try {
      isLoading(true);
      currentLocation.value = "$city, $country";

      final response = await http.get(
        Uri.parse(
          'https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=2',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        prayerTimes.value = PrayerTimesModel.fromJson(data);
        calculateNextPrayer();

        // 🕌 SCHEDULE REAL PRAYER NOTIFICATIONS
        await _scheduleAllPrayerNotifications();

        Get.snackbar(
          'Success',
          'Prayer times loaded for $city, $country',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', 'Failed to fetch prayer times for this location');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to get prayer times: $e');
    } finally {
      isLoading(false);
    }
  }

  void calculateNextPrayer() {
    if (prayerTimes.value == null) return;

    final now = DateTime.now();
    final prayers = [
      {'name': 'Fajr', 'time': prayerTimes.value!.fajr},
      {'name': 'Dhuhr', 'time': prayerTimes.value!.dhuhr},
      {'name': 'Asr', 'time': prayerTimes.value!.asr},
      {'name': 'Maghrib', 'time': prayerTimes.value!.maghrib},
      {'name': 'Isha', 'time': prayerTimes.value!.isha},
    ];

    for (var prayer in prayers) {
      final prayerTime = DateTime.parse(
        '${now.toString().substring(0, 10)} ${prayer['time']}',
      );
      if (prayerTime.isAfter(now)) {
        nextPrayer.value = prayer['name']!;
        nextPrayerTime.value = prayer['time']!;
        break;
      }
    }

    if (nextPrayer.value.isEmpty) {
      nextPrayer.value = 'Fajr';
      nextPrayerTime.value = prayers[0]['time']!;
    }
  }

  // 🕌 SCHEDULE ALL PRAYER NOTIFICATIONS
  Future<void> _scheduleAllPrayerNotifications() async {
    if (prayerTimes.value == null) return;

    try {
      print('🕌 Scheduling all prayer notifications...');

      // Cancel any existing notifications first
      await _notificationService.cancelAllNotifications();

      final now = DateTime.now();
      final prayers = [
        {'name': 'Fajr', 'time': prayerTimes.value!.fajr, 'emoji': '🌅'},
        {'name': 'Dhuhr', 'time': prayerTimes.value!.dhuhr, 'emoji': '☀️'},
        {'name': 'Asr', 'time': prayerTimes.value!.asr, 'emoji': '🌤️'},
        {'name': 'Maghrib', 'time': prayerTimes.value!.maghrib, 'emoji': '🌅'},
        {'name': 'Isha', 'time': prayerTimes.value!.isha, 'emoji': '🌙'},
      ];

      int scheduledCount = 0;

      for (int i = 0; i < prayers.length; i++) {
        final prayer = prayers[i];
        final prayerTimeString = prayer['time']!;

        // Parse prayer time for today
        final prayerTime = _parseTimeToday(prayerTimeString);
        print('📿 Processing ${prayer['name']}: $prayerTime');

        // Determine target time (today or tomorrow)
        DateTime targetPrayerTime;
        if (prayerTime.isBefore(now)) {
          targetPrayerTime = prayerTime.add(const Duration(days: 1));
          print(
            '   ⏭️ Prayer time passed today, scheduling for tomorrow: $targetPrayerTime',
          );
        } else {
          targetPrayerTime = prayerTime;
          print('   ✅ Prayer time is today: $targetPrayerTime');
        }

        // Calculate seconds until prayer time
        final secondsUntilPrayer = targetPrayerTime.difference(now).inSeconds;

        if (secondsUntilPrayer > 0) {
          // Schedule prayer time notification
          await _schedulePrayerNotification(
            seconds: secondsUntilPrayer,
            title: '${prayer['emoji']} ${prayer['name']} Prayer Time',
            body:
                'It\'s time for ${prayer['name']} prayer. May Allah accept your prayers. 🤲',
          );
          scheduledCount++;
          print(
            '   🔔 Scheduled prayer notification in $secondsUntilPrayer seconds',
          );

          // Schedule reminder (10 minutes before)
          const reminderMinutes = 10;
          final reminderSeconds = secondsUntilPrayer - (reminderMinutes * 60);

          if (reminderSeconds > 0) {
            await _scheduleReminderNotification(
              seconds: reminderSeconds,
              title: '⏰ ${prayer['name']} Prayer Reminder',
              body:
                  '${prayer['name']} prayer in $reminderMinutes minutes. Please prepare for prayer. 🕌',
            );
            scheduledCount++;
            print('   ⏰ Scheduled reminder in $reminderSeconds seconds');
          } else {
            print('   ⚠️ Reminder time has passed, skipping reminder');
          }
        } else {
          print('   ⚠️ Prayer time has passed, skipping');
        }
      }

      print('✅ All prayer notifications scheduled! Total: $scheduledCount');
    } catch (e) {
      print('❌ Error scheduling prayer notifications: $e');
      Get.snackbar(
        'Error',
        'Failed to schedule prayer notifications: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Helper method to parse time string to DateTime for today
  DateTime _parseTimeToday(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // Schedule prayer time notification
  Future<void> _schedulePrayerNotification({
    required int seconds,
    required String title,
    required String body,
  }) async {
    await _notificationService.schedulePrayerNotification(
      seconds: seconds,
      title: title,
      body: body,
    );
  }

  // Schedule reminder notification
  Future<void> _scheduleReminderNotification({
    required int seconds,
    required String title,
    required String body,
  }) async {
    await _notificationService.scheduleReminderNotification(
      seconds: seconds,
      title: title,
      body: body,
    );
  }

  void refreshPrayerTimes() {
    getPrayerTimes();
  }

  // Simple method to test notification from prayer times page
  Future<void> testNotification() async {
    await _notificationService.showSimpleNotification();
  }

  // Method to manually reschedule notifications
  Future<void> rescheduleNotifications() async {
    if (prayerTimes.value != null) {
      await _scheduleAllPrayerNotifications();
    }
  }
}
