import 'package:get/get.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }

  void goToPrayerTimes() {
    selectedIndex.value = 0;
  }

  void goToDonation() {
    selectedIndex.value = 1;
  }
}
