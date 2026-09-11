import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String productId;
  final String bookingId;
  final int rating;
  final String comment;
  final List<String> photos;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    this.userName = '',
    this.userPhotoUrl = '',
    required this.productId,
    required this.bookingId,
    required this.rating,
    this.comment = '',
    this.photos = const [],
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      productId: data['productId'] ?? '',
      bookingId: data['bookingId'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'productId': productId,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
