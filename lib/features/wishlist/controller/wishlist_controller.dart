import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_haven/features/home/model/home_model.dart';

class WishlistController extends GetxController {
  var wishlistItems = <HomeModel>[].obs;

  // Get total wishlist items count
  int get itemCount => wishlistItems.length;

  // Check if item is in wishlist
  bool isInWishlist(String productId) {
    return wishlistItems.any((item) => item.id == productId);
  }

  // Add item to wishlist
  void addToWishlist(HomeModel product) {
    if (!isInWishlist(product.id)) {
      wishlistItems.add(product);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text('${product.title} has been added to your wishlist'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Remove item from wishlist
  void removeFromWishlist(String productId) {
    int index = wishlistItems.indexWhere((item) => item.id == productId);
    if (index != -1) {
      String productName = wishlistItems[index].title;
      wishlistItems.removeAt(index);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text('$productName has been removed from your wishlist'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Toggle wishlist status
  void toggleWishlist(HomeModel product) {
    if (isInWishlist(product.id)) {
      removeFromWishlist(product.id);
    } else {
      addToWishlist(product);
    }
    update(); // Force update for GetBuilder widgets
  }

  // Clear all wishlist items
  void clearWishlist() {
    wishlistItems.clear();
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Text('All items have been removed from your wishlist'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
