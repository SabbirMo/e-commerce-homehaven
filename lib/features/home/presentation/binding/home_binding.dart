import 'package:get/get.dart';
import 'package:home_haven/features/home/presentation/controller/home_controller.dart';
import 'package:home_haven/features/wishlist/controller/wishlist_controller.dart';
import 'package:home_haven/features/cart/controller/cart_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<WishlistController>(() => WishlistController());
    Get.lazyPut<CartController>(() => CartController());
  }
}
