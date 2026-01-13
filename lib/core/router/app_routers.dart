import 'package:get/get.dart';
import 'package:home_haven/features/admin_dashboard/admin_dashboard.dart';
import 'package:home_haven/features/appliances/appliances_product_screen.dart';
import 'package:home_haven/features/auth/forgot/screen/forgot_password_screen.dart';
import 'package:home_haven/features/auth/login/binding/login_binding.dart';
import 'package:home_haven/features/auth/login/screen/login_screen.dart';
import 'package:home_haven/features/auth/registration/binding/registor_binding.dart';
import 'package:home_haven/features/auth/registration/screen/register_screen.dart';
import 'package:home_haven/features/furniture/screen/furniture_product_screen.dart';
import 'package:home_haven/features/home/presentation/screen/home_screen.dart';
import 'package:home_haven/features/home/presentation/binding/home_binding.dart';
import 'package:home_haven/features/product_details/screen/product_details_screen.dart';
import 'package:home_haven/features/bottom_navbar/screen/custom_bottom_navbar.dart';
import 'package:home_haven/features/onboarding/binding/onboarding_binding.dart';
import 'package:home_haven/features/onboarding/view/onboarding_screen.dart';
import 'package:home_haven/features/splash/splash_screen.dart';
import 'package:home_haven/features/checkout/screen/checkout_screen.dart';
import 'package:home_haven/features/products/screen/all_products_screen.dart';
import 'package:home_haven/features/outdoor/screen/outdoor_products_screen.dart';
import 'package:home_haven/features/special_offers/special_offers_screen.dart';
import 'package:home_haven/features/orders/screen/customer_order_screen.dart';

class AppRouters {
  static final appRouters = [
    GetPage(name: RouterConstant.splach, page: () => SplashScreen()),
    GetPage(
      name: RouterConstant.onBoarding,
      page: () => OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: RouterConstant.loginScreen,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: RouterConstant.registorScreen,
      page: () => RegisterScreen(),
      binding: RegistorBinding(),
    ),
    GetPage(
      name: RouterConstant.forgotPassword,
      page: () => ForgotPasswordScreen(),
    ),
    GetPage(
      name: RouterConstant.homeScreen,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: RouterConstant.mainScreen,
      page: () => CustomBottomNavbar(),
    ),
    GetPage(
      name: RouterConstant.adminDashboard,
      page: () => AdminDashboard(),
    ),
    GetPage(
      name: RouterConstant.productDetails,
      page: () => ProductDetailsScreen(
        product: Get.arguments,
      ),
    ),
    GetPage(
      name: RouterConstant.checkout,
      page: () => CheckoutScreen(),
    ),
    GetPage(
      name: RouterConstant.allProducts,
      page: () => AllProductsScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: RouterConstant.outdoorProducts,
      page: () => OutdoorProductsScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: RouterConstant.furnitureProducts,
      page: () => FurnitureProductScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: RouterConstant.appliancesProducts,
      page: () => AppliancesProductScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: RouterConstant.specialOffers,
      page: () => SpecialOffersScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: RouterConstant.customerOrders,
      page: () => CustomerOrderScreen(),
    ),
  ];
}

class RouterConstant {
  static final splach = '/';
  static final onBoarding = '/onBoarding';
  static final loginScreen = '/loginScreen';
  static final registorScreen = '/registorScreen';
  static final forgotPassword = '/forgotPassword';
  static final homeScreen = '/homeScreen';
  static final mainScreen = '/mainScreen';
  static final adminDashboard = '/adminDashboard';
  static final productDetails = '/productDetails';
  static final checkout = '/checkout';
  static final allProducts = '/allProducts';
  static final outdoorProducts = '/outdoorProducts';
  static final furnitureProducts = '/furnitureProducts';
  static final appliancesProducts = '/appliancesProducts';
  static final specialOffers = '/specialOffers';
  static final customerOrders = '/customerOrders';
}
