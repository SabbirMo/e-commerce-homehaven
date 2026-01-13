import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_haven/core/assets/app_colors.dart';
import 'package:home_haven/core/assets/app_image.dart';
import 'package:home_haven/features/auth/login/screen/login_screen.dart';
import 'package:home_haven/features/onboarding/controller/onboarding_controller.dart';
import 'package:home_haven/features/onboarding/widget/custom_button.dart';
import 'package:home_haven/features/onboarding/widget/custom_onboarding.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GetBuilder<OnboardingController>(
        builder: (_) => Stack(
          children: [
            PageView(
              controller: controller.pageController,
              onPageChanged: (value) => controller.onPageChange(value),
              children: [
                CustomOnboarding(
                  image: AppImage.onBoard1,
                  name: "Online Home Store \nand Furniture",
                  description:
                      "Discover all style and budgets of furniture, appliances, kitchen, and more from 500+ brands in your hand.",
                ),
                CustomOnboarding(
                  image: AppImage.onBoard2,
                  name: "Delivery Right to Your Doorstep",
                  description:
                      "Sit back, and enjoy the convenience of our drivers delivering your order to your doorstep.",
                ),
                CustomOnboarding(
                  image: AppImage.onBoard3,
                  name: "Get Support From Our Skilled Team",
                  description:
                      "If our products don't meet your expectations, we're available 24/7 to assist you.",
                )
              ],
            ),
            Container(
              alignment: Alignment(0, 0.69),
              child: SmoothPageIndicator(
                controller: controller.pageController,
                count: 3,
                effect: WormEffect(
                  activeDotColor: AppColors.primary,
                ),
              ),
            ),
            Positioned(
              bottom: 35,
              left: 15,
              right: 15,
              child: controller.currentIndex == 0
                  ? CustomButton(text: "Next", onTap: controller.nextPage)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (controller.currentIndex > 0)
                          ElevatedButton(
                            onPressed: controller.previousPage,
                            child: Text(
                              "Back",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        CustomButton(
                          width: size.width * .55,
                          text: "Next",
                          onTap: () {
                            controller.currentIndex == 2
                                ? Get.offAll(() => LoginScreen())
                                : controller.nextPage();
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
