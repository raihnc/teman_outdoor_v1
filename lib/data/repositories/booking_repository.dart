import '../models/booking_model.dart';
import '../services/firestore_service.dart';
import '../../core/constants/firestore_constants.dart';

class BookingRepository {
  final FirestoreService _firestoreService;

  BookingRepository(this._firestoreService);

  Future<void> createBooking(BookingModel booking) async {
    await _firestoreService.createBooking(booking.toMap());
  }

  Future<List<BookingModel>> getUserBookings(
    String userId, {
    bool activeOnly = false,
  }) async {
    if (activeOnly) {
      final results = <BookingModel>[];
      for (final status in FirestoreConstants.statusOrder) {
        final snapshot = await _firestoreService.getUserBookings(
          userId,
          status: status,
        );
        results.addAll(
          snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)),
        );
      }
      return results;
    }
    final snapshot = await _firestoreService.getUserBookings(userId);
    return snapshot.docs
        .map((doc) => BookingModel.fromFirestore(doc))
        .toList();
  }

  Future<List<BookingModel>> getAllBookings({String? status}) async {
    final snapshot = await _firestoreService.getAllBookings(status: status);
    return snapshot.docs
        .map((doc) => BookingModel.fromFirestore(doc))
        .toList();
  }

  Future<BookingModel?> getBooking(String id) async {
    final doc = await _firestoreService.getBooking(id);
    if (!doc.exists) return null;
    return BookingModel.fromFirestore(doc);
  }

  Future<void> updateBookingStatus(
    String bookingId,
    String newStatus,
    String updatedBy,
  ) async {
    final historyEntry = {
      'status': newStatus,
      'timestamp': DateTime.now().toIso8601String(),
      'updatedBy': updatedBy,
    };
    await _firestoreService.updateBooking(bookingId, {
      'status': newStatus,
      'updatedAt': DateTime.now().toIso8601String(),
      'statusHistory': [historyEntry],
    });
  }

  Future<void> markReviewed(String bookingId) async {
    await _firestoreService.updateBooking(bookingId, {'reviewed': true});
  }
}
