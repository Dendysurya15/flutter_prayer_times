import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DonationController extends GetxController {
  var isProcessing = false.obs;

  void onDonatePressed() {
    // Show a simple message for now
    Get.snackbar(
      'Coming Soon',
      'Donation feature will be available soon!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
