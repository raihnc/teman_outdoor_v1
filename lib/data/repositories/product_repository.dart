import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class ProductRepository {
  final FirestoreService _firestoreService;

  ProductRepository(this._firestoreService);

  Future<List<ProductModel>> getProducts({
    String? category,
    String orderBy = 'createdAt',
    bool descending = true,
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    final snapshot = await _firestoreService.getProducts(
      category: category,
      orderBy: orderBy,
      descending: descending,
      limit: limit,
      lastDoc: lastDoc,
    );
    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .where((p) => p.isActive)
        .toList();
  }

  Future<List<ProductModel>> getPopularProducts({int limit = 6}) async {
    final snapshot = await _firestoreService.getPopularProducts(limit: limit);
    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  Future<List<ProductModel>> getNewProducts({int limit = 6}) async {
    final snapshot = await _firestoreService.getNewProducts(limit: limit);
    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  Future<ProductModel?> getProduct(String id) async {
    final doc = await _firestoreService.getProduct(id);
    if (!doc.exists) return null;
    return ProductModel.fromFirestore(doc);
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    await _firestoreService.createProduct(data);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _firestoreService.updateProduct(id, data);
  }

  Future<void> deleteProduct(String id) async {
    await _firestoreService.deleteProduct(id);
  }
}
