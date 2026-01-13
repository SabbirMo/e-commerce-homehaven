import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  bool hidenPassword = true;
  void showPassword() {
    hidenPassword = !hidenPassword;
    update();
  }

  bool hidenConfirmPassword = true;
  void showConfirmPassword() {
    hidenConfirmPassword = !hidenConfirmPassword;
    update();
  }

  String adminEmail = "sabbirsamolla51@gmail.com";

  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;

  Future<void> registorUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Check if this is the admin email and set role accordingly
      String userRole = "customer"; // Default role
      if (email.trim().toLowerCase() == adminEmail.toLowerCase()) {
        userRole = "admin";
      }

      isLoading = true;
      update();

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = credential.user;

      if (user != null && !credential.user!.emailVerified) {
        await credential.user!.sendEmailVerification();
        // Use WidgetsBinding to show snackbar after frame is built

        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text('Verification Email sent to $email'),
          ),
        );
      }

      await _firestore.collection('auth').doc(user!.uid).set({
        'uid': user!.uid,
        'name': name,
        'email': email,
        'role': userRole, // Use the determined role
        'createAt': DateTime.now(),
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
