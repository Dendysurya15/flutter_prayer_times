import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notif_donate/app/modules/prayer_times/widgets/prayer_card.dart';

import '../controllers/prayer_times_controller.dart';

class PrayerTimesView extends GetView<PrayerTimesController> {
  const PrayerTimesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        title: const Text('Prayer Times'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshPrayerTimes,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
        }

        if (controller.prayerTimes.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Failed to load prayer times'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshPrayerTimes,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final prayerTimes = controller.prayerTimes.value!;
        final today = DateFormat('EEEE, MMMM d, y').format(DateTime.now());

        return RefreshIndicator(
          onRefresh: controller.getPrayerTimes,
          color: Colors.green,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Today's Prayer Times",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          today,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        if (controller.nextPrayer.value.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Next: ${controller.nextPrayer.value} at ${controller.nextPrayerTime.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Prayer Times List
                  PrayerCard(
                    prayerName: 'Fajr',
                    time: prayerTimes.fajr,
                    isNext: controller.nextPrayer.value == 'Fajr',
                    icon: Icons.brightness_2,
                  ),
                  const SizedBox(height: 12),
                  PrayerCard(
                    prayerName: 'Dhuhr',
                    time: prayerTimes.dhuhr,
                    isNext: controller.nextPrayer.value == 'Dhuhr',
                    icon: Icons.wb_sunny,
                  ),
                  const SizedBox(height: 12),
                  PrayerCard(
                    prayerName: 'Asr',
                    time: prayerTimes.asr,
                    isNext: controller.nextPrayer.value == 'Asr',
                    icon: Icons.wb_sunny_outlined,
                  ),
                  const SizedBox(height: 12),
                  PrayerCard(
                    prayerName: 'Maghrib',
                    time: prayerTimes.maghrib,
                    isNext: controller.nextPrayer.value == 'Maghrib',
                    icon: Icons.brightness_3,
                  ),
                  const SizedBox(height: 12),
                  PrayerCard(
                    prayerName: 'Isha',
                    time: prayerTimes.isha,
                    isNext: controller.nextPrayer.value == 'Isha',
                    icon: Icons.brightness_2_outlined,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
