import 'package:home_haven/core/util/export.dart';
import 'package:flutter/material.dart';
import 'package:home_haven/core/assets/app_colors.dart';
import 'package:home_haven/features/home/model/home_model.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'admin_product_controller.dart';
import 'package:home_haven/features/orders/screen/orders_management_screen.dart';
import 'package:home_haven/features/orders/controller/orders_controller.dart';
import 'package:home_haven/features/orders/model/order_model.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminProductController controller = Get.put(AdminProductController());
    final OrdersController ordersController = Get.put(OrdersController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ordersController.fetchOrders();
              Get.snackbar(
                'Refreshing',
                'Updating order statistics...',
                backgroundColor: Colors.blue[100],
                colorText: Colors.blue[800],
                duration: Duration(seconds: 2),
              );
            },
          ),
          _buildUserProfileMenu(),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Stats
            _buildDashboardStats(controller),
            SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(controller),
            SizedBox(height: 24),

            // Orders Management Section
            _buildOrdersManagementSection(ordersController),
            SizedBox(height: 24),

            // Recent Pending Orders Section
            _buildRecentPendingOrdersSection(ordersController),
            SizedBox(height: 24),

            // Recent Products
            _buildRecentProducts(controller),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddProductDialog(context, controller);
        },
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Product',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildRecentPendingOrdersSection(OrdersController ordersController) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Get.to(() => OrdersManagementScreen());
                    Future.delayed(Duration(milliseconds: 100), () {
                      try {
                        Get.find<OrdersController>()
                            .filterByStatus(OrderStatus.pending);
                      } catch (e) {}
                    });
                  },
                  icon: Icon(Icons.arrow_forward, size: 16),
                  label: Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Obx(() {
              final pendingOrders = ordersController.orders
                  .where((order) => order.status == OrderStatus.pending)
                  .take(3)
                  .toList();

              if (pendingOrders.isEmpty) {
                return SizedBox(
                  height: 100,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pending_actions_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No pending orders',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: pendingOrders.length,
                itemBuilder: (context, index) {
                  final order = pendingOrders[index];
                  return _buildPendingOrderTile(order, ordersController);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingOrderTile(
      OrderModel order, OrdersController ordersController) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange[50]!,
            Colors.white,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      order.customerName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatDate(order.orderDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳${order.totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${order.items.length} items',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),

          // Customer Info
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey[600]),
              SizedBox(width: 4),
              Text(
                order.customerPhone,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${order.city}, ${order.state}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _showOrderDetailsDialog(order, ordersController),
                  icon: Icon(Icons.visibility, size: 16),
                  label: Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showQuickApproveDialog(order, ordersController),
                  icon: Icon(Icons.check_circle, size: 16),
                  label: Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showOrderDetailsDialog(
      OrderModel order, OrdersController ordersController) {
    ordersController.showOrderActionDialog(order);
  }

  void _showQuickApproveDialog(
      OrderModel order, OrdersController ordersController) {
    final TextEditingController notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 12),
            Text('Approve Order'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('Customer: ${order.customerName}'),
                  Text('Amount: ৳${order.totalAmount.toStringAsFixed(0)}'),
                  Text('Items: ${order.items.length}'),
                ],
              ),
            ),
            SizedBox(height: 16),

            Text(
              'Are you sure you want to approve this order?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Admin Notes (Optional)',
                hintText: 'Add any notes for the customer...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_add),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              ordersController.updateOrderStatus(
                order.id,
                OrderStatus.approved,
                adminNotes: notesController.text.trim().isEmpty
                    ? 'Approved from Admin Dashboard'
                    : notesController.text.trim(),
              );

              // Show success message
              Get.snackbar(
                '✅ Order Approved',
                'Order #${order.id.substring(0, 8)} has been approved successfully!',
                backgroundColor: Colors.green[100],
                colorText: Colors.green[800],
                duration: Duration(seconds: 3),
                icon: Icon(Icons.check_circle, color: Colors.green),
              );
            },
            icon: Icon(Icons.check_circle, color: Colors.white),
            label: Text('Approve Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersManagementSection(OrdersController ordersController) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Orders Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Get.to(() => OrdersManagementScreen());
                  },
                  icon: Icon(Icons.arrow_forward, size: 16),
                  label: Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Orders Stats
            Obx(() {
              return Column(
                children: [
                  // Order Status Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildOrderStatCard(
                          'Total Orders',
                          ordersController.totalOrders.toString(),
                          Icons.shopping_bag,
                          Colors.blue,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildOrderStatCard(
                          'Pending',
                          ordersController.pendingOrders.toString(),
                          Icons.pending,
                          Colors.orange,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildOrderStatCard(
                          'Approved',
                          ordersController.approvedOrders.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Product Order Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildOrderStatCard(
                          'Products Ordered',
                          ordersController.totalProductsOrdered.toString(),
                          Icons.inventory_2,
                          Colors.purple,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildOrderStatCard(
                          'Unique Products',
                          ordersController.totalUniqueProductsOrdered
                              .toString(),
                          Icons.category,
                          Colors.teal,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildOrderStatCard(
                          'Revenue',
                          '৳${ordersController.totalRevenue.toStringAsFixed(0)}',
                          Icons.monetization_on,
                          Colors.green[700]!,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
            SizedBox(height: 16),

            // Quick Actions for Orders
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Manage Orders',
                    Icons.manage_search,
                    Colors.purple,
                    () => Get.to(() => OrdersManagementScreen()),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'View Pending',
                    Icons.pending_actions,
                    Colors.orange,
                    () {
                      Get.to(() => OrdersManagementScreen());
                      // Auto-filter to pending orders after navigation
                      Future.delayed(Duration(milliseconds: 100), () {
                        try {
                          Get.find<OrdersController>()
                              .filterByStatus(OrderStatus.pending);
                        } catch (e) {
                          // Controller not found, ignore
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileMenu() {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: PopupMenuButton<String>(
        offset: Offset(0, 50),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            backgroundImage:
                user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null
                ? Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 22,
                  )
                : null,
          ),
        ),
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.person_outline, color: Colors.grey[700], size: 20),
                SizedBox(width: 12),
                Text('View Profile'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings_outlined,
                    color: Colors.grey[700], size: 20),
                SizedBox(width: 12),
                Text('Settings'),
              ],
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.red, size: 20),
                SizedBox(width: 12),
                Text(
                  'Log Out',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
        onSelected: (String value) {
          _handleUserMenuAction(value);
        },
      ),
    );
  }

  void _handleUserMenuAction(String action) {
    switch (action) {
      case 'profile':
        _showUserProfileDialog();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
      case 'logout':
        _showLogoutConfirmation();
        break;
    }
  }

  void _showUserProfileDialog() {
    final user = FirebaseAuth.instance.currentUser;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Text('Admin Profile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileRow('Email', user?.email ?? 'N/A'),
            SizedBox(height: 12),
            _buildProfileRow('User ID', user?.uid.substring(0, 8) ?? 'N/A'),
            SizedBox(height: 12),
            _buildProfileRow('Account Type', 'Administrator'),
            SizedBox(height: 12),
            _buildProfileRow(
                'Last Login', _formatLastLogin(user?.metadata.lastSignInTime)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatLastLogin(DateTime? lastLogin) {
    if (lastLogin == null) return 'N/A';

    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _showSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Settings'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications_outlined),
              title: Text('Notifications'),
              subtitle: Text('Manage notification preferences'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Info',
                  'Notification settings coming soon!',
                  backgroundColor: Colors.blue[100],
                  colorText: Colors.blue[800],
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.security_outlined),
              title: Text('Security'),
              subtitle: Text('Change password and security settings'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Info',
                  'Security settings coming soon!',
                  backgroundColor: Colors.blue[100],
                  colorText: Colors.blue[800],
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Help & Support'),
              subtitle: Text('Get help and contact support'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Info',
                  'Help & Support coming soon!',
                  backgroundColor: Colors.blue[100],
                  colorText: Colors.blue[800],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Text('Confirm Logout'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Are you sure you want to log out from the admin dashboard?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(Get.context!).pop(); // Close the dialog
              await _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      // Show loading
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text('Logging out...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Sign out from Google Sign In (if user logged in with Google)
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      } catch (googleError) {
        print('Google sign out error: $googleError');
      }

      // Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();

      // Small delay to ensure sign out completes
      await Future.delayed(Duration(milliseconds: 300));

      // Close loading dialog
      Get.back();

      // Navigate to login screen and clear all previous routes
      Get.offAllNamed(RouterConstant.loginScreen);

      // Show success message after navigation
      Future.delayed(Duration(milliseconds: 500), () {
        Get.snackbar(
          'Success',
          'You have been logged out successfully',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
          duration: Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } catch (e) {
      // Close loading dialog if still open
      try {
        Get.back();
      } catch (_) {}

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to log out: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildDashboardStats(AdminProductController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Products',
                        controller.totalProducts.value.toString(),
                        Icons.inventory,
                        AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Active Products',
                        controller.activeProducts.value.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AdminProductController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Add Product',
                    Icons.add_box,
                    AppColors.primary,
                    () => _showAddProductDialog(Get.context!, controller),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'View All',
                    Icons.list,
                    Colors.blue,
                    () => _showAllProductsDialog(Get.context!, controller),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentProducts(AdminProductController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      _showAllProductsDialog(Get.context!, controller),
                  child: Text(
                    'View All',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Obx(() {
              if (controller.products.isEmpty) {
                return SizedBox(
                  height: 80,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 48, color: Colors.grey[400]),
                        SizedBox(height: 8),
                        Text(
                          'No products yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.products.length > 5
                    ? 5
                    : controller.products.length,
                itemBuilder: (context, index) {
                  final product = controller.products[index];
                  return _buildProductTile(product, controller);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTile(
      HomeModel product, AdminProductController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, color: Colors.grey[500]),
                );
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title.replaceAll('"', ''),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '৳${(product.offerPrice ?? '0').replaceAll('"', '')}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _showEditProductDialog(Get.context!, controller, product);
              } else if (value == 'delete') {
                _showDeleteConfirmation(Get.context!, controller, product);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(
      BuildContext context, AdminProductController controller) {
    controller.clearForm();
    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(
        controller: controller,
        isEdit: false,
      ),
    );
  }

  void _showEditProductDialog(BuildContext context,
      AdminProductController controller, HomeModel product) {
    controller.fillFormForEdit(product);
    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(
        controller: controller,
        isEdit: true,
        product: product,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context,
      AdminProductController controller, HomeModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text(
            'Are you sure you want to delete "${product.title.replaceAll('"', '')}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteProduct(product.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAllProductsDialog(
      BuildContext context, AdminProductController controller) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: Obx(() {
                  if (controller.products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'No products available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.products.length,
                    itemBuilder: (context, index) {
                      final product = controller.products[index];
                      return _buildProductTile(product, controller);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductFormDialog extends StatelessWidget {
  final AdminProductController controller;
  final bool isEdit;
  final HomeModel? product;

  const _ProductFormDialog({
    required this.controller,
    required this.isEdit,
    this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? 'Edit Product' : 'Add New Product',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: controller.titleController,
                      label: 'Product Title',
                      icon: Icons.title,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: controller.imageController,
                      label: 'Image URL',
                      icon: Icons.image,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: controller.descriptionController,
                      label: 'Description',
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    // Category Selection Dropdown
                    _buildCategoryDropdown(controller),
                    SizedBox(height: 16),
                    Obx(() => controller.selectedCategory.value == 'special'
                        ? Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.regularPriceController,
                                  label: 'Regular Price',
                                  icon: Icons.attach_money,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.offerPriceController,
                                  label: 'Offer Price',
                                  icon: Icons.local_offer,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          )
                        : _buildTextField(
                            controller: controller.regularPriceController,
                            label: 'Price',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                          )),
                    SizedBox(height: 16),
                    // Conditional fields for Special category only
                    Obx(() => controller.selectedCategory.value == 'special'
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: controller.offPriceController,
                                      label: 'Discount %',
                                      icon: Icons.percent,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: controller.ratingController,
                                      label: 'Rating',
                                      icon: Icons.star,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.ratingController,
                                  label: 'Rating',
                                  icon: Icons.star,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          )),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (isEdit) {
                              controller.updateProduct(product!.id);
                            } else {
                              controller.addProduct();
                            }
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isEdit ? 'Update Product' : 'Add Product',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(AdminProductController controller) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedCategory.value,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
              hint: Row(
                children: [
                  Icon(Icons.category, color: AppColors.primary),
                  SizedBox(width: 12),
                  Text('Select Category'),
                ],
              ),
              items: controller.categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        color: _getCategoryColor(category),
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.selectedCategory.value = newValue;
                }
              },
            ),
          ),
        ));
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'outdoor':
        return Icons.outdoor_grill;
      case 'appliances':
        return Icons.kitchen;
      case 'furniture':
        return Icons.chair;
      case 'special':
        return Icons.local_offer;
      default:
        return Icons.category;
    }
  }

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
}
