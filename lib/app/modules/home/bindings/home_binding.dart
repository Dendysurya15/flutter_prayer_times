import 'package:get/get.dart';
import 'package:notif_donate/app/modules/donation/controllers/donation_controller.dart';
import 'package:notif_donate/app/modules/prayer_times/controllers/prayer_times_controller.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<PrayerTimesController>(() => PrayerTimesController());
    Get.lazyPut<DonationController>(() => DonationController());
  }
}
