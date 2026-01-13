import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_haven/core/assets/app_colors.dart';
import 'package:home_haven/features/wishlist/controller/wishlist_controller.dart';
import 'package:home_haven/features/product_details/screen/product_details_screen.dart';
import 'package:home_haven/features/cart/controller/cart_controller.dart';
import 'package:home_haven/features/onboarding/widget/custom_button.dart';
import 'package:home_haven/features/bottom_navbar/controller/navigation_controller.dart';
import 'package:home_haven/core/util/text_utils.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WishlistController wishlistController =
        Get.find<WishlistController>();
    final CartController cartController = Get.put(CartController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'My Wishlist',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => wishlistController.wishlistItems.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_all, color: Colors.white),
                  onPressed: () => _showClearAllDialog(wishlistController),
                )
              : SizedBox()),
        ],
      ),
      body: Obx(() {
        if (wishlistController.wishlistItems.isEmpty) {
          return _buildEmptyWishlist();
        }

        return Column(
          children: [
            // Wishlist Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    '${wishlistController.itemCount} items in your wishlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Wishlist Items
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: wishlistController.wishlistItems.length,
                itemBuilder: (context, index) {
                  final item = wishlistController.wishlistItems[index];
                  return _buildWishlistItem(
                      item, wishlistController, cartController);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Add some products to your wishlist and\nthey will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
          SizedBox(height: 40),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: CustomButton(
              text: 'Start Shopping',
              onTap: () {
                // Navigate to home screen
                try {
                  final NavigationController navController =
                      Get.find<NavigationController>();
                  navController.changeTab(0); // Switch to home tab
                  Get.back();

                  Get.snackbar(
                    'Happy Shopping! 🛍️',
                    'Find products you love and add them to wishlist',
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    colorText: AppColors.primary,
                    duration: Duration(seconds: 2),
                    snackPosition: SnackPosition.BOTTOM,
                    margin: EdgeInsets.all(16),
                    borderRadius: 12,
                    icon: Icon(Icons.favorite, color: AppColors.primary),
                  );
                } catch (e) {
                  // Fallback: Navigate to main screen
                  Get.back();
                  Get.offAllNamed('/mainScreen');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(dynamic item, WishlistController wishlistController,
      CartController cartController) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Product Image
                GestureDetector(
                  onTap: () =>
                      Get.to(() => ProductDetailsScreen(product: item)),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.chair,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            Get.to(() => ProductDetailsScreen(product: item)),
                        child: Text(
                          TextUtils.truncateToTwoWords(
                              item.title.toUpperCase()),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Price
                      if (item.offerPrice != null)
                        Row(
                          children: [
                            Text(
                              item.offerPrice!.replaceAll('"', ''),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 8),
                            if (item.regularPrice != null &&
                                item.offerPrice != item.regularPrice)
                              Text(
                                item.regularPrice!.replaceAll('"', ''),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      SizedBox(height: 12),

                      // Action Buttons
                      Row(
                        children: [
                          // Add to Cart Button
                          Expanded(
                            child: GetBuilder<CartController>(
                              builder: (controller) {
                                bool isInCart = controller.isInCart(item.id);
                                return ElevatedButton(
                                  onPressed: () {
                                    if (!isInCart) {
                                      controller.addToCart(item, 'Default');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isInCart
                                        ? AppColors.red
                                        : AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isInCart
                                            ? Icons.check
                                            : Icons.shopping_cart_outlined,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        isInCart ? 'Added' : 'Add to Cart',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Remove Button - Top Right
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _showRemoveDialog(item, wishlistController),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite,
                  color: AppColors.red,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(dynamic item, WishlistController wishlistController) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.favorite_border, color: AppColors.red),
            SizedBox(width: 8),
            Text('Remove from Wishlist'),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "${item.title.replaceAll('"', '')}" from your wishlist?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              wishlistController.removeFromWishlist(item.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(WishlistController wishlistController) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.clear_all, color: Colors.orange[600]),
            SizedBox(width: 8),
            Text('Clear All'),
          ],
        ),
        content: Text(
          'Are you sure you want to remove all items from your wishlist? This action cannot be undone.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              wishlistController.clearWishlist();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
