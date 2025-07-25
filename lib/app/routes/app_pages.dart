import 'package:get/get.dart';

import '../modules/donation/bindings/donation_binding.dart';
import '../modules/donation/views/donation_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/notification_test/bindings/notification_test_binding.dart';
import '../modules/notification_test/views/notification_test_view.dart';
import '../modules/prayer_times/bindings/prayer_times_binding.dart';
import '../modules/prayer_times/views/prayer_times_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.DONATION,
      page: () => const DonationView(),
      binding: DonationBinding(),
    ),
    GetPage(
      name: _Paths.PRAYER_TIMES,
      page: () => const PrayerTimesView(),
      binding: PrayerTimesBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION_TEST,
      page: () => const NotificationTestView(),
      binding: NotificationTestBinding(),
    ),
  ];
}
