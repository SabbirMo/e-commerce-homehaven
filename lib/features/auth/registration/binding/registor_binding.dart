import 'package:get/get.dart';
import 'package:home_haven/features/auth/registration/controller/register_controller.dart';

class RegistorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
  }
}
