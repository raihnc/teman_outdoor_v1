import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../services/firestore_service.dart';
import '../../core/constants/firestore_constants.dart';

class BookingRepository {
  final FirestoreService _firestoreService;

  BookingRepository(this._firestoreService);

  /// Membuat booking + update stok/popularitas produk dalam satu transaksi.
  /// Validasi stok dilakukan ulang di dalam transaksi (server-side rules
  /// tetap menjaga pricePerDay/totalPrice/quantity <= stock saat create).
  Future<void> createBookingWithStock(BookingModel booking) async {
    await _firestoreService.runTransaction((tx) async {
      final productDoc = await tx.get(
        _firestoreService.productRef(booking.productId),
      );
      if (!productDoc.exists) {
        throw Exception('Produk tidak ditemukan');
      }
      final productData = productDoc.data() as Map<String, dynamic>;
      final stock = (productData['stock'] ?? 0) as int;
      if (stock < booking.quantity) {
        throw Exception('Stok tidak mencukupi');
      }

      tx.set(_firestoreService.bookingsRef.doc(), booking.toMap());
      tx.update(_firestoreService.productRef(booking.productId), {
        'stock': stock - booking.quantity,
        'totalBooked': FieldValue.increment(booking.quantity),
      });
    });
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

  /// Update status sederhana (non-transaksi). Status & field yang boleh diubah
  /// penyewa dijaga oleh firestore.rules.
  Future<void> updateBookingStatus(
    String bookingId,
    String newStatus,
    String updatedBy,
  ) async {
    await _firestoreService.updateBooking(bookingId, {
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([
        _statusEntry(newStatus, updatedBy),
      ]),
    });
  }

  /// Batalkan booking + kembalikan stok produk dalam satu transaksi.
  /// Penyewa hanya bisa cancel dari status pending/confirmed (rules juga
  /// menegakkan hal ini); admin bisa cancel kapan saja via [asAdmin].
  Future<void> cancelBooking(
    String bookingId,
    String actorUid, {
    bool asAdmin = false,
  }) async {
    await _firestoreService.runTransaction((tx) async {
      final doc = await tx.get(_firestoreService.bookingRef(bookingId));
      if (!doc.exists) throw Exception('Booking tidak ditemukan');
      final data = doc.data() as Map<String, dynamic>;
      final currentStatus = data['status'] ?? '';
      if (!asAdmin &&
          currentStatus != FirestoreConstants.statusPending &&
          currentStatus != FirestoreConstants.statusConfirmed) {
        throw Exception('Booking tidak bisa dibatalkan pada status ini');
      }

      tx.update(_firestoreService.bookingRef(bookingId), {
        'status': FirestoreConstants.statusCancelled,
        'updatedAt': FieldValue.serverTimestamp(),
        'statusHistory': FieldValue.arrayUnion([
          _statusEntry(FirestoreConstants.statusCancelled, actorUid),
        ]),
      });
      await _restoreStock(tx, data);
    });
  }

  /// Tandai sudah dikembalikan + kembalikan stok produk (transaksi).
  Future<void> markReturned(String bookingId, String userId) async {
    await _firestoreService.runTransaction((tx) async {
      final doc = await tx.get(_firestoreService.bookingRef(bookingId));
      if (!doc.exists) throw Exception('Booking tidak ditemukan');
      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != userId) throw Exception('Bukan booking Anda');
      if (data['status'] != FirestoreConstants.statusPickedUp) {
        throw Exception('Booking belum diambil');
      }

      tx.update(_firestoreService.bookingRef(bookingId), {
        'status': FirestoreConstants.statusReturned,
        'updatedAt': FieldValue.serverTimestamp(),
        'statusHistory': FieldValue.arrayUnion([
          _statusEntry(FirestoreConstants.statusReturned, userId),
        ]),
      });
      await _restoreStock(tx, data);
    });
  }

  Future<void> markReviewed(String bookingId) async {
    await _firestoreService.updateBooking(bookingId, {'reviewed': true});
  }

  /// Tulis ulang stok produk sesuai quantity booking (tidak mengubah
  /// totalBooked — popularitas bersifat historis).
  Future<void> _restoreStock(Transaction tx, Map<String, dynamic> bookingData) async {
    final productId = bookingData['productId'] as String?;
    final quantity = (bookingData['quantity'] ?? 1) as int;
    if (productId == null || productId.isEmpty) return;

    final productDoc = await tx.get(_firestoreService.productRef(productId));
    if (!productDoc.exists) return;
    final productData = productDoc.data() as Map<String, dynamic>;
    final stock = (productData['stock'] ?? 0) as int;
    tx.update(_firestoreService.productRef(productId), {
      'stock': stock + quantity,
    });
  }

  Map<String, dynamic> _statusEntry(String status, String updatedBy) => {
    'status': status,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'updatedBy': updatedBy,
  };

  // ── Real-time streams ──
  Stream<List<BookingModel>> userBookingsStream(String userId) =>
      _firestoreService.getUserBookingsStream(userId)
          .map((snap) => snap.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList());

  Stream<List<BookingModel>> allBookingsStream() =>
      _firestoreService.allBookingsStream()
          .map((snap) => snap.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList());
}
