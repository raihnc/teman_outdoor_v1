import '../models/review_model.dart';
import '../services/firestore_service.dart';

class ReviewRepository {
  final FirestoreService _firestoreService;

  ReviewRepository(this._firestoreService);

  Future<void> createReview(ReviewModel review) async {
    await _firestoreService.createReview(review.toMap());
  }

  Future<List<ReviewModel>> getProductReviews(String productId) async {
    final snapshot = await _firestoreService.getProductReviews(productId);
    return snapshot.docs
        .map((doc) => ReviewModel.fromFirestore(doc))
        .toList();
  }

  Future<void> deleteReview(String id) async {
    await _firestoreService.deleteReview(id);
  }
}
