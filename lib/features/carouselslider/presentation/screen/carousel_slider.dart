import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_haven/features/carouselslider/presentation/controller/carousel_slider_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:home_haven/core/assets/app_colors.dart';

class CarouselSliderScreen extends StatelessWidget {
  const CarouselSliderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyCarouselSliderController>(
      init: MyCarouselSliderController(),
      builder: (controller) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              // Enhanced Carousel Container
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Main Carousel
                      CarouselSlider.builder(
                        itemCount: controller.images.length,
                        itemBuilder: (context, index, realIndex) {
                          return _buildCarouselItem(controller, index);
                        },
                        options: CarouselOptions(
                          autoPlay: true,
                          height: 200,
                          viewportFraction: 1.0,
                          enlargeCenterPage: false,
                          autoPlayInterval: Duration(seconds: 4),
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 1000),
                          autoPlayCurve: Curves.easeInOutCubic,
                          pauseAutoPlayOnTouch: true,
                          onPageChanged: (index, reason) {
                            controller.onPageChange(index);
                          },
                        ),
                      ),

                      // Gradient Overlay for better text readability
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Content Overlay
                      Positioned(
                        bottom: 60,
                        left: 20,
                        right: 20,
                        child: _buildCarouselContent(controller),
                      ),

                      // Enhanced Page Indicator - Inside Carousel
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: _buildEnhancedIndicator(controller),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                  .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 800.ms,
                      curve: Curves.easeOutBack),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarouselItem(MyCarouselSliderController controller, int index) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with Hero Animation
          Hero(
            tag: 'carousel_$index',
            child: Image.asset(
              controller.images[index],
              fit: BoxFit.cover,
            ),
          ),

          // Subtle Overlay for Premium Look
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate(target: controller.activeIndex == index ? 1 : 0).scale(
          begin: Offset(0.95, 0.95),
          end: Offset(1.0, 1.0),
          duration: 600.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildCarouselContent(MyCarouselSliderController controller) {
    final titles = [
      'Premium Furniture Collection',
      'Modern Living Solutions',
      'Elegant Home Designs',
    ];

    final descriptions = [
      'Discover our exclusive range of premium furniture',
      'Transform your space with modern designs',
      'Create elegant living spaces with our collection',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titles[controller.activeIndex],
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(
            begin: -0.3, end: 0, duration: 500.ms, curve: Curves.easeOut),
        SizedBox(height: 8),
        Text(
          descriptions[controller.activeIndex],
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(
            begin: -0.3, end: 0, duration: 500.ms, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildEnhancedIndicator(MyCarouselSliderController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedSmoothIndicator(
        activeIndex: controller.activeIndex,
        count: controller.images.length,
        effect: ExpandingDotsEffect(
          dotHeight: 6,
          dotWidth: 6,
          spacing: 10,
          radius: 12,
          activeDotColor: Colors.white,
          dotColor: Colors.white.withValues(alpha: 0.4),
          expansionFactor: 2.5,
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 600.ms).scale(
          begin: Offset(0.8, 0.8),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }
}
