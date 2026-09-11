import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../../core/utils/toast.dart';

class CatalogController extends GetxController {
  final FirestoreService _firestoreService;

  CatalogController(this._firestoreService);

  final isLoading = true.obs;
  final products = <ProductModel>[].obs;
  final selectedCategory = ''.obs;
  final searchQuery = ''.obs;
  final sortBy = 'newest'.obs;
  final hasMore = true.obs;

  StreamSubscription<QuerySnapshot>? _productsSub;
  DocumentSnapshot? _lastDoc;

  List<ProductModel> get filteredProducts {
    var result = products.toList();

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    }

    switch (sortBy.value) {
      case 'price_low':
        result.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case 'price_high':
        result.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
      case 'popular':
        result.sort((a, b) => b.totalBooked.compareTo(a.totalBooked));
        break;
    }

    return result;
  }

  String get _orderByField => switch (sortBy.value) {
        'price_low' || 'price_high' => 'pricePerDay',
        'popular' => 'totalBooked',
        _ => 'createdAt',
      };

  bool get _descending => sortBy.value != 'price_low';

  @override
  void onInit() {
    super.onInit();
    final initialCategory = Get.arguments as String?;
    if (initialCategory != null) {
      selectedCategory.value = initialCategory;
    }
    _subscribe();
  }

  @override
  void onClose() {
    _productsSub?.cancel();
    super.onClose();
  }

  /// Halaman 1 (limit 20) real-time; perubahan data langsung tampil.
  void _subscribe() {
    _productsSub?.cancel();
    isLoading.value = true;
    _lastDoc = null;

    _productsSub = _firestoreService
        .activeProductsStream(
          category: selectedCategory.value.isEmpty
              ? null
              : selectedCategory.value,
          orderBy: _orderByField,
          descending: _descending,
          limit: AppConstants.defaultPageSize,
        )
        .listen((snap) {
      products.value = snap.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where((p) => p.isActive)
          .toList();
      hasMore.value = snap.docs.length >= AppConstants.defaultPageSize;
      _lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
      isLoading.value = false;
      update();
    }, onError: (_) {
      showToast('Gagal memuat produk', type: ToastType.error);
      isLoading.value = false;
      update();
    });
  }

  /// Muat halaman berikutnya (one-shot get, sesuai PRD pagination).
  Future<void> loadMore() async {
    if (!hasMore.value || isLoading.value || _lastDoc == null) return;
    isLoading.value = true;
    try {
      final snap = await _firestoreService.getProducts(
        category: selectedCategory.value.isEmpty
            ? null
            : selectedCategory.value,
        orderBy: _orderByField,
        descending: _descending,
        limit: AppConstants.defaultPageSize,
        lastDoc: _lastDoc,
      );
      final list = snap.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
      if (list.isNotEmpty) {
        products.addAll(list);
        hasMore.value = list.length >= AppConstants.defaultPageSize;
        _lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
        update();
      }
    } catch (_) {
      showToast('Gagal memuat produk', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    _subscribe();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setSortBy(String value) {
    sortBy.value = value;
    _subscribe();
  }

  Future<void> refreshProducts() async {
    _subscribe();
  }
}
