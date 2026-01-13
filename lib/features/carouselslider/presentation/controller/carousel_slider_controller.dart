import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyCarouselSliderController extends GetxController {
  final CarouselController carouselController = CarouselController();
  int activeIndex = 0;

  final images = [
    'assets/images/carousel1.png',
    'assets/images/carousel2.jpg',
    'assets/images/carousel3.jpg',
  ];

  void onPageChange(int index) {
    activeIndex = index;
    update();
  }
}
