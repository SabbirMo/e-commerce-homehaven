import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;

  // Forgot Password method
  Future<void> resetPassword({required String email}) async {
    try {
      if (email.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar('Error', 'Please enter your email');
        });
        return;
      }

      isLoading = true;
      update();

      await _auth.sendPasswordResetEmail(email: email);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Success', 'Password reset email sent. Check your inbox.');
      });
    } on FirebaseAuthException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Error', e.message ?? 'Something went wrong');
      });
    } finally {
      isLoading = false;
      update();
    }
  }
}
