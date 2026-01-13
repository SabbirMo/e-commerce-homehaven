import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class SimpleProfileController extends GetxController {
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

  // Enhanced gallery picker with comprehensive error handling and platform optimization
  Future<void> pickImageFromGallery() async {
    try {
      // Show loading indicator with better design
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(24),
            margin: EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  strokeWidth: 3,
                ),
                SizedBox(height: 20),
                Text(
                  'Opening Gallery...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please wait',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Add small delay to show loading indicator
      await Future.delayed(Duration(milliseconds: 300));

      // Try multiple approaches for better compatibility
      XFile? image;

      try {
        // First attempt: Standard gallery picker
        image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
          requestFullMetadata: false,
        );
      } catch (primaryError) {
        print('Primary picker failed: $primaryError');

        // Second attempt: Try with different parameters
        try {
          image = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 100,
          );
        } catch (secondaryError) {
          print('Secondary picker failed: $secondaryError');
          throw primaryError; // Use the original error
        }
      }

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (image != null) {
        print('Image selected: ${image.path}');

        // Verify file exists and is accessible
        final File file = File(image.path);

        try {
          final bool exists = await file.exists();
          if (exists) {
            // Additional verification: try to read file size
            final int fileSize = await file.length();
            print('File size: $fileSize bytes');

            if (fileSize > 0) {
              selectedImagePath.value = image.path;

              // Show success message
              Get.snackbar(
                'Success! ✅',
                'Image selected successfully',
                backgroundColor: Colors.green[50],
                colorText: Colors.green[800],
                borderColor: Colors.green[300],
                borderWidth: 1,
                duration: Duration(seconds: 2),
                icon: Icon(Icons.check_circle, color: Colors.green[700]),
                snackPosition: SnackPosition.BOTTOM,
                margin: EdgeInsets.all(16),
                borderRadius: 12,
              );
            } else {
              throw Exception('Selected file is empty');
            }
          } else {
            throw Exception('Selected file does not exist');
          }
        } catch (fileError) {
          print('File verification error: $fileError');
          Get.snackbar(
            'File Error',
            'Selected image file could not be accessed. Please try again.',
            backgroundColor: Colors.orange[50],
            colorText: Colors.orange[800],
            borderColor: Colors.orange[300],
            borderWidth: 1,
            duration: Duration(seconds: 3),
            icon: Icon(Icons.warning, color: Colors.orange[700]),
            snackPosition: SnackPosition.BOTTOM,
            margin: EdgeInsets.all(16),
            borderRadius: 12,
          );
        }
      } else {
        // User cancelled - show gentle message
        Get.snackbar(
          'No Image Selected',
          'You can try again anytime',
          backgroundColor: Colors.grey[50],
          colorText: Colors.grey[700],
          borderColor: Colors.grey[300],
          borderWidth: 1,
          duration: Duration(seconds: 1),
          icon: Icon(Icons.info_outline, color: Colors.grey[600]),
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print('Gallery picker error: $e');

      // Enhanced error analysis
      String errorTitle = 'Gallery Access Failed';
      String errorMessage = 'Unable to access photo gallery';
      String actionMessage = 'Please try the following:';
      List<String> troubleshootingSteps = [];
      bool showCameraFallback = true;

      final String errorString = e.toString().toLowerCase();

      if (errorString.contains('permission') ||
          errorString.contains('denied')) {
        errorTitle = 'Permission Required';
        errorMessage = 'App needs permission to access your photos';
        troubleshootingSteps = [
          '• Go to Settings > Apps > Home Haven > Permissions',
          '• Allow "Photos and media" or "Storage" access',
          '• Restart the app and try again',
        ];
      } else if (errorString.contains('no_available_camera') ||
          errorString.contains('camera')) {
        errorTitle = 'Camera Issue';
        errorMessage = 'Camera service is not available';
        troubleshootingSteps = [
          '• Try selecting from gallery instead',
          '• Restart your device',
          '• Check if other camera apps work',
        ];
      } else if (errorString.contains('photo_access_denied') ||
          errorString.contains('media')) {
        errorTitle = 'Media Access Denied';
        errorMessage = 'Cannot access device media storage';
        troubleshootingSteps = [
          '• Allow media access in device settings',
          '• Check available storage space',
          '• Try restarting the app',
        ];
      } else if (errorString.contains('platform') ||
          errorString.contains('channel')) {
        errorTitle = 'System Error';
        errorMessage = 'Platform communication error occurred';
        troubleshootingSteps = [
          '• Restart the app completely',
          '• Check for app updates',
          '• Try again in a few moments',
        ];
        showCameraFallback = false;
      } else {
        troubleshootingSteps = [
          '• Ensure you have photos in your gallery',
          '• Check app permissions in device settings',
          '• Restart the app',
          '• Free up device storage if needed',
        ];
      }

      // Show comprehensive error dialog
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[600], size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  errorTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  actionMessage,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                ...troubleshootingSteps
                    .map((step) => Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            step,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.3,
                            ),
                          ),
                        ))
                    .toList(),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[600], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Error details: ${e.toString()}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[800],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            if (showCameraFallback)
              TextButton(
                onPressed: () {
                  Get.back();
                  pickImageFromCamera();
                },
                child: Text(
                  'Try Camera',
                  style: TextStyle(color: Colors.blue[600]),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                // Retry gallery picker
                Future.delayed(Duration(milliseconds: 500), () {
                  pickImageFromGallery();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  // Enhanced camera picker with better error handling
  Future<void> pickImageFromCamera() async {
    try {
      // Show loading indicator
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(24),
            margin: EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  strokeWidth: 3,
                ),
                SizedBox(height: 20),
                Text(
                  'Opening Camera...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please wait',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Add small delay to show loading indicator
      await Future.delayed(Duration(milliseconds: 300));

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (image != null) {
        print('Photo captured: ${image.path}');

        // Verify file exists and is accessible
        final File file = File(image.path);

        try {
          final bool exists = await file.exists();
          if (exists) {
            final int fileSize = await file.length();
            print('Photo file size: $fileSize bytes');

            if (fileSize > 0) {
              selectedImagePath.value = image.path;

              Get.snackbar(
                'Success! 📷',
                'Photo captured successfully',
                backgroundColor: Colors.green[50],
                colorText: Colors.green[800],
                borderColor: Colors.green[300],
                borderWidth: 1,
                duration: Duration(seconds: 2),
                icon: Icon(Icons.camera_alt, color: Colors.green[700]),
                snackPosition: SnackPosition.BOTTOM,
                margin: EdgeInsets.all(16),
                borderRadius: 12,
              );
            } else {
              throw Exception('Captured photo is empty');
            }
          } else {
            throw Exception('Captured photo could not be saved');
          }
        } catch (fileError) {
          print('Photo file error: $fileError');
          Get.snackbar(
            'Photo Error',
            'Captured photo could not be processed. Please try again.',
            backgroundColor: Colors.orange[50],
            colorText: Colors.orange[800],
            borderColor: Colors.orange[300],
            borderWidth: 1,
            duration: Duration(seconds: 3),
            icon: Icon(Icons.warning, color: Colors.orange[700]),
            snackPosition: SnackPosition.BOTTOM,
            margin: EdgeInsets.all(16),
            borderRadius: 12,
          );
        }
      } else {
        // User cancelled camera
        Get.snackbar(
          'Photo Cancelled',
          'No photo was taken',
          backgroundColor: Colors.grey[50],
          colorText: Colors.grey[700],
          borderColor: Colors.grey[300],
          borderWidth: 1,
          duration: Duration(seconds: 1),
          icon: Icon(Icons.info_outline, color: Colors.grey[600]),
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print('Camera picker error: $e');

      String errorTitle = 'Camera Access Failed';
      String errorMessage = 'Unable to access camera';
      List<String> troubleshootingSteps = [];

      final String errorString = e.toString().toLowerCase();

      if (errorString.contains('permission') ||
          errorString.contains('denied')) {
        errorTitle = 'Camera Permission Required';
        errorMessage = 'App needs permission to access your camera';
        troubleshootingSteps = [
          '• Go to Settings > Apps > Home Haven > Permissions',
          '• Allow "Camera" access',
          '• Restart the app and try again',
        ];
      } else if (errorString.contains('camera_access_denied')) {
        errorTitle = 'Camera Access Denied';
        errorMessage = 'Please allow camera access in device settings';
        troubleshootingSteps = [
          '• Check camera permissions in Settings',
          '• Ensure no other app is using camera',
          '• Restart your device if needed',
        ];
      } else if (errorString.contains('no_available_camera')) {
        errorTitle = 'No Camera Available';
        errorMessage = 'No camera found on this device';
        troubleshootingSteps = [
          '• Try selecting from gallery instead',
          '• Check if camera works in other apps',
          '• Restart your device',
        ];
      } else {
        troubleshootingSteps = [
          '• Ensure camera is not being used by another app',
          '• Check camera permissions in device settings',
          '• Restart the app',
          '• Try using gallery picker instead',
        ];
      }

      // Show error dialog
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.red[600], size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  errorTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Please try the following:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                ...troubleshootingSteps
                    .map((step) => Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            step,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.3,
                            ),
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                pickImageFromGallery();
              },
              child: Text(
                'Try Gallery',
                style: TextStyle(color: Colors.blue[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                // Retry camera
                Future.delayed(Duration(milliseconds: 500), () {
                  pickImageFromCamera();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Retry'),
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

        // Reload user to get updated information
        await user.reload();
        currentUser.value = _auth.currentUser;

        Get.snackbar(
          'Success',
          'Profile updated successfully!',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
          icon: Icon(Icons.check_circle, color: Colors.green[800]),
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
