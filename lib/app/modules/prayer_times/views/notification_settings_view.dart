import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/prayer_times_controller.dart';

class NotificationSettingsView extends GetView<PrayerTimesController> {
  const NotificationSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enable/Disable Notifications
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.notifications, color: Colors.green),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Prayer Notifications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Get notified for each prayer time',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => Switch(
                        value: controller.isNotificationEnabled,
                        onChanged: controller.toggleNotifications,
                        activeColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Reminder Time Setting
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule, color: Colors.green),
                        const SizedBox(width: 16),
                        const Text(
                          'Reminder Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'How many minutes before prayer time should we remind you?',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => Column(
                        children:
                            [5, 10, 15, 20, 30]
                                .map(
                                  (minutes) => RadioListTile<int>(
                                    title: Text('$minutes minutes before'),
                                    value: minutes,
                                    groupValue: controller.reminderMinutes,
                                    onChanged: (value) {
                                      if (value != null) {
                                        controller.setReminderTime(value);
                                      }
                                    },
                                    activeColor: Colors.green,
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
