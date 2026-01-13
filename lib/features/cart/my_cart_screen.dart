import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_haven/core/assets/app_colors.dart';
import 'package:home_haven/features/cart/controller/cart_controller.dart';
import 'package:home_haven/features/cart/model/cart_model.dart';
import 'package:home_haven/features/onboarding/widget/custom_button.dart';
import 'package:home_haven/features/bottom_navbar/controller/navigation_controller.dart';

class MyCartScreen extends StatelessWidget {
  const MyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () {
            // Check if we can navigate back
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // If we can't go back, switch to home tab
              try {
                final NavigationController navController =
                    Get.find<NavigationController>();
                navController.changeTab(0); // Switch to home tab
              } catch (e) {
                // If navigation controller not found, try going back anyway
                Navigator.pop(context);
              }
            }
          },
        ),
        title: Text(
          'My Cart',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.notifications_outlined, color: Colors.black87),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return _buildEmptyCart();
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: cartController.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartController.cartItems[index];
                  return _buildCartItem(item, cartController);
                },
              ),
            ),
            _buildBottomSection(cartController),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some items to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: CustomButton(
              text: 'Start Shopping',
              onTap: () {
                // Navigate to home screen through bottom navigation
                try {
                  final NavigationController navController =
                      Get.find<NavigationController>();
                  navController.changeTab(0); // Switch to home tab (index 0)

                  // If we're in a standalone cart screen (not bottom nav), go back to main screen
                  if (Navigator.canPop(Get.context!)) {
                    Get.back();
                  }

                  Get.snackbar(
                    'Let\'s Shop! 🛍️',
                    'Browse our amazing products',
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    colorText: AppColors.primary,
                    duration: Duration(seconds: 2),
                    snackPosition: SnackPosition.BOTTOM,
                    margin: EdgeInsets.all(16),
                    borderRadius: 12,
                    icon: Icon(Icons.shopping_bag, color: AppColors.primary),
                  );
                } catch (e) {
                  // Fallback: Navigate to main screen with bottom navigation
                  Get.offAllNamed('/mainScreen');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartModel item, CartController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content
          Row(
            children: [
              // Product Image
              Container(
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
              SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name..toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),

                    // Price Row
                    Row(
                      children: [
                        Text(
                          '৳${item.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 8),
                        if (item.originalPrice > item.price)
                          Text(
                            '৳${item.originalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        SizedBox(width: 8),
                        if (item.discountPercentage.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.discountPercentage,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),

                    // Color
                    Text(
                      item.color,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 12),

                    // Quantity Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Quantity Controls
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.remove,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                onPressed: () {
                                  controller.decreaseQuantity(
                                      item.id, item.color);
                                },
                                padding: EdgeInsets.all(8),
                                constraints: BoxConstraints(),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  item.quantity.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.add,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                onPressed: () {
                                  controller.increaseQuantity(
                                      item.id, item.color);
                                },
                                padding: EdgeInsets.all(8),
                                constraints: BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Delete Button - Top Right
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // Show confirmation dialog
                Get.dialog(
                  AlertDialog(
                    title: Text('Remove Item'),
                    content: Text(
                        'Are you sure you want to remove ${item.name.replaceAll('"', '')} from your cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.removeFromCart(item.id, item.color);
                          Get.back();
                          Get.snackbar(
                            'Removed',
                            '${item.name.replaceAll('"', '')} removed from cart',
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red[100],
                            colorText: Colors.red[800],
                          );
                        },
                        child:
                            Text('Remove', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(CartController controller) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Order Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total (${controller.itemCount} items)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '৳${controller.totalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            if (controller.totalSavings > 0) ...[
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'You saved',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '৳${controller.totalSavings.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 20),

            // Checkout Button
            CustomButton(
              text: 'Proceed to Checkout',
              onTap: () {
                Get.toNamed('/checkout');
              },
            ),
          ],
        ),
      ),
    );
  }
}
