import 'package:flutter/material.dart';
import 'package:home_haven/features/cart/model/cart_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String shippingAddress;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String paymentMethod;
  final String? specialInstructions;
  final List<CartModel> items;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? approvedDate;
  final DateTime? cancelledDate;
  final String? adminNotes;

  OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.shippingAddress,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.paymentMethod,
    this.specialInstructions,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.approvedDate,
    this.cancelledDate,
    this.adminNotes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      shippingAddress: json['shippingAddress'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      specialInstructions: json['specialInstructions'],
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartModel.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      orderDate:
          DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'])
          : null,
      cancelledDate: json['cancelledDate'] != null
          ? DateTime.parse(json['cancelledDate'])
          : null,
      adminNotes: json['adminNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'paymentMethod': paymentMethod,
      'specialInstructions': specialInstructions,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'orderDate': orderDate.toIso8601String(),
      'approvedDate': approvedDate?.toIso8601String(),
      'cancelledDate': cancelledDate?.toIso8601String(),
      'adminNotes': adminNotes,
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? shippingAddress,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? paymentMethod,
    String? specialInstructions,
    List<CartModel>? items,
    double? subtotal,
    double? deliveryFee,
    double? totalAmount,
    OrderStatus? status,
    DateTime? orderDate,
    DateTime? approvedDate,
    DateTime? cancelledDate,
    String? adminNotes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      approvedDate: approvedDate ?? this.approvedDate,
      cancelledDate: cancelledDate ?? this.cancelledDate,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }
}

enum OrderStatus {
  pending,
  approved,
  processing,
  shipped,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.approved:
        return 'Approved';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.approved:
        return Colors.green;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.teal;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
