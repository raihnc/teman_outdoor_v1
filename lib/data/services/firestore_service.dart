import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _users => _db.collection(FirestoreConstants.usersCollection);
  CollectionReference get _products => _db.collection(FirestoreConstants.productsCollection);
  CollectionReference get _bookings => _db.collection(FirestoreConstants.bookingsCollection);
  CollectionReference get _reviews => _db.collection(FirestoreConstants.reviewsCollection);
  CollectionReference get _categories => _db.collection(FirestoreConstants.categoriesCollection);

  CollectionReference get bookingsRef => _bookings;
  CollectionReference get reviewsRef => _reviews;
  DocumentReference bookingRef(String id) => _bookings.doc(id);
  DocumentReference productRef(String id) => _products.doc(id);
  DocumentReference userRef(String uid) => _users.doc(uid);

  // Transaksi untuk operasi yang mengubah beberapa dokumen sekaligus
  // (booking + stok produk, review + rating produk).
  Future<T> runTransaction<T>(Future<T> Function(Transaction) action) =>
      _db.runTransaction(action);

  // Streams untuk real-time update (pengganti push notification di v1.0)
  Stream<QuerySnapshot> getUserBookingsStream(String userId) =>
      _bookings.where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots();

  Stream<QuerySnapshot> allBookingsStream() =>
      _bookings.orderBy('createdAt', descending: true).snapshots();

  // ── Streams produk ──
  Stream<QuerySnapshot> activeProductsStream({
    String? category,
    String? orderBy,
    bool descending = false,
    int limit = 20,
  }) {
    Query query = _products.where('isActive', isEqualTo: true);
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    return query.orderBy(orderBy ?? 'createdAt', descending: descending)
        .limit(limit)
        .snapshots();
  }

  Stream<QuerySnapshot> popularProductsStream({int limit = 6}) =>
      activeProductsStream(orderBy: 'totalBooked', descending: true, limit: limit);

  Stream<QuerySnapshot> newProductsStream({int limit = 6}) =>
      activeProductsStream(orderBy: 'createdAt', descending: true, limit: limit);

  Stream<DocumentSnapshot> productStream(String id) =>
      _products.doc(id).snapshots();

  // ── Streams ulasan ──
  Stream<QuerySnapshot> productReviewsStream(String productId) =>
      _reviews.where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .snapshots();

  Stream<QuerySnapshot> allReviewsStream() =>
      _reviews.orderBy('createdAt', descending: true).snapshots();

  // ── Streams kategori ──
  Stream<QuerySnapshot> activeCategoriesStream() =>
      _categories.where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .snapshots();

  // ── Stream wishlist ──
  Stream<DocumentSnapshot> wishlistStream(String uid) =>
      _users.doc(uid).collection(FirestoreConstants.wishlistSubcollection)
          .doc('list')
          .snapshots();

  // Users
  Future<DocumentSnapshot> getUser(String uid) => _users.doc(uid).get();

  Future<void> createUser(String uid, Map<String, dynamic> data) =>
      _users.doc(uid).set(data);

  Future<void> updateUser(String uid, Map<String, dynamic> data) =>
      _users.doc(uid).update(data);

  // Products
  Future<QuerySnapshot> getProducts({
    String? category,
    String? orderBy,
    bool descending = false,
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    Query query = _products.where('isActive', isEqualTo: true);
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    query = query.orderBy(orderBy ?? 'createdAt', descending: descending);
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }
    return query.limit(limit).get();
  }

  Future<QuerySnapshot> getPopularProducts({int limit = 6}) =>
      _products.where('isActive', isEqualTo: true)
          .orderBy('totalBooked', descending: true)
          .limit(limit)
          .get();

  Future<QuerySnapshot> getNewProducts({int limit = 6}) =>
      _products.where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

  Future<DocumentSnapshot> getProduct(String id) => _products.doc(id).get();

  Future<void> createProduct(Map<String, dynamic> data) =>
      _products.add(data);

  Future<void> updateProduct(String id, Map<String, dynamic> data) =>
      _products.doc(id).update(data);

  Future<void> deleteProduct(String id) =>
      _products.doc(id).update({'isActive': false});

  // Bookings
  Future<void> createBooking(Map<String, dynamic> data) =>
      _bookings.add(data);

  Future<QuerySnapshot> getUserBookings(String userId, {String? status}) {
    Query query = _bookings.where('userId', isEqualTo: userId);
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query.orderBy('createdAt', descending: true).get();
  }

  Future<QuerySnapshot> getAllBookings({String? status}) {
    Query query = _bookings;
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query.orderBy('createdAt', descending: true).get();
  }

  Future<DocumentSnapshot> getBooking(String id) => _bookings.doc(id).get();

  Future<void> updateBooking(String id, Map<String, dynamic> data) =>
      _bookings.doc(id).update(data);

  // Reviews
  Future<void> createReview(Map<String, dynamic> data) =>
      _reviews.add(data);

  Future<QuerySnapshot> getProductReviews(String productId) =>
      _reviews.where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();

  Future<void> deleteReview(String id) => _reviews.doc(id).delete();

  // Categories
  Future<QuerySnapshot> getActiveCategories() =>
      _categories.where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .get();

  // Wishlist
  Future<DocumentSnapshot> getWishlist(String uid) =>
      _users.doc(uid).collection(FirestoreConstants.wishlistSubcollection).doc('list').get();

  Future<void> toggleWishlist(String uid, String productId, bool isAdd) {
    return _users.doc(uid).collection(FirestoreConstants.wishlistSubcollection)
        .doc('list')
        .set({
      'items': isAdd
          ? FieldValue.arrayUnion([productId])
          : FieldValue.arrayRemove([productId]),
    }, SetOptions(merge: true));
  }
}
