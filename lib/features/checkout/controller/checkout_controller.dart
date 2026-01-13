import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_haven/features/checkout/model/checkout_model.dart';
import 'package:home_haven/features/cart/controller/cart_controller.dart';
import 'package:home_haven/features/bottom_navbar/controller/navigation_controller.dart';

class CheckoutController extends GetxController {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipCodeController = TextEditingController();
  final countryController = TextEditingController();
  final specialInstructionsController = TextEditingController();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Payment method selection
  var selectedPaymentMethod = 'cod'.obs;

  // Loading state
  var isProcessingOrder = false.obs;
  var isLoadingUserData = true.obs;

  // Available payment methods
  final paymentMethods = [
    {'id': 'cod', 'name': 'Cash on Delivery', 'icon': Icons.local_shipping},
    {'id': 'card', 'name': 'Credit/Debit Card', 'icon': Icons.credit_card},
    {
      'id': 'wallet',
      'name': 'Digital Wallet',
      'icon': Icons.account_balance_wallet
    },
  ];

  @override
  void onInit() {
    super.onInit();
    // Set default country
    countryController.text = 'Bangladesh';
    // Fetch user data
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      isLoadingUserData.value = true;

      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Try to get user data from Firestore first
        try {
          DocumentSnapshot userDoc =
              await _firestore.collection('auth').doc(currentUser.uid).get();

          if (userDoc.exists) {
            Map<String, dynamic> userData =
                userDoc.data() as Map<String, dynamic>;

            // Pre-fill form with user data from Firestore
            fullNameController.text =
                userData['name'] ?? currentUser.displayName ?? '';
            emailController.text = userData['email'] ?? currentUser.email ?? '';
            // Note: Allow user to edit name and email if they want to use different info
          } else {
            // Fallback to Firebase Auth data
            fullNameController.text = currentUser.displayName ?? '';
            emailController.text = currentUser.email ?? '';
          }
        } catch (firestoreError) {
          // If Firestore fails, use Firebase Auth data
          fullNameController.text = currentUser.displayName ?? '';
          emailController.text = currentUser.email ?? '';
          print(
              'Using Firebase Auth data due to Firestore error: $firestoreError');
        }

        // Check if we have phone number from Firebase Auth (usually null unless using phone auth)
        if (currentUser.phoneNumber != null &&
            currentUser.phoneNumber!.isNotEmpty) {
          phoneController.text = currentUser.phoneNumber!;
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      Get.snackbar(
        'Warning',
        'Could not load user information. Please fill the form manually.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } finally {
      isLoadingUserData.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose controllers
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    countryController.dispose();
    specialInstructionsController.dispose();
    super.onClose();
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Remove any non-numeric characters for validation
    String cleanPhone = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length < 10) {
      return 'Please enter a valid phone number (at least 10 digits)';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (value.length < 10) {
      return 'Please enter a complete address';
    }
    return null;
  }

  String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }
    return null;
  }

  String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'State is required';
    }
    return null;
  }

  String? validateZipCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'ZIP code is required';
    }
    if (value.length < 4) {
      return 'Please enter a valid ZIP code';
    }
    return null;
  }

  Future<void> processOrder() async {
    // Check if cart is empty
    final cartController = Get.find<CartController>();
    if (cartController.cartItems.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Please add items to your cart before checkout',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'Error',
        'Please fill in all required fields correctly',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isProcessingOrder.value = true;

    try {
      // Create checkout model
      final checkoutData = CheckoutModel(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        zipCode: zipCodeController.text.trim(),
        country: countryController.text.trim(),
        paymentMethod: selectedPaymentMethod.value,
        specialInstructions: specialInstructionsController.text.trim().isEmpty
            ? null
            : specialInstructionsController.text.trim(),
      );

      // Get cart controller
      // Note: Already retrieved above for validation

      // Show loading state and process order
      Get.snackbar(
        'Processing Order',
        'Please wait while we process your order...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );

      // Simulate order processing delay
      await Future.delayed(Duration(seconds: 1));

      // Create order in Firebase
      String orderId =
          await _createOrderInFirebase(checkoutData, cartController);

      Get.snackbar(
        'Order Placed Successfully!',
        'Your order #${orderId.substring(0, 8)} has been placed and will be delivered soon',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      // Clear cart after successful order
      cartController.cartItems.clear();

      // Navigate back to home tab via bottom navigation
      try {
        final NavigationController navController =
            Get.find<NavigationController>();
        navController.changeTab(0); // Switch to home tab
        Get.back(); // Close checkout screen
      } catch (e) {
        // If navigation controller not found, just go back
        Get.back();
        Get.back();
      }
    } catch (e) {
      print('Error in processOrder: $e');
      Get.snackbar(
        'Error',
        'Failed to process order: ${e.toString()}. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isProcessingOrder.value = false;
    }
  }

  // Calculate delivery fee based on payment method
  double get deliveryFee {
    switch (selectedPaymentMethod.value) {
      case 'cod':
        return 50.0; // COD fee
      case 'card':
        return 30.0; // Card payment delivery fee
      case 'wallet':
        return 25.0; // Digital wallet delivery fee
      default:
        return 50.0;
    }
  }

  // Get payment method display name
  String get paymentMethodName {
    final method = paymentMethods.firstWhere(
      (method) => method['id'] == selectedPaymentMethod.value,
      orElse: () => {'name': 'Cash on Delivery'},
    );
    return method['name'] as String;
  }

  // Create order in Firebase
  Future<String> _createOrderInFirebase(
      CheckoutModel checkoutData, CartController cartController) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      if (cartController.cartItems.isEmpty) {
        throw Exception('Cannot create order with empty cart');
      }

      String orderId = _firestore.collection('orders').doc().id;

      Map<String, dynamic> orderData = {
        'id': orderId,
        'userId': currentUser.uid,
        'customerName': checkoutData.fullName,
        'customerEmail': checkoutData.email,
        'customerPhone': checkoutData.phoneNumber,
        'shippingAddress': checkoutData.address,
        'city': checkoutData.city,
        'state': checkoutData.state,
        'zipCode': checkoutData.zipCode,
        'country': checkoutData.country,
        'paymentMethod': checkoutData.paymentMethod,
        'specialInstructions': checkoutData.specialInstructions,
        'items': cartController.cartItems.map((item) => item.toJson()).toList(),
        'subtotal': cartController.totalPrice,
        'deliveryFee': deliveryFee,
        'totalAmount': cartController.totalPrice + deliveryFee,
        'status': 'pending',
        'orderDate': DateTime.now().toIso8601String(),
        'approvedDate': null,
        'cancelledDate': null,
        'adminNotes': null,
      };

      print('Creating order with data: $orderData'); // Debug log
      await _firestore.collection('orders').doc(orderId).set(orderData);
      print('Order created successfully with ID: $orderId'); // Debug log
      return orderId;
    } catch (e) {
      print('Error creating order in Firebase: $e');
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }
}
