import 'package:get/get.dart';
import 'package:notif_donate/app/data/models/prayer_times_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class PrayerTimesController extends GetxController {
  var isLoading = true.obs;
  var prayerTimes = Rxn<PrayerTimesModel>();
  var currentLocation = ''.obs;
  var nextPrayer = ''.obs;
  var nextPrayerTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getPrayerTimes();
  }

  Future<void> getPrayerTimes() async {
    try {
      isLoading(true);

      // Get location
      Position position = await getCurrentLocation();

      // Get city name from coordinates (optional)
      currentLocation.value = "Current Location";

      // Fetch prayer times
      final response = await http.get(
        Uri.parse(
          'https://api.aladhan.com/v1/timings?latitude=${position.latitude}&longitude=${position.longitude}&method=2',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print("data $data");
        prayerTimes.value = PrayerTimesModel.fromJson(data);
        calculateNextPrayer();
      } else {
        Get.snackbar('Error', 'Failed to fetch prayer times');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to get location or prayer times: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<Position> getCurrentLocation() async {
    // Request location permission
    var status = await Permission.location.request();

    if (status.isGranted) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      return await Geolocator.getCurrentPosition();
    } else {
      throw Exception('Location permission denied');
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

  void refreshPrayerTimes() {
    getPrayerTimes();
  }
}
