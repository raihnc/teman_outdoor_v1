import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../core/utils/toast.dart';

class CatalogController extends GetxController {
  final ProductRepository _productRepo;

  CatalogController(this._productRepo);

  final isLoading = true.obs;
  final products = <ProductModel>[].obs;
  final selectedCategory = ''.obs;
  final searchQuery = ''.obs;
  final sortBy = 'newest'.obs;
  final hasMore = true.obs;
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

  @override
  void onInit() {
    super.onInit();
    final initialCategory = Get.arguments as String?;
    if (initialCategory != null) {
      selectedCategory.value = initialCategory;
    }
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    _lastDoc = null;
    try {
      final orderBy = sortBy.value == 'price_low' || sortBy.value == 'price_high'
          ? 'pricePerDay'
          : sortBy.value == 'popular'
              ? 'totalBooked'
              : 'createdAt';

      final result = await _productRepo.getProducts(
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
        orderBy: orderBy,
        descending: sortBy.value != 'price_low',
      );
      products.value = result;
      hasMore.value = result.length >= 20;
    } catch (e) {
      showToast('Gagal memuat produk', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoading.value) return;
    try {
      final result = await _productRepo.getProducts(
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
        lastDoc: _lastDoc,
      );
      if (result.isNotEmpty) {
        products.addAll(result);
        hasMore.value = result.length >= 20;
      }
    } catch (_) {}
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    loadProducts();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setSortBy(String value) {
    sortBy.value = value;
    loadProducts();
  }

  Future<void> refreshProducts() => loadProducts();
}
