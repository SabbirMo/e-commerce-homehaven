import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/model/home_model.dart';

class AdminProductController extends GetxController {
  // Text controllers for form
  final titleController = TextEditingController();
  final imageController = TextEditingController();
  final descriptionController = TextEditingController();
  final regularPriceController = TextEditingController();
  final offerPriceController = TextEditingController();
  final offPriceController = TextEditingController();
  final ratingController = TextEditingController();

  // Category selection
  var selectedCategory = 'outdoor'.obs;
  final categories = ['outdoor', 'appliances', 'furniture', 'special'];

  // Observable variables
  var products = <HomeModel>[].obs;
  var isLoading = false.obs;
  var totalProducts = 0.obs;
  var activeProducts = 0.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String mainDocId = "JbmCjuFy2CF90gyYW4tC";

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  @override
  void onClose() {
    titleController.dispose();
    imageController.dispose();
    descriptionController.dispose();
    regularPriceController.dispose();
    offerPriceController.dispose();
    offPriceController.dispose();
    ratingController.dispose();
    super.onClose();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;

      final docRef = _firestore.collection('cetagories').doc(mainDocId);
      List<HomeModel> allProducts = [];

      // Fetch from all categories
      for (String category in categories) {
        var snapshot = await docRef.collection(category).get();
        var categoryProducts = snapshot.docs
            .map((doc) => HomeModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList();
        allProducts.addAll(categoryProducts);
      }

      products.value = allProducts;
      totalProducts.value = allProducts.length;
      activeProducts.value =
          allProducts.length; // Assuming all are active for now
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      final docRef = _firestore
          .collection('cetagories')
          .doc(mainDocId)
          .collection(selectedCategory.value);

      await docRef.add({
        'title': titleController.text.trim(),
        'image': imageController.text.trim(),
        'description': descriptionController.text.trim(),
        'regularPrice': regularPriceController.text.trim(),
        'offerPrice': offerPriceController.text.trim(),
        'offPrice': offPriceController.text.trim(),
        'rating': ratingController.text.trim(),
        'category': selectedCategory.value,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'Product added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearForm();
      fetchProducts();
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add product: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(String productId) async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      final docRef = _firestore
          .collection('cetagories')
          .doc(mainDocId)
          .collection(selectedCategory.value)
          .doc(productId);

      await docRef.update({
        'title': titleController.text.trim(),
        'image': imageController.text.trim(),
        'description': descriptionController.text.trim(),
        'regularPrice': regularPriceController.text.trim(),
        'offerPrice': offerPriceController.text.trim(),
        'offPrice': offPriceController.text.trim(),
        'rating': ratingController.text.trim(),
        'category': selectedCategory.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'Product updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearForm();
      fetchProducts();
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update product: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      // Find the product to get its category
      HomeModel? productToDelete;
      for (var product in products) {
        if (product.id == productId) {
          productToDelete = product;
          break;
        }
      }

      if (productToDelete == null) {
        Get.snackbar('Error', 'Product not found');
        return;
      }

      final docRef = _firestore
          .collection('cetagories')
          .doc(mainDocId)
          .collection(productToDelete.category.toLowerCase())
          .doc(productId);

      await docRef.delete();

      Get.snackbar(
        'Success',
        'Product deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      fetchProducts();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete product: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void fillFormForEdit(HomeModel product) {
    titleController.text = product.title;
    imageController.text = product.image;
    descriptionController.text = product.description ?? '';
    regularPriceController.text = product.regularPrice ?? '';
    offerPriceController.text = product.offerPrice ?? '';
    offPriceController.text = product.offPrice ?? '';
    ratingController.text = product.rating;
    selectedCategory.value = product.category.toLowerCase();
  }

  void clearForm() {
    titleController.clear();
    imageController.clear();
    descriptionController.clear();
    regularPriceController.clear();
    offerPriceController.clear();
    offPriceController.clear();
    ratingController.clear();
    selectedCategory.value = 'outdoor';
  }

  bool _validateForm() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter product title',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (imageController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter image URL',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }
}
