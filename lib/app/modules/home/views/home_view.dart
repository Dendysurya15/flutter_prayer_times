import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notif_donate/app/modules/donation/views/donation_view.dart';
import 'package:notif_donate/app/modules/prayer_times/views/prayer_times_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.selectedIndex.value == 0 ? 'Prayer Times' : 'Donation',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        actions: [
          // Test Notification Button
          IconButton(
            onPressed: () {
              Get.toNamed('/notification-test');
            },
            icon: const Icon(Icons.bug_report),
            tooltip: 'Test Notifications',
          ),
          // Optional: Settings or more options
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'test':
                  Get.toNamed('/notification-test');
                  break;
                case 'settings':
                  // Navigate to settings if you have one
                  Get.snackbar(
                    'Info',
                    'Settings page not implemented yet',
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                  );
                  break;
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'test',
                    child: Row(
                      children: [
                        Icon(Icons.notifications, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Test Notifications'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: const [PrayerTimesView(), DonationView()],
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTabIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          elevation: 8,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time),
              label: 'Prayer Times',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism),
              label: 'Donation',
            ),
          ],
        ),
      ),
    );
  }
}
