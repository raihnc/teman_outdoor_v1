import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../services/firestore_service.dart';
import '../../core/constants/firestore_constants.dart';

class ReviewRepository {
  final FirestoreService _firestoreService;

  ReviewRepository(this._firestoreService);

  /// Simpan ulasan + update rating produk + tandai booking sudah direview,
  /// semuanya dalam satu transaksi.
  Future<void> createReviewAndUpdateProduct(ReviewModel review) async {
    await _firestoreService.runTransaction((tx) async {
      final bookingDoc = await tx.get(
        _firestoreService.bookingRef(review.bookingId),
      );
      if (!bookingDoc.exists) throw Exception('Booking tidak ditemukan');
      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      if (bookingData['userId'] != review.userId) {
        throw Exception('Bukan booking Anda');
      }
      if (bookingData['status'] != FirestoreConstants.statusCompleted) {
        throw Exception('Ulasan hanya untuk booking yang sudah selesai');
      }

      tx.set(_firestoreService.reviewsRef.doc(), review.toMap());
      tx.update(_firestoreService.bookingRef(review.bookingId), {
        'reviewed': true,
      });
      await _updateProductRating(tx, review);
    });
  }

  Future<List<ReviewModel>> getProductReviews(String productId) async {
    final snapshot = await _firestoreService.getProductReviews(productId);
    return snapshot.docs
        .map((doc) => ReviewModel.fromFirestore(doc))
        .toList();
  }

  Stream<List<ReviewModel>> productReviewsStream(String productId) =>
      _firestoreService.productReviewsStream(productId)
          .map((snap) => snap.docs
              .map((doc) => ReviewModel.fromFirestore(doc))
              .toList());

  Stream<List<ReviewModel>> allReviewsStream() =>
      _firestoreService.allReviewsStream()
          .map((snap) => snap.docs
              .map((doc) => ReviewModel.fromFirestore(doc))
              .toList());

  Future<void> deleteReview(String id) async {
    await _firestoreService.deleteReview(id);
  }

  /// Rekomputasi averageRating & totalReviews produk berbasis data lama
  /// (dibaca dalam transaksi yang sama).
  Future<void> _updateProductRating(Transaction tx, ReviewModel review) async {
    final productDoc = await tx.get(_firestoreService.productRef(review.productId));
    if (!productDoc.exists) return;

    final data = productDoc.data() as Map<String, dynamic>;
    final totalReviews = (data['totalReviews'] ?? 0) as int;
    final averageRating = ((data['averageRating'] ?? 0) as num).toDouble();
    final newTotal = totalReviews + 1;
    final newAverage = ((averageRating * totalReviews) + review.rating) / newTotal;

    tx.update(_firestoreService.productRef(review.productId), {
      'totalReviews': newTotal,
      'averageRating': double.parse(newAverage.toStringAsFixed(2)),
    });
  }
}
