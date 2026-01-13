import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_haven/core/assets/app_colors.dart';
import 'package:home_haven/core/router/app_routers.dart';
import 'package:home_haven/features/orders/screen/customer_order_screen.dart';
import 'package:home_haven/features/profile/screen/edit_profile_screen.dart';
import 'package:home_haven/features/wishlist/screen/wishlist_screen.dart';
import 'package:home_haven/features/wishlist/controller/wishlist_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 20),
              // Profile Header
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Icon(
                              Icons.person_rounded,
                              size: 40,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    SizedBox(height: 16),
                    Text(
                      user?.displayName ?? 'User',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user?.email ?? 'No email',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user?.emailVerified == true
                            ? 'Verified Account'
                            : 'Unverified',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Menu Options
              _buildMenuSection('Account', [
                _buildMenuItem(
                  Icons.edit_rounded,
                  'Edit Profile',
                  'Update your personal information',
                  () => Get.to(() => EditProfileScreen()),
                ),
                _buildMenuItem(
                  Icons.shopping_bag_rounded,
                  'Order History',
                  'View your past orders',
                  () {
                    // Navigate to customer order screen using direct navigation
                    // This avoids the bottom navigation restart issue
                    try {
                      Get.to(() => CustomerOrderScreen());
                    } catch (e) {
                      // Fallback to router navigation if direct navigation fails
                      Get.toNamed(RouterConstant.customerOrders);
                    }
                  },
                ),
                _buildMenuItem(
                  Icons.location_on_rounded,
                  'Addresses',
                  'Manage delivery addresses',
                  () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Addresses management coming soon!'),
                    ),
                  ),
                ),
                _buildWishlistMenuItem(),
              ]),

              SizedBox(height: 16),

              _buildMenuSection('Preferences', [
                _buildMenuItem(
                  Icons.notifications_rounded,
                  'Notifications',
                  'Manage notification settings',
                  () => Get.snackbar(
                      'Coming Soon', 'Notification settings coming soon!'),
                ),
                _buildMenuItem(
                  Icons.security_rounded,
                  'Security',
                  'Password and security settings',
                  () => Get.snackbar(
                      'Coming Soon', 'Security settings coming soon!'),
                ),
                _buildMenuItem(
                  Icons.help_rounded,
                  'Help & Support',
                  'Get help and contact support',
                  () => Get.snackbar('Coming Soon', 'Help center coming soon!'),
                ),
              ]),

              SizedBox(height: 24),

              // Logout Button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red[600],
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red[200]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Container(
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
          Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildWishlistMenuItem() {
    final WishlistController wishlistController = Get.put(WishlistController());

    return Obx(() => ListTile(
          onTap: () => Get.to(() => WishlistScreen()),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.favorite,
              color: AppColors.red,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Text(
                'My Wishlist',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (wishlistController.itemCount > 0)
                Container(
                  margin: EdgeInsets.only(left: 8),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${wishlistController.itemCount}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            wishlistController.itemCount > 0
                ? '${wishlistController.itemCount} items saved'
                : 'Save your favorite products',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey[400],
          ),
        ));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.red[600],
              ),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
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
              onPressed: () async {
                Get.back();
                await FirebaseAuth.instance.signOut();
                Get.offAllNamed(RouterConstant.loginScreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
