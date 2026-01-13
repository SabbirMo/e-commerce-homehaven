import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  // Text controllers
  final nameController = TextEditingController();

  // Reactive variables
  var isLoading = false.obs;
  var selectedImagePath = ''.obs;
  var currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _auth.currentUser;
    if (currentUser.value != null) {
      nameController.text = currentUser.value?.displayName ?? '';
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  // Pick image from gallery with simple error handling
  Future<void> pickImageFromGallery() async {
    try {
      // Show loading dialog
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Opening Gallery...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      // Close loading dialog
      Get.back();

      if (image != null) {
        // Verify file exists
        final File file = File(image.path);
        if (await file.exists()) {
          selectedImagePath.value = image.path;
          Get.snackbar(
            'Success',
            'Image selected successfully!',
            backgroundColor: Colors.green[100],
            colorText: Colors.green[800],
            duration: Duration(seconds: 2),
            icon: Icon(Icons.check_circle, color: Colors.green[800]),
          );
        } else {
          Get.snackbar(
            'Error',
            'Selected image could not be accessed',
            backgroundColor: Colors.red[100],
            colorText: Colors.red[800],
            duration: Duration(seconds: 3),
            icon: Icon(Icons.error, color: Colors.red[800]),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print('Gallery picker error: $e');

      String errorMessage = 'Failed to access gallery';
      if (e.toString().toLowerCase().contains('permission')) {
        errorMessage =
            'Gallery access denied. Please allow photo access in device settings.';
      }

      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Gallery Error'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(errorMessage),
              SizedBox(height: 16),
              Text(
                'Try:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Allow photo access in device settings'),
              Text('• Restart the app'),
              Text('• Try using camera instead'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                pickImageFromCamera();
              },
              child: Text('Try Camera'),
            ),
          ],
        ),
      );
    }
  }

  // Pick image from camera with simple error handling
  Future<void> pickImageFromCamera() async {
    try {
      // Show loading dialog
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Opening Camera...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      // Close loading dialog
      Get.back();

      if (image != null) {
        // Verify file exists
        final File file = File(image.path);
        if (await file.exists()) {
          selectedImagePath.value = image.path;
          Get.snackbar(
            'Success',
            'Photo captured successfully!',
            backgroundColor: Colors.green[100],
            colorText: Colors.green[800],
            duration: Duration(seconds: 2),
            icon: Icon(Icons.check_circle, color: Colors.green[800]),
          );
        } else {
          Get.snackbar(
            'Error',
            'Captured photo could not be accessed',
            backgroundColor: Colors.red[100],
            colorText: Colors.red[800],
            duration: Duration(seconds: 3),
            icon: Icon(Icons.error, color: Colors.red[800]),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print('Camera picker error: $e');

      String errorMessage = 'Failed to access camera';
      if (e.toString().toLowerCase().contains('permission')) {
        errorMessage =
            'Camera access denied. Please allow camera access in device settings.';
      }

      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.red),
              SizedBox(width: 8),
              Text('Camera Error'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(errorMessage),
              SizedBox(height: 16),
              Text(
                'Try:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Allow camera access in device settings'),
              Text('• Restart the app'),
              Text('• Try using gallery instead'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                pickImageFromGallery();
              },
              child: Text('Try Gallery'),
            ),
          ],
        ),
      );
    }
  }

  // Show image picker options
  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Choose Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  Icons.photo_library,
                  'Gallery',
                  () {
                    Get.back();
                    pickImageFromGallery();
                  },
                ),
                _buildImageOption(
                  Icons.camera_alt,
                  'Camera',
                  () {
                    Get.back();
                    pickImageFromCamera();
                  },
                ),
                if (selectedImagePath.value.isNotEmpty)
                  _buildImageOption(
                    Icons.delete_outline,
                    'Remove',
                    () {
                      Get.back();
                      selectedImagePath.value = '';
                      Get.snackbar(
                        'Success',
                        'Profile photo removed',
                        backgroundColor: Colors.orange[100],
                        colorText: Colors.orange[800],
                        duration: Duration(seconds: 2),
                        icon:
                            Icon(Icons.check_circle, color: Colors.orange[800]),
                      );
                    },
                  ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.grey[700]),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Update profile
  Future<void> updateProfile() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your name',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

    try {
      isLoading.value = true;

      User? user = _auth.currentUser;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(nameController.text.trim());

        // If image is selected, update profile photo
        // Note: In a real app, you would upload the image to Firebase Storage
        // and get the download URL, then update the photoURL
        if (selectedImagePath.value.isNotEmpty) {
          // For now, we'll just show a success message
          // In production, implement image upload to Firebase Storage
          Get.snackbar(
            'Note',
            'Image selected. In production, this would be uploaded to cloud storage.',
            backgroundColor: Colors.blue[100],
            colorText: Colors.blue[800],
          );
        }

        // Reload user to get updated information
        await user.reload();
        currentUser.value = _auth.currentUser;

        Get.snackbar(
          'Success',
          'Profile updated successfully!',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
        );

        // Go back to profile screen
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Reset form
  void resetForm() {
    nameController.text = currentUser.value?.displayName ?? '';
    selectedImagePath.value = '';
  }
}
