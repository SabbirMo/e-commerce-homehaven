// ignore_for_file: avoid_types_as_parameter_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_haven/features/orders/model/order_model.dart';

class OrdersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var selectedStatus = Rxn<OrderStatus>();

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;

      QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .get();

      orders.value = querySnapshot.docs
          .map((doc) => OrderModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch orders: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus,
      {String? adminNotes}) async {
    try {
      isLoading.value = true;

      Map<String, dynamic> updateData = {
        'status': newStatus.toString().split('.').last,
        'adminNotes': adminNotes,
      };

      // Add timestamp for status changes
      String currentTime = DateTime.now().toIso8601String();
      if (newStatus == OrderStatus.approved) {
        updateData['approvedDate'] = currentTime;
        updateData['processingStarted'] = currentTime;
      } else if (newStatus == OrderStatus.processing) {
        updateData['processingDate'] = currentTime;
      } else if (newStatus == OrderStatus.shipped) {
        updateData['shippedDate'] = currentTime;
        updateData['estimatedDelivery'] =
            DateTime.now().add(Duration(days: 3)).toIso8601String();
      } else if (newStatus == OrderStatus.delivered) {
        updateData['deliveredDate'] = currentTime;
      } else if (newStatus == OrderStatus.cancelled) {
        updateData['cancelledDate'] = currentTime;
      }

      await _firestore.collection('orders').doc(orderId).update(updateData);

      // Update local orders list
      int orderIndex = orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        OrderModel updatedOrder = orders[orderIndex].copyWith(
          status: newStatus,
          adminNotes: adminNotes,
          approvedDate: newStatus == OrderStatus.approved
              ? DateTime.now()
              : orders[orderIndex].approvedDate,
          cancelledDate: newStatus == OrderStatus.cancelled
              ? DateTime.now()
              : orders[orderIndex].cancelledDate,
        );
        orders[orderIndex] = updatedOrder;
      }

      // Show success message with next steps
      String successMessage = _getStatusUpdateMessage(newStatus);
      Get.snackbar(
        '✅ Status Updated',
        successMessage,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        ' Update Failed',
        'Failed to update order status: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _getStatusUpdateMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.approved:
        return 'Order approved! Customer will be notified. Next: Start Processing';
      case OrderStatus.processing:
        return 'Order is now being processed. Prepare items for shipping.';
      case OrderStatus.shipped:
        return 'Order shipped! Estimated delivery in 3 days. Customer notified.';
      case OrderStatus.delivered:
        return 'Order delivered successfully! Transaction completed.';
      case OrderStatus.cancelled:
        return 'Order cancelled. Customer will be refunded if applicable.';
      default:
        return 'Order status updated to ${status.displayName}';
    }
  }

  List<OrderModel> get filteredOrders {
    // If selectedStatus is null or we want to show all orders, return all
    if (selectedStatus.value == null) {
      return orders;
    }

    switch (selectedStatus.value) {
      case OrderStatus.pending:
        final pendingList = orders
            .where((order) => order.status == OrderStatus.pending)
            .toList();
        return pendingList;
      case OrderStatus.approved:
        final approvedList = orders
            .where((order) => order.status == OrderStatus.approved)
            .toList();
        return approvedList;
      case OrderStatus.processing:
        final processingList = orders
            .where((order) => order.status == OrderStatus.processing)
            .toList();
        return processingList;
      case OrderStatus.shipped:
        final shippedList = orders
            .where((order) => order.status == OrderStatus.shipped)
            .toList();
        return shippedList;
      case OrderStatus.delivered:
        final deliveredList = orders
            .where((order) => order.status == OrderStatus.delivered)
            .toList();
        return deliveredList;
      case OrderStatus.cancelled:
        final cancelledList = orders
            .where((order) => order.status == OrderStatus.cancelled)
            .toList();
        return cancelledList;
      default:
        return orders; // Show all orders
    }
  }

  int get totalOrders => orders.length;
  int get pendingOrders =>
      orders.where((order) => order.status == OrderStatus.pending).length;
  int get approvedOrders =>
      orders.where((order) => order.status == OrderStatus.approved).length;
  int get cancelledOrders =>
      orders.where((order) => order.status == OrderStatus.cancelled).length;

  double get totalRevenue => orders
      .where((order) => order.status != OrderStatus.cancelled)
      .fold(0.0, (sum, order) => sum + order.totalAmount);

  // Product-based order statistics
  int get totalProductsOrdered {
    return orders.where((order) => order.status != OrderStatus.cancelled).fold(
        0,
        (sum, order) =>
            sum +
            order.items.fold(0, (itemSum, item) => itemSum + item.quantity));
  }

  int get totalUniqueProductsOrdered {
    Set<String> uniqueProductIds = {};
    for (var order in orders) {
      if (order.status != OrderStatus.cancelled) {
        for (var item in order.items) {
          uniqueProductIds.add(item.id); // Assuming cart item has product id
        }
      }
    }
    return uniqueProductIds.length;
  }

  List<Map<String, dynamic>> get topOrderedProducts {
    Map<String, Map<String, dynamic>> productStats = {};

    // Collect product statistics from orders
    for (var order in orders) {
      if (order.status != OrderStatus.cancelled) {
        for (var item in order.items) {
          String productKey = '${item.name}_${item.id}';
          if (productStats.containsKey(productKey)) {
            productStats[productKey]!['quantity'] += item.quantity;
            productStats[productKey]!['orders'] += 1;
            productStats[productKey]!['revenue'] +=
                (item.price * item.quantity);
          } else {
            productStats[productKey] = {
              'name': item.name,
              'image': item.image,
              'quantity': item.quantity,
              'orders': 1,
              'revenue': (item.price * item.quantity),
              'price': item.price,
            };
          }
        }
      }
    }

    // Convert to list and sort by quantity ordered
    List<Map<String, dynamic>> topProducts = productStats.values.toList();
    topProducts.sort((a, b) => b['quantity'].compareTo(a['quantity']));

    return topProducts.take(5).toList(); // Return top 5 products
  }

  void filterByStatus(OrderStatus status) {
    selectedStatus.value = status;
  }

  void showAllOrders() {
    selectedStatus.value = null; // Set to null to show all orders
  }

  void showOrderActionDialog(OrderModel order) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: order.status.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag,
                        color: order.status.color, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.id.substring(0, 8)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Customer: ${order.customerName}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: order.status.color,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        order.status.displayName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Details
                      _buildOrderDetailsSection(order),
                      SizedBox(height: 20),

                      // Progress Timeline
                      _buildOrderTimeline(order),
                      SizedBox(height: 20),

                      // Action Buttons
                      _buildActionButtons(order),
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

  Widget _buildOrderDetailsSection(OrderModel order) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Order Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildDetailRow(
              'Total Amount', '৳${order.totalAmount.toStringAsFixed(0)}'),
          _buildDetailRow('Items Count', '${order.items.length} items'),
          _buildDetailRow('Payment Method', order.paymentMethod.toUpperCase()),
          _buildDetailRow('Phone', order.customerPhone),
          _buildDetailRow('Address', '${order.shippingAddress}, ${order.city}'),
          if (order.specialInstructions != null &&
              order.specialInstructions!.isNotEmpty)
            _buildDetailRow('Special Instructions', order.specialInstructions!),
          if (order.adminNotes != null && order.adminNotes!.isNotEmpty)
            _buildDetailRow('Admin Notes', order.adminNotes!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline(OrderModel order) {
    List<Map<String, dynamic>> timeline = [
      {
        'status': OrderStatus.pending,
        'title': 'Order Placed',
        'subtitle': 'Customer placed the order',
        'date': order.orderDate,
        'completed': true,
      },
      {
        'status': OrderStatus.approved,
        'title': 'Order Approved',
        'subtitle': 'Admin approved the order',
        'date': order.approvedDate,
        'completed': order.status.index >= OrderStatus.approved.index,
      },
      {
        'status': OrderStatus.processing,
        'title': 'Processing',
        'subtitle': 'Order is being prepared',
        'date': null, // Add processingDate to model if needed
        'completed': order.status.index >= OrderStatus.processing.index,
      },
      {
        'status': OrderStatus.shipped,
        'title': 'Shipped',
        'subtitle': 'Order dispatched for delivery',
        'date': null, // Add shippedDate to model if needed
        'completed': order.status.index >= OrderStatus.shipped.index,
      },
      {
        'status': OrderStatus.delivered,
        'title': 'Delivered',
        'subtitle': 'Order delivered to customer',
        'date': null, // Add deliveredDate to model if needed
        'completed': order.status.index >= OrderStatus.delivered.index,
      },
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Order Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...timeline
              .map((step) => _buildTimelineStep(
                    step['status'] as OrderStatus,
                    step['title'] as String,
                    step['subtitle'] as String,
                    step['date'] as DateTime?,
                    step['completed'] as bool,
                    step == timeline.last,
                  ))
              // ignore: unnecessary_to_list_in_spreads
              .toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(OrderStatus status, String title, String subtitle,
      DateTime? date, bool completed, bool isLast) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: completed ? status.color : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                completed ? Icons.check : Icons.radio_button_unchecked,
                color: Colors.white,
                size: 16,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: completed ? status.color : Colors.grey[300],
              ),
          ],
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: completed ? Colors.black87 : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (date != null)
                  Text(
                    _formatDateTime(date),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(OrderModel order) {
    List<Widget> buttons = [];

    if (order.status == OrderStatus.pending) {
      buttons.addAll([
        _buildActionButton(
          'Approve Order',
          Icons.check_circle,
          Colors.green,
          () {
            Get.back();
            _showApproveDialog(order);
          },
        ),
        SizedBox(height: 12),
        _buildActionButton(
          'Cancel Order',
          Icons.cancel,
          Colors.red,
          () {
            Get.back();
            _showCancelDialog(order);
          },
        ),
      ]);
    } else if (order.status == OrderStatus.approved) {
      buttons.add(
        _buildActionButton(
          'Start Processing',
          Icons.play_circle_filled,
          Colors.blue,
          () {
            Get.back();
            _showProcessingDialog(order);
          },
        ),
      );
    } else if (order.status == OrderStatus.processing) {
      buttons.add(
        _buildActionButton(
          'Mark as Shipped',
          Icons.local_shipping,
          Colors.purple,
          () {
            Get.back();
            _showShippingDialog(order);
          },
        ),
      );
    } else if (order.status == OrderStatus.shipped) {
      buttons.add(
        _buildActionButton(
          'Mark as Delivered',
          Icons.check_circle_outline,
          Colors.teal,
          () {
            Get.back();
            _showDeliveryDialog(order);
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons,
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showApproveDialog(OrderModel order) {
    final TextEditingController notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Approve Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to approve this order?'),
            SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Admin Notes (Optional)',
                border: OutlineInputBorder(),
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
          ElevatedButton(
            onPressed: () {
              Get.back();
              updateOrderStatus(
                order.id,
                OrderStatus.approved,
                adminNotes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Approve Order'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(OrderModel order) {
    final TextEditingController reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel this order?'),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Cancellation Reason (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              updateOrderStatus(
                order.id,
                OrderStatus.cancelled,
                adminNotes: reasonController.text.trim().isEmpty
                    ? null
                    : reasonController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Cancel Order'),
          ),
        ],
      ),
    );
  }

  void _showProcessingDialog(OrderModel order) {
    final TextEditingController notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.play_circle_filled, color: Colors.blue),
            SizedBox(width: 12),
            Text('Start Processing'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Order will be marked as "Processing".\nThis means the order is being prepared for shipment.'),
            SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Processing Notes (Optional)',
                hintText:
                    'e.g., Items being packed, expected completion time...',
                border: OutlineInputBorder(),
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
          ElevatedButton(
            onPressed: () {
              Get.back();
              updateOrderStatus(
                order.id,
                OrderStatus.processing,
                adminNotes: notesController.text.trim().isEmpty
                    ? 'Order processing started'
                    : notesController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Start Processing'),
          ),
        ],
      ),
    );
  }

  void _showShippingDialog(OrderModel order) {
    final TextEditingController trackingController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.local_shipping, color: Colors.purple),
            SizedBox(width: 12),
            Text('Mark as Shipped'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Order will be marked as "Shipped".\nCustomer will be notified with tracking information.'),
            SizedBox(height: 16),
            TextField(
              controller: trackingController,
              decoration: InputDecoration(
                labelText: 'Tracking Number (Optional)',
                hintText: 'e.g., TRK123456789',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.track_changes),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Shipping Notes (Optional)',
                hintText: 'e.g., Courier service, expected delivery date...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              String notes = 'Order shipped';
              if (trackingController.text.trim().isNotEmpty) {
                notes += ' - Tracking: ${trackingController.text.trim()}';
              }
              if (notesController.text.trim().isNotEmpty) {
                notes += ' - ${notesController.text.trim()}';
              }
              updateOrderStatus(
                order.id,
                OrderStatus.shipped,
                adminNotes: notes,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Mark as Shipped'),
          ),
        ],
      ),
    );
  }

  void _showDeliveryDialog(OrderModel order) {
    final TextEditingController notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.teal),
            SizedBox(width: 12),
            Text('Mark as Delivered'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will complete the order. Make sure the customer has received the items.',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Delivery Notes (Optional)',
                hintText: 'e.g., Delivered to customer, signed by...',
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
          ElevatedButton(
            onPressed: () {
              Get.back();
              updateOrderStatus(
                order.id,
                OrderStatus.delivered,
                adminNotes: notesController.text.trim().isEmpty
                    ? 'Order delivered successfully'
                    : notesController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: Text('Mark as Delivered'),
          ),
        ],
      ),
    );
  }
}
