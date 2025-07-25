import 'package:get/get.dart';
import '../controllers/notification_test_controller.dart';
import '../../../services/notification_service.dart';

class NotificationTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NotificationService>(NotificationService());
    Get.lazyPut<NotificationTestController>(() => NotificationTestController());
  }
}
