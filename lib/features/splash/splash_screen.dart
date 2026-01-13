import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_haven/core/assets/app_colors.dart';
import 'package:home_haven/core/assets/app_icons.dart';
import 'package:home_haven/core/router/app_routers.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  Future<void> _checkUserLoginStatus() async {
    // Show splash for at least 2 seconds
    await Future.delayed(Duration(seconds: 2));

    // Check if user is logged in
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // User is logged in, check if email is verified
      await currentUser.reload();
      currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser!.emailVerified) {
        // User is verified, check their role
        try {
          DocumentSnapshot doc = await FirebaseFirestore.instance
              .collection('auth')
              .doc(currentUser.uid)
              .get();

          if (doc.exists) {
            Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
            String role = userData['role'] ?? 'customer';

            print('User logged in with role: $role');

            // Check if user is admin - if yes, force logout for security
            if (role == 'admin') {
              print(
                  'Admin user detected - signing out for security, must login manually');
              await FirebaseAuth.instance.signOut();
              Get.offAllNamed(RouterConstant.onBoarding);
              return;
            }

            // For regular customers, allow auto-login
            print('Customer user detected - auto-login to main screen');
            Get.offAllNamed(RouterConstant.mainScreen);
          } else {
            // User document doesn't exist, treat as customer and allow auto-login
            print(
                'User document not found, treating as customer - navigating to main screen');
            Get.offAllNamed(RouterConstant.mainScreen);
          }
        } catch (firestoreError) {
          // Firestore error, but user is authenticated - treat as customer
          print('Firestore error: $firestoreError - treating as customer');
          Get.offAllNamed(RouterConstant.mainScreen);
        }
      } else {
        // Email not verified, sign out and go to onboarding
        print('Email not verified, signing out');
        await FirebaseAuth.instance.signOut();
        Get.offAllNamed(RouterConstant.onBoarding);
      }
    } else {
      // No user logged in, go to onboarding
      print('No user logged in, going to onboarding');
      Get.offAllNamed(RouterConstant.onBoarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.liner, AppColors.gradient],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AppIcons.homeSvg, width: 87, height: 87),
            const SizedBox(height: 15),
            Text(
              'HomeHaven',
              style: TextStyle(
                color: AppColors.neutral10,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            CircularProgressIndicator(
              color: AppColors.neutral10,
            ),
          ],
        ),
      ),
    );
  }
}
