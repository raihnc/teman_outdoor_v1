import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final int pricePerDay;
  final String category;
  final List<String> images;
  final String thumbnailUrl;
  final int stock;
  final Map<String, dynamic> specs;
  final double averageRating;
  final int totalReviews;
  final int totalBooked;
  final bool isActive;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerDay,
    required this.category,
    this.images = const [],
    this.thumbnailUrl = '',
    this.stock = 0,
    this.specs = const {},
    this.averageRating = 0,
    this.totalReviews = 0,
    this.totalBooked = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final images = List<String>.from(data['images'] ?? []);
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      pricePerDay: data['pricePerDay'] ?? 0,
      category: data['category'] ?? '',
      images: images,
      thumbnailUrl: data['thumbnailUrl'] ?? (images.isNotEmpty ? images.first : ''),
      stock: data['stock'] ?? 0,
      specs: Map<String, dynamic>.from(data['specs'] ?? {}),
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      totalBooked: data['totalBooked'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'pricePerDay': pricePerDay,
      'category': category,
      'images': images,
      'thumbnailUrl': thumbnailUrl,
      'stock': stock,
      'specs': specs,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'totalBooked': totalBooked,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  ProductModel copyWith({
    String? name,
    String? description,
    int? pricePerDay,
    String? category,
    List<String>? images,
    String? thumbnailUrl,
    int? stock,
    Map<String, dynamic>? specs,
    double? averageRating,
    int? totalReviews,
    int? totalBooked,
    bool? isActive,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      category: category ?? this.category,
      images: images ?? this.images,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      stock: stock ?? this.stock,
      specs: specs ?? this.specs,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalBooked: totalBooked ?? this.totalBooked,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
