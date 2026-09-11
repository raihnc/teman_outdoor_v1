import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String productId;
  final String productName;
  final String productThumbnail;
  final int pricePerDay;
  final DateTime pickupDate;
  final DateTime returnDate;
  final int duration;
  final int quantity;
  final int totalPrice;
  final String note;
  final String status;
  final List<Map<String, dynamic>> statusHistory;
  final bool reviewed;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    this.userName = '',
    this.userPhone = '',
    required this.productId,
    required this.productName,
    this.productThumbnail = '',
    required this.pricePerDay,
    required this.pickupDate,
    required this.returnDate,
    required this.duration,
    this.quantity = 1,
    required this.totalPrice,
    this.note = '',
    this.status = 'pending',
    this.statusHistory = const [],
    this.reviewed = false,
    required this.createdAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productThumbnail: data['productThumbnail'] ?? '',
      pricePerDay: data['pricePerDay'] ?? 0,
      pickupDate: (data['pickupDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      returnDate: (data['returnDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duration: data['duration'] ?? 1,
      quantity: data['quantity'] ?? 1,
      totalPrice: data['totalPrice'] ?? 0,
      note: data['note'] ?? '',
      status: data['status'] ?? 'pending',
      statusHistory: List<Map<String, dynamic>>.from(data['statusHistory'] ?? []),
      reviewed: data['reviewed'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'productId': productId,
      'productName': productName,
      'productThumbnail': productThumbnail,
      'pricePerDay': pricePerDay,
      'pickupDate': Timestamp.fromDate(pickupDate),
      'returnDate': Timestamp.fromDate(returnDate),
      'duration': duration,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'note': note,
      'status': status,
      'statusHistory': statusHistory,
      'reviewed': reviewed,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
