import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  int currentIndex = 0;
  void onPageChange(int index) {
    currentIndex = index;
    update();
  }

  void nextPage() {
    if (currentIndex < 2) {
      pageController.nextPage(
          duration: Duration(seconds: 1), curve: Curves.easeInOut);
    }
    update();
  }

  void previousPage() {
    if (currentIndex > 0) {
      pageController.previousPage(
          duration: Duration(seconds: 1), curve: Curves.easeInOut);
    }
    update();
  }
}
