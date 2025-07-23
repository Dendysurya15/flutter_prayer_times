import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DonationController extends GetxController {
  var donationAmount = 0.0.obs;
  var isProcessing = false.obs;
  var selectedDonationType = 'one-time'.obs;

  final List<double> quickAmounts = [10.0, 25.0, 50.0, 100.0, 250.0, 500.0];

  void onDonatePressed() {
    Get.snackbar(
      'Coming Soon',
      'Donation feature will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void setDonationAmount(double amount) {
    donationAmount.value = amount;
  }

  void setDonationType(String type) {
    selectedDonationType.value = type;
  }

  Future<void> processDonation() async {
    isProcessing(true);
    await Future.delayed(const Duration(seconds: 2));
    isProcessing(false);
  }
}
