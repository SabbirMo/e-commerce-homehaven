class CartModel {
  final String id;
  final String name;
  final String image;
  final double price;
  final double originalPrice;
  final String discountPercentage;
  final String color;
  int quantity;

  CartModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.originalPrice,
    required this.discountPercentage,
    required this.color,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      originalPrice: double.tryParse(json['originalPrice'].toString()) ?? 0.0,
      discountPercentage: json['discountPercentage'] ?? '',
      color: json['color'] ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
      'color': color,
      'quantity': quantity,
    };
  }
}
