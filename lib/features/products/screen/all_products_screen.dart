import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_haven/core/assets/app_colors.dart';
import 'package:home_haven/features/home/presentation/controller/home_controller.dart';
import 'package:home_haven/features/product_details/screen/product_details_screen.dart';
import 'package:home_haven/features/cart/controller/cart_controller.dart';
import 'package:home_haven/features/wishlist/controller/wishlist_controller.dart';
import 'package:home_haven/core/util/text_utils.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is available
    HomeController controller;
    try {
      controller = Get.find<HomeController>();
    } catch (e) {
      controller = Get.put(HomeController());
    }

    // Ensure other controllers are available
    Get.put(WishlistController());
    Get.put(CartController());

    // Selected category for filtering and search
    final selectedCategory = 'All'.obs;
    final searchQuery = ''.obs;
    final isSearching = false.obs;
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Products',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => IconButton(
                icon: Icon(isSearching.value ? Icons.close : Icons.search,
                    color: Colors.black87),
                onPressed: () {
                  isSearching.toggle();
                  if (!isSearching.value) {
                    searchQuery.value = '';
                    searchController.clear();
                  }
                },
              )),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.allItem.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          // Filter products based on selected category and search query
          var filteredProducts = selectedCategory.value == 'All'
              ? controller.allItem
              : controller.allItem
                  .where((item) =>
                      item.category.toLowerCase() ==
                      selectedCategory.value.toLowerCase())
                  .toList();

          // Apply search filter
          if (searchQuery.value.isNotEmpty) {
            filteredProducts = filteredProducts
                .where((item) =>
                    item.title
                        .toLowerCase()
                        .contains(searchQuery.value.toLowerCase()) ||
                    item.category
                        .toLowerCase()
                        .contains(searchQuery.value.toLowerCase()))
                .toList();
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Obx(() => isSearching.value
                    ? Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) => searchQuery.value = value,
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon:
                                Icon(Icons.search, color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      )
                    : SizedBox.shrink()),

                // Products count
                Text(
                  '${filteredProducts.length} Products Found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),

                // Category Filter (hide when searching)
                Obx(() => !isSearching.value
                    ? Column(
                        children: [
                          _buildCategoryFilter(selectedCategory),
                          SizedBox(height: 16),
                        ],
                      )
                    : SizedBox.shrink()),

                // Products Grid or No Results
                Expanded(
                  child:
                      filteredProducts.isEmpty && searchQuery.value.isNotEmpty
                          ? _buildNoResultsFound()
                          : GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final item = filteredProducts[index];
                                return _buildProductCard(item);
                              },
                            ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProductCard(item) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailsScreen(product: item));
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Stack(
                children: [
                  // Clean Image Container
                  GestureDetector(
                    onTap: () {
                      Get.to(() => ProductDetailsScreen(product: item));
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                        color: Colors.grey[50],
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.network(
                            item.image,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chair_outlined,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'No Image',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[500],
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
                  ),
                  // Discount Badge - Enhanced Design
                  if (item.offPrice != null && item.offPrice!.isNotEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade400, Colors.red.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          item.offPrice!.replaceAll('"', ''),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Category Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(item.category),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Title
                    Text(
                      TextUtils.truncateToTwoWords(
                          (item.title ?? '').replaceAll('"', '')),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),

                    // Price Row - Show offer price if available, otherwise regular price
                    Row(
                      children: [
                        if (item.offerPrice != null &&
                            item.offerPrice!.isNotEmpty)
                          Text(
                            '৳${item.offerPrice!.replaceAll('"', '')}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        else
                          Text(
                            '৳${item.regularPrice.replaceAll('"', '')}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        // Show regular price with strikethrough only if offer price exists and is different
                        if (item.offerPrice != null &&
                            item.offerPrice!.isNotEmpty &&
                            item.regularPrice != item.offerPrice &&
                            item.regularPrice.isNotEmpty) ...[
                          SizedBox(width: 8),
                          Text(
                            '৳${item.regularPrice.replaceAll('"', '')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4),

                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amberAccent, size: 14),
                        SizedBox(width: 2),
                        Text(
                          (item.rating ?? '').replaceAll('"', ''),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    //Spacer(),

                    // Action Buttons Row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          // Wishlist Button
                          Expanded(
                            child: GetBuilder<WishlistController>(
                              init: WishlistController(),
                              builder: (wishlistController) {
                                bool isWishlisted =
                                    wishlistController.isInWishlist(item.id);
                                return GestureDetector(
                                  onTap: () {
                                    wishlistController.toggleWishlist(item);
                                  },
                                  child: Container(
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isWishlisted
                                          ? AppColors.red.withValues(alpha: 0.1)
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isWishlisted
                                            ? AppColors.red
                                            : Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        isWishlisted
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isWishlisted
                                            ? AppColors.red
                                            : Colors.grey[600],
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          // Add to Cart Button
                          Expanded(
                            flex: 2,
                            child: GetBuilder<CartController>(
                              init: CartController(),
                              builder: (cartController) {
                                bool isInCart =
                                    cartController.isInCart(item.id);

                                return GestureDetector(
                                  onTap: () {
                                    if (!isInCart) {
                                      cartController.addToCart(item, 'Default');
                                    }
                                  },
                                  child: Container(
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isInCart
                                          ? AppColors.red
                                          : AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isInCart
                                                ? Icons.check
                                                : Icons.shopping_cart_outlined,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            isInCart ? 'Added' : 'Add',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Category Filter Widget
  Widget _buildCategoryFilter(RxString selectedCategory) {
    final categories = ['All', 'Outdoor', 'Appliances', 'Furniture', 'Special'];

    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return Obx(() {
            final isSelected = category == selectedCategory.value;

            return Padding(
              padding: EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  selectedCategory.value = category;
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[400]!,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // Helper method to get category color
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'outdoor':
        return Color(0xFF2E7D32); // Green
      case 'appliances':
        return Color(0xFF1976D2); // Blue
      case 'furniture':
        return Color(0xFFFF9800); // Orange
      case 'special':
        return Color(0xFFD32F2F); // Red
      default:
        return Colors.grey;
    }
  }

  // No Results Found Widget
  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Products Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search terms\nor browse our categories',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
