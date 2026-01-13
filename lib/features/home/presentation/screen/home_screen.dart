import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_haven/core/assets/app_colors.dart';
import 'package:home_haven/features/carouselslider/presentation/screen/carousel_slider.dart';
import 'package:home_haven/features/product_details/screen/product_details_screen.dart';
import 'package:home_haven/features/cart/controller/cart_controller.dart';
import 'package:home_haven/features/wishlist/controller/wishlist_controller.dart';
import 'package:home_haven/features/products/screen/all_products_screen.dart';
import 'package:home_haven/features/appliances/appliances_product_screen.dart';
import 'package:home_haven/features/furniture/screen/furniture_product_screen.dart';
import 'package:home_haven/features/outdoor/screen/outdoor_products_screen.dart';
import 'package:home_haven/features/special_offers/special_offers_screen.dart';
import 'package:home_haven/core/util/text_utils.dart';
import '../controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    // Ensure WishlistController is initialized
    Get.put(WishlistController());
    // Ensure CartController is initialized
    Get.put(CartController());

    // Add a variable to track if search is active
    final TextEditingController searchController = TextEditingController();
    // Add a FocusNode to control focus behavior
    final FocusNode searchFocusNode = FocusNode();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            controller.fetchAllProducts();
          },
          color: Color(0xff156651),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xffE0E0E0)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Obx(() => TextField(
                                    controller: searchController,
                                    focusNode:
                                        searchFocusNode, // Add focus node
                                    onChanged: (value) {
                                      controller.searchProduct(value);
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(12),
                                      border: InputBorder.none,
                                      hintText: "Search products...",
                                      prefixIcon: Icon(Icons.search_outlined),
                                      suffixIcon: controller
                                              .searchQuery.value.isNotEmpty
                                          ? IconButton(
                                              icon: Icon(Icons.clear),
                                              onPressed: () {
                                                searchController.clear();
                                                controller.searchProduct('');
                                              },
                                            )
                                          : null,
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CarouselSliderScreen(),
                      const SizedBox(height: 16),

                      // Categories Section
                      _buildCategoriesSection(),
                      const SizedBox(height: 24),
                      Obx(
                        () {
                          // Show search results if search is active, otherwise show special products
                          final isSearching =
                              controller.searchQuery.value.isNotEmpty;
                          final displayProducts = isSearching
                              ? controller.filterItem
                              : controller.allItem
                                  .where((product) =>
                                      product.category.toLowerCase() ==
                                      'special')
                                  .toList();

                          final sectionTitle = isSearching
                              ? 'Search Results (${displayProducts.length})'
                              : 'Popular Products';

                          return Column(
                            children: [
                              // Section Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    sectionTitle,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (!isSearching)
                                    InkWell(
                                      onTap: () {
                                        Get.to(() => SpecialOffersScreen());
                                      },
                                      child: Text(
                                        "See More",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff156651),
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xff156651),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 16),
                              // Products List
                              SizedBox(
                                height: 307,
                                child: displayProducts.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              isSearching
                                                  ? Icons.search_off
                                                  : Icons.local_offer,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              isSearching
                                                  ? 'No products found for "${controller.searchQuery.value}"'
                                                  : 'No Special Offers Available',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            if (isSearching)
                                              SizedBox(height: 8),
                                            if (isSearching)
                                              Text(
                                                'Try different keywords',
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 14,
                                                ),
                                              ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: displayProducts.length,
                                        itemBuilder: (_, index) {
                                          final item = displayProducts[index];
                                          return Container(
                                            width: 170,
                                            margin: EdgeInsets.all(8),
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                                boxShadow: [
                                                  BoxShadow(
                                                    blurRadius: 2,
                                                  ),
                                                ]),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Get.to(() =>
                                                        ProductDetailsScreen(
                                                            product: item));
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Align(
                                                            child:
                                                                Image.network(
                                                              item.image,
                                                              width: 110,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          // Only show discount badge if offPrice exists and is not empty
                                                          if (item.offPrice !=
                                                                  null &&
                                                              item.offPrice!
                                                                  .isNotEmpty)
                                                            Positioned(
                                                              bottom: 5,
                                                              child: Container(
                                                                width: 65,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      AppColors
                                                                          .red,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            14),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            14),
                                                                  ),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    item.offPrice!
                                                                        .replaceAll(
                                                                            '"',
                                                                            ''),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            11),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 3),
                                                      Text(
                                                        TextUtils
                                                            .truncateToTwoWords(
                                                                (item.title)
                                                                    .replaceAll(
                                                                        '"',
                                                                        '')),
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      // Price Section - Show offer price if available, otherwise regular price
                                                      if (item.offerPrice !=
                                                              null &&
                                                          item.offerPrice!
                                                              .isNotEmpty)
                                                        Text(
                                                          '৳${item.offerPrice!.replaceAll('"', '')}',
                                                          style: TextStyle(
                                                            fontSize: 19,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: AppColors
                                                                .primary,
                                                          ),
                                                        )
                                                      else
                                                        Text(
                                                          '৳${item.regularPrice.replaceAll('"', '')}',
                                                          style: TextStyle(
                                                            fontSize: 19,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: AppColors
                                                                .primary,
                                                          ),
                                                        ),
                                                      // Show regular price with strikethrough only if offer price exists and is different
                                                      if (item.offerPrice !=
                                                              null &&
                                                          item.offerPrice!
                                                              .isNotEmpty &&
                                                          item.regularPrice !=
                                                              item.offerPrice &&
                                                          item.regularPrice
                                                              .isNotEmpty)
                                                        Text(
                                                          '৳${item.regularPrice.replaceAll('"', '')}',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[600],
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                          ),
                                                        ),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.star,
                                                              color: Colors
                                                                  .amberAccent),
                                                          Text((item.rating)
                                                              .replaceAll(
                                                                  '"', '')),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                // Action Buttons Row
                                                Row(
                                                  children: [
                                                    // Wishlist Button
                                                    Expanded(
                                                      child: GetBuilder<
                                                          WishlistController>(
                                                        init:
                                                            WishlistController(),
                                                        builder:
                                                            (wishlistController) {
                                                          bool isWishlisted =
                                                              wishlistController
                                                                  .isInWishlist(
                                                                      item.id);
                                                          return GestureDetector(
                                                            onTap: () {
                                                              wishlistController
                                                                  .toggleWishlist(
                                                                      item);
                                                            },
                                                            child: Container(
                                                              height: 32,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: isWishlisted
                                                                    ? AppColors
                                                                        .red
                                                                        .withValues(
                                                                            alpha:
                                                                                0.1)
                                                                    : Colors.grey[
                                                                        100],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                border:
                                                                    Border.all(
                                                                  color: isWishlisted
                                                                      ? AppColors
                                                                          .red
                                                                      : Colors.grey[
                                                                          300]!,
                                                                  width: 1,
                                                                ),
                                                              ),
                                                              child: Center(
                                                                child: Icon(
                                                                  isWishlisted
                                                                      ? Icons
                                                                          .favorite
                                                                      : Icons
                                                                          .favorite_border,
                                                                  color: isWishlisted
                                                                      ? AppColors
                                                                          .red
                                                                      : Colors.grey[
                                                                          600],
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
                                                      child: GetBuilder<
                                                          CartController>(
                                                        init: CartController(),
                                                        builder:
                                                            (cartController) {
                                                          bool isInCart =
                                                              cartController
                                                                  .isInCart(
                                                                      item.id);

                                                          return GestureDetector(
                                                            onTap: () {
                                                              if (!isInCart) {
                                                                cartController
                                                                    .addToCart(
                                                                        item,
                                                                        'Default');
                                                              }
                                                            },
                                                            child: Container(
                                                              height: 32,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: isInCart
                                                                    ? AppColors
                                                                        .red
                                                                    : AppColors
                                                                        .primary,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child: Center(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      isInCart
                                                                          ? Icons
                                                                              .check
                                                                          : Icons
                                                                              .shopping_cart_outlined,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 14,
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            4),
                                                                    Text(
                                                                      isInCart
                                                                          ? 'Added'
                                                                          : 'Add',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w600,
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
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Outdoor Category
            Expanded(
              child: _buildCategoryCard(
                title: 'Outdoor',
                iconPath: 'assets/icons/grill.png',
                backgroundColor: Color(0xFFE0F0E3),
                onTap: () {
                  // Navigate to outdoor products
                  Get.to(() => OutdoorProductsScreen());
                },
              ),
            ),
            const SizedBox(width: 12),
            // Appliances Category
            Expanded(
              child: _buildCategoryCard(
                title: 'Appliances',
                iconPath: 'assets/icons/electrical.png',
                backgroundColor: Color(0xFFDEEBFF),
                onTap: () {
                  // Navigate to appliances
                  Get.to(() => AppliancesProductScreen());
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Furniture Category
            Expanded(
              child: _buildCategoryCard(
                title: 'Furniture',
                iconPath: 'assets/icons/sofa.png',
                backgroundColor: Color(0xFFFFEBC2),
                onTap: () {
                  // Navigate to furniture
                  Get.to(() => FurnitureProductScreen());
                },
              ),
            ),
            const SizedBox(width: 12),
            // See More Category
            Expanded(
              child: _buildCategoryCard(
                title: 'See More',
                iconPath: 'assets/icons/more-icon.png',
                backgroundColor: Color(0xFFEEEEEE),
                onTap: () {
                  // Navigate to all categories
                  Get.to(() => AllProductsScreen());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String iconPath,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 26, height: 26),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
