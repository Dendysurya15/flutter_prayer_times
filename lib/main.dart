import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:notif_donate/app/services/notification_service.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await Get.putAsync(() async {
    final service = NotificationService();
    await service.onInit(); // Call onInit manually
    return service;
  });

  runApp(
    GetMaterialApp(
      title: "Prayer Times App",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
    ),
  );
}
