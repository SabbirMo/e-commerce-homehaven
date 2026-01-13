import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_haven/core/assets/app_colors.dart';
import 'package:home_haven/features/home/presentation/controller/home_controller.dart';
import 'package:home_haven/features/product_details/screen/product_details_screen.dart';
import 'package:home_haven/features/cart/controller/cart_controller.dart';
import 'package:home_haven/features/wishlist/controller/wishlist_controller.dart';
import 'package:home_haven/core/util/text_utils.dart';

class AppliancesProductScreen extends StatelessWidget {
  const AppliancesProductScreen({super.key});

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

    // Search state variables
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
          'Appliances Products',
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
          // Filter appliances products
          var appliancesProducts = controller.allItem
              .where(
                  (product) => product.category.toLowerCase() == 'appliances')
              .toList();

          // Apply search filter
          if (searchQuery.value.isNotEmpty) {
            appliancesProducts = appliancesProducts
                .where((item) => item.title
                    .toLowerCase()
                    .contains(searchQuery.value.toLowerCase()))
                .toList();
          }

          if (controller.allItem.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (appliancesProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.outdoor_grill,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Appliances Products Found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Check back later for Appliances products',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE0F0E3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.outdoor_grill,
                        color: Color(0xFF2E7D32),
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Appliances Collection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

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
                            hintText: 'Search appliances...',
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
                  '${appliancesProducts.length} Appliances Products Found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),

                // Products Grid or No Results
                Expanded(
                  child:
                      appliancesProducts.isEmpty && searchQuery.value.isNotEmpty
                          ? _buildNoResultsFound()
                          : GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.6,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: appliancesProducts.length,
                              itemBuilder: (context, index) {
                                final item = appliancesProducts[index];
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
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFE0F0E3),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.outdoor_grill,
                            size: 50,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Product Details
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Title
                    Text(
                      TextUtils.truncateToTwoWords(
                          item.title.replaceAll('"', '')),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),

                    // Price Row - Show offer price if available, otherwise regular price
                    if (item.offerPrice != null && item.offerPrice!.isNotEmpty)
                      Text(
                        '৳${item.offerPrice!.replaceAll('"', '')}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        '৳${item.regularPrice.replaceAll('"', '')}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 6),

                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amberAccent, size: 14),
                        SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            item.rating.replaceAll('"', ''),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    // Action Buttons Row
                    Row(
                      children: [
                        // Wishlist Button
                        Expanded(
                          child: Container(
                            height: 32,
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
                        ),
                        SizedBox(width: 8),
                        // Add to Cart Button
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 32,
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
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isInCart
                                                ? Icons.check
                                                : Icons.shopping_cart_outlined,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              isInCart ? 'Added' : 'Add',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
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
                        ),
                      ],
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
            'No Appliances Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search terms\nor browse our other categories',
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
