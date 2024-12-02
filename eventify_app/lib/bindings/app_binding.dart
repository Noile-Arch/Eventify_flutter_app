import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/event_controller.dart';
import '../controllers/bottomnav_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(EventController(), permanent: true);
    Get.put(BottomNavController(), permanent: true);
  }
} 