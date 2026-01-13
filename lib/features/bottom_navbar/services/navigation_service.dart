import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_haven/features/bottom_navbar/controller/navigation_controller.dart';
import 'package:home_haven/features/bottom_navbar/widget/custom_bottom_navbar.dart';
import 'package:home_haven/features/cart/my_cart_screen.dart';
import 'package:home_haven/features/cart/controller/cart_controller.dart';
import 'package:home_haven/features/home/presentation/screen/home_screen.dart';
import 'package:home_haven/features/home/presentation/controller/home_controller.dart';
import 'package:home_haven/features/wishlist/controller/wishlist_controller.dart';
import 'package:home_haven/features/profile/profile_screen.dart';

class GlobalNavigationWrapper extends StatelessWidget {
  final Widget child;
  final bool showBottomNav;
  
  const GlobalNavigationWrapper({
    super.key,
    required this.child,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBottomNav) {
      return child;
    }

    final NavigationController controller = Get.put(NavigationController());
    // Initialize controllers
    Get.put(HomeController());
    Get.put(CartController());
    Get.put(WishlistController());

    final pages = [HomeScreen(), MyCartScreen(), ProfileScreen()];

    return Obx(
      () => Scaffold(
        backgroundColor: Colors.grey[50],
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: CustomNavbar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
        extendBody: true,
      ),
    );
  }
}

// Enhanced navigation service
class NavigationService {
  static void navigateToPage(Widget page, {bool showBottomNav = false}) {
    if (showBottomNav) {
      Get.to(() => GlobalNavigationWrapper(
        child: page,
        showBottomNav: true,
      ));
    } else {
      Get.to(() => page);
    }
  }
  
  static void navigateToPageWithBottomNav(Widget page) {
    navigateToPage(page, showBottomNav: true);
  }
}