class HomeModel {
  final String id;
  final String image;
  final String title;
  final String? offerPrice;
  final String regularPrice;
  final String rating;
  final String? offPrice;
  final String description;
  final String category;
  final bool isActive;

  HomeModel({
    required this.id,
    required this.image,
    required this.title,
    this.offerPrice,
    required this.regularPrice,
    required this.rating,
    this.offPrice,
    this.description = '',
    required this.category,
    this.isActive = true,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      id: json['id'] ?? '',
      image: json['image'] ?? '',
      title: json['title'] ?? '',
      offerPrice: json['offerPrice'],
      regularPrice: json['regularPrice'] ?? '0.0',
      rating: json['rating'] ?? '0.0',
      offPrice: json['offPrice'],
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'offerPrice': offerPrice,
      'regularPrice': regularPrice,
      'rating': rating,
      'offPrice': offPrice,
      'description': description,
      'category': category,
      'isActive': isActive,
    };
  }
}
