import '../models/product_model.dart';
import '../services/firestore_service.dart';

class WishlistRepository {
  final FirestoreService _firestoreService;

  WishlistRepository(this._firestoreService);

  Future<List<String>> getWishlistIds(String uid) async {
    final doc = await _firestoreService.getWishlist(uid);
    if (!doc.exists) return [];
    final data = doc.data() as Map<String, dynamic>?;
    return List<String>.from(data?['items'] ?? []);
  }

  /// Stream id wishlist — memicu reload produk saat user menambah/menghapus.
  Stream<List<String>> wishlistIdsStream(String uid) =>
      _firestoreService.wishlistStream(uid).map((doc) {
        if (!doc.exists) return <String>[];
        final data = doc.data() as Map<String, dynamic>?;
        return List<String>.from(data?['items'] ?? []);
      });

  Future<void> toggleWishlist(String uid, String productId, bool isAdd) async {
    await _firestoreService.toggleWishlist(uid, productId, isAdd);
  }

  Future<List<ProductModel>> getWishlistProducts(String uid) async {
    final ids = await getWishlistIds(uid);
    return getProductsByIds(ids);
  }

  Future<List<ProductModel>> getProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final products = <ProductModel>[];
    for (final id in ids) {
      final doc = await _firestoreService.getProduct(id);
      if (doc.exists) {
        products.add(ProductModel.fromFirestore(doc));
      }
    }
    return products;
  }
}
