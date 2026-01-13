import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_haven/features/orders/model/order_model.dart';
import 'package:home_haven/features/cart/model/cart_model.dart';

class CustomerOrdersController extends GetxController {
  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMockOrders();
  }

  // For now, using mock data. In a real app, you'd fetch from Firebase
  void loadMockOrders() {
    isLoading.value = true;
    
    // Simulate loading delay
    Future.delayed(Duration(milliseconds: 500), () {
      orders.value = [
        OrderModel(
          id: 'ORD-001',
          userId: FirebaseAuth.instance.currentUser?.uid ?? 'user123',
          customerName: 'John Doe',
          customerEmail: 'john.doe@example.com',
          customerPhone: '+1 234 567 8900',
          shippingAddress: '123 Main Street, Apt 4B',
          city: 'New York',
          state: 'NY',
          zipCode: '10001',
          country: 'USA',
          paymentMethod: 'Credit Card',
          specialInstructions: 'Please ring doorbell twice',
          items: [
            CartModel(
              id: '1',
              name: 'Modern Coffee Table',
              image: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
              price: 299.99,
              originalPrice: 349.99,
              discountPercentage: '14%',
              color: 'Brown',
              quantity: 1,
            ),
            CartModel(
              id: '2',
              name: 'Wireless Bluetooth Speaker',
              image: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400',
              price: 79.99,
              originalPrice: 99.99,
              discountPercentage: '20%',
              color: 'Black',
              quantity: 2,
            ),
          ],
          subtotal: 459.97,
          deliveryFee: 15.00,
          totalAmount: 474.97,
          status: OrderStatus.pending,
          orderDate: DateTime.now().subtract(Duration(days: 2)),
        ),
        OrderModel(
          id: 'ORD-002',
          userId: FirebaseAuth.instance.currentUser?.uid ?? 'user123',
          customerName: 'John Doe',
          customerEmail: 'john.doe@example.com',
          customerPhone: '+1 234 567 8900',
          shippingAddress: '123 Main Street, Apt 4B',
          city: 'New York',
          state: 'NY',
          zipCode: '10001',
          country: 'USA',
          paymentMethod: 'PayPal',
          items: [
            CartModel(
              id: '3',
              name: 'Outdoor Patio Set',
              image: 'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=400',
              price: 599.99,
              originalPrice: 699.99,
              discountPercentage: '14%',
              color: 'Natural',
              quantity: 1,
            ),
          ],
          subtotal: 599.99,
          deliveryFee: 25.00,
          totalAmount: 624.99,
          status: OrderStatus.shipped,
          orderDate: DateTime.now().subtract(Duration(days: 7)),
        ),
        OrderModel(
          id: 'ORD-003',
          userId: FirebaseAuth.instance.currentUser?.uid ?? 'user123',
          customerName: 'John Doe',
          customerEmail: 'john.doe@example.com',
          customerPhone: '+1 234 567 8900',
          shippingAddress: '123 Main Street, Apt 4B',
          city: 'New York',
          state: 'NY',
          zipCode: '10001',
          country: 'USA',
          paymentMethod: 'Credit Card',
          items: [
            CartModel(
              id: '4',
              name: 'Smart Refrigerator',
              image: 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=400',
              price: 1299.99,
              originalPrice: 1599.99,
              discountPercentage: '19%',
              color: 'Stainless Steel',
              quantity: 1,
            ),
            CartModel(
              id: '5',
              name: 'Ergonomic Office Chair',
              image: 'https://images.unsplash.com/photo-1592078615290-033ee584e267?w=400',
              price: 349.99,
              originalPrice: 399.99,
              discountPercentage: '12%',
              color: 'Black',
              quantity: 1,
            ),
          ],
          subtotal: 1649.98,
          deliveryFee: 50.00,
          totalAmount: 1699.98,
          status: OrderStatus.delivered,
          orderDate: DateTime.now().subtract(Duration(days: 15)),
        ),
      ];
      isLoading.value = false;
    });
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      isLoading.value = true;
      
      // Find the order
      int orderIndex = orders.indexWhere((order) => order.id == orderId);
      if (orderIndex == -1) {
        Get.snackbar('Error', 'Order not found');
        return;
      }

      OrderModel order = orders[orderIndex];
      
      // Check if order can be cancelled
      if (order.status != OrderStatus.pending) {
        Get.snackbar(
          'Cannot Cancel',
          'Only pending orders can be cancelled',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[800],
        );
        return;
      }

      // Update order status to cancelled
      OrderModel updatedOrder = order.copyWith(
        status: OrderStatus.cancelled,
        cancelledDate: DateTime.now(),
      );

      orders[orderIndex] = updatedOrder;
      
      Get.snackbar(
        'Order Cancelled',
        'Your order has been cancelled successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        icon: Icon(Icons.check_circle, color: Colors.green[600]),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel order: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  void refreshOrders() {
    loadMockOrders();
  }
}