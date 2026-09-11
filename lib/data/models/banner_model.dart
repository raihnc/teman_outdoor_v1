import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final String linkType;
  final String linkValue;
  final bool isActive;
  final int sortOrder;

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.title = '',
    this.linkType = 'none',
    this.linkValue = '',
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      linkType: data['linkType'] ?? 'none',
      linkValue: data['linkValue'] ?? '',
      isActive: data['isActive'] ?? true,
      sortOrder: data['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'linkType': linkType,
      'linkValue': linkValue,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }
}
