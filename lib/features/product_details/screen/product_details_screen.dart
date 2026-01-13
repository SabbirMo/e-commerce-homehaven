// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_haven/core/assets/app_colors.dart';
import 'package:home_haven/features/home/model/home_model.dart';
import 'package:home_haven/features/onboarding/widget/custom_button.dart';
import 'package:home_haven/features/cart/controller/cart_controller.dart';
import 'package:home_haven/features/cart/my_cart_screen.dart';
import 'package:home_haven/features/wishlist/controller/wishlist_controller.dart';
import 'package:home_haven/core/util/text_utils.dart';

class ProductDetailsScreen extends StatefulWidget {
  final HomeModel product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int selectedColorIndex = 0;
  late CartController cartController;

  @override
  void initState() {
    super.initState();
    cartController = Get.put(CartController());
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: topPadding + 10), // Safe area padding
                  // Product Image Section
                  Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Center the image within the container
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                _getSelectedColor().withOpacity(0.3),
                                BlendMode.multiply,
                              ),
                              child: Image.network(
                                widget.product.image,
                                width: double.infinity,
                                height: 400,
                                fit: BoxFit
                                    .contain, // Changed from cover to contain to center the image
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: 400,
                                    decoration: BoxDecoration(
                                      color:
                                          _getSelectedColor().withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chair,
                                          color: _getSelectedColor(),
                                          size: 100,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Sofa Preview',
                                          style: TextStyle(
                                            color: _getSelectedColor(),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        // Back Button
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(48, 255, 255, 255),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.black87,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Product Info Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Title
                        Text(
                          TextUtils.truncateToTwoWords(
                              widget.product.title.toUpperCase()),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8),

                        // Price Section
                        if (widget.product.offerPrice != null)
                          Row(
                            children: [
                              Text(
                                widget.product.offerPrice!.replaceAll('"', ''),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 12),
                              if (widget.product.regularPrice != null &&
                                  widget.product.offerPrice != null &&
                                  widget.product.regularPrice !=
                                      widget.product.offerPrice &&
                                  widget.product.offPrice != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.product.offPrice!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                        if (widget.product.regularPrice != null &&
                            widget.product.offerPrice != null &&
                            widget.product.regularPrice !=
                                widget.product.offerPrice)
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              widget.product.regularPrice!.replaceAll('"', ''),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),

                        SizedBox(height: 16),

                        // Rating Section
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text(
                              widget.product.rating,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              ' (256)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24),

                        // Description
                        Text(
                          widget.product.description.isNotEmpty
                              ? widget.product.description
                              : 'A minimalist chair with a reversible back cushion provides soft support for your back and has two sides to wear.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: 32),

                        // Colors Section
                        Text(
                          'Colors',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: 16),

                        // Color Options
                        _buildColorOptions(),

                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Wishlist Button
                  GetBuilder<WishlistController>(
                    init: WishlistController(),
                    builder: (wishlistController) {
                      bool isWishlisted =
                          wishlistController.isInWishlist(widget.product.id);
                      return Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isWishlisted
                                ? AppColors.red
                                : AppColors.gradient,
                            width: isWishlisted ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isWishlisted
                              ? AppColors.red.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isWishlisted
                                ? AppColors.red
                                : AppColors.primary,
                            size: 24,
                          ),
                          onPressed: () {
                            wishlistController.toggleWishlist(widget.product);
                          },
                        ),
                      );
                    },
                  ),

                  SizedBox(width: 16),

                  // Add to Cart Button
                  Expanded(
                    child: GetBuilder<CartController>(
                      init: CartController(),
                      builder: (controller) {
                        bool isInCart = controller.isInCart(widget.product.id);
                        return ElevatedButton(
                          onPressed: () {
                            if (!isInCart) {
                              final selectedColor = _getSelectedColorName();
                              controller.addToCart(
                                  widget.product, selectedColor);
                            } else {
                              // Navigate to cart if already added
                              Get.to(() => MyCartScreen());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isInCart ? AppColors.red : AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isInCart
                                    ? Icons.check_circle
                                    : Icons.shopping_cart_outlined,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                isInCart ? 'Added to Cart' : 'Add to Cart',
                                style: TextStyle(
                                  fontSize: 16,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOptions() {
    final colors = [
      {'name': 'Harvest Gold', 'color': Color(0xFFE6A623)},
      {'name': 'Eerie Black', 'color': Color(0xFF1C1C1C)},
      {'name': 'Flame', 'color': Color(0xFFE55722)},
      {'name': 'Pakistan Green', 'color': Color(0xFF2E7D32)},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> colorOption = entry.value;
        bool isSelected = selectedColorIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedColorIndex = index;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: MediaQuery.of(context).size.width * .43,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Color(0xFF2E7D32) : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colorOption['color'] as Color,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 0.5,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  colorOption['name'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Color(0xFF2E7D32) : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getSelectedColor() {
    final colors = [
      Color(0xFFE6A623), // Harvest Gold
      Color(0xFF1C1C1C), // Eerie Black
      Color(0xFFE55722), // Flame
      Color(0xFF2E7D32), // Pakistan Green
    ];
    return colors[selectedColorIndex];
  }

  String _getSelectedColorName() {
    final colorNames = [
      'Harvest Gold',
      'Eerie Black',
      'Flame',
      'Pakistan Green',
    ];
    return colorNames[selectedColorIndex];
  }
}
