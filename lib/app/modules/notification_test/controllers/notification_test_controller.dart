import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/notification_service.dart';

class NotificationTestController extends GetxController {
  late NotificationService notificationService;

  @override
  void onInit() {
    super.onInit();
    notificationService = Get.find<NotificationService>();
  }

  Future<void> sendInstantNotification() async {
    try {
      await notificationService.showSimpleNotification();

      Get.snackbar(
        'Success',
        'Notification sent! Check your notification panel.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error: $e');

      Get.snackbar(
        'Error',
        'Failed to send notification: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> scheduleNotificationIn10Seconds() async {
    try {
      await notificationService.scheduleNotification(seconds: 10);

      Get.snackbar(
        'Scheduled! ⏰',
        'Notification will appear in 10 seconds!',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      print('❌ Error: $e');

      Get.snackbar(
        'Error',
        'Failed to schedule notification: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
