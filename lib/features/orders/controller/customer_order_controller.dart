// controller/customer_order_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/order_model.dart';

class CustomerOrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var customerOrders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var selectedFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomerOrders();
  }

  Future<void> fetchCustomerOrders() async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Authentication Error', 'Please log in first',
            backgroundColor: Colors.red[100], colorText: Colors.red[800]);
        return;
      }

      try {
        QuerySnapshot snapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('orderDate', descending: true)
            .get();

        if (snapshot.docs.isEmpty) {
          customerOrders.clear();
        } else {
          List<OrderModel> orders = [];

          for (var doc in snapshot.docs) {
            try {
              var data = doc.data() as Map<String, dynamic>;

              var order = OrderModel.fromJson({
                'id': doc.id,
                ...data,
              });

              orders.add(order);
            } catch (e) {
              Get.snackbar('Error', 'Failed to fetch orders: ${e.toString()}',
                  backgroundColor: Colors.red[100], colorText: Colors.red[800]);
              return;
            }
          }

          customerOrders.value = orders;
        }
      } catch (firestoreError) {
        if (firestoreError.toString().contains('index')) {
          try {
            QuerySnapshot snapshot = await _firestore
                .collection('orders')
                .where('userId', isEqualTo: user.uid)
                .get();

            customerOrders.value = snapshot.docs
                .map((doc) => OrderModel.fromJson({
                      'id': doc.id,
                      ...doc.data() as Map<String, dynamic>,
                    }))
                .toList();

            // Sort locally
            customerOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          } catch (fallbackError) {
            rethrow;
          }
        } else {
          rethrow;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch orders: ${e.toString()}',
          backgroundColor: Colors.red[100], colorText: Colors.red[800]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      isLoading.value = true;
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancelledDate': DateTime.now().toIso8601String(),
        'adminNotes': 'Cancelled by customer',
      });

      final index = customerOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        customerOrders[index] = customerOrders[index].copyWith(
          status: OrderStatus.cancelled,
          cancelledDate: DateTime.now(),
          adminNotes: 'Cancelled by customer',
        );
      }

      Get.snackbar('Success', 'Order cancelled',
          backgroundColor: Colors.orange[100], colorText: Colors.orange[800]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel order',
          backgroundColor: Colors.red[100], colorText: Colors.red[800]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restoreOrder(String orderId) async {
    try {
      isLoading.value = true;

      // Update order status back to pending
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'pending',
        'cancelledDate': null,
        'adminNotes': 'Restored by customer',
        'orderDate': DateTime.now()
            .toIso8601String(), // Update order date to current time
      });

      // Update local order data
      final index = customerOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        customerOrders[index] = customerOrders[index].copyWith(
          status: OrderStatus.pending,
          cancelledDate: null,
          adminNotes: 'Restored by customer',
          orderDate: DateTime.now(),
        );
      }

      Get.snackbar(
        'Success',
        'Order restored and placed again',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to restore order: ${e.toString()}',
          backgroundColor: Colors.red[100], colorText: Colors.red[800]);
    } finally {
      isLoading.value = false;
    }
  }

  List<OrderModel> get filteredOrders {
    switch (selectedFilter.value) {
      case 'pending':
        return customerOrders
            .where((o) => o.status == OrderStatus.pending)
            .toList();
      case 'processing':
        return customerOrders
            .where((o) =>
                o.status == OrderStatus.processing ||
                o.status == OrderStatus.approved ||
                o.status == OrderStatus.shipped)
            .toList();
      case 'delivered':
        return customerOrders
            .where((o) => o.status == OrderStatus.delivered)
            .toList();
      case 'cancelled':
        return customerOrders
            .where((o) => o.status == OrderStatus.cancelled)
            .toList();
      default:
        return customerOrders;
    }
  }

  void filterByStatus(String status) => selectedFilter.value = status;

  int get totalOrders => customerOrders.length;
  int get pendingOrders =>
      customerOrders.where((o) => o.status == OrderStatus.pending).length;
  int get processingOrders => customerOrders
      .where((o) =>
          o.status == OrderStatus.processing ||
          o.status == OrderStatus.approved ||
          o.status == OrderStatus.shipped)
      .length;
  int get deliveredOrders =>
      customerOrders.where((o) => o.status == OrderStatus.delivered).length;
  int get cancelledOrders =>
      customerOrders.where((o) => o.status == OrderStatus.cancelled).length;

  double get totalSpent => customerOrders
      .where((o) => o.status != OrderStatus.cancelled)
      // ignore: avoid_types_as_parameter_names
      .fold(0, (sum, o) => sum + o.totalAmount);

  // Check if order can be restored (only cancelled orders can be restored)
  bool canRestoreOrder(OrderModel order) {
    return order.status == OrderStatus.cancelled;
  }

  // Debug method to check Firebase collection
  Future<void> debugFirebaseOrders() async {
    try {
      // Check total orders in collection
      QuerySnapshot allOrders = await _firestore.collection('orders').get();

      if (allOrders.docs.isNotEmpty) {
        for (var doc in allOrders.docs.take(3)) {
          doc.data() as Map<String, dynamic>;
        }
      }

      // Check current user
      final user = _auth.currentUser;
      if (user != null) {
        // Check orders for current user
        QuerySnapshot userOrders = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .get();
        debugPrint('📋 Orders for current user: ${userOrders.docs.length}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to debug Firebase orders: ${e.toString()}',
          backgroundColor: Colors.red[100], colorText: Colors.red[800]);
    }
  }
}
