import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../core/utils/toast.dart';

class AdminProductController extends GetxController {
  final ProductRepository _productRepo;

  AdminProductController(this._productRepo);

  final isLoading = true.obs;
  final isSaving = false.obs;
  final products = <ProductModel>[].obs;
  final searchQuery = ''.obs;

  List<ProductModel> get filteredProducts {
    if (searchQuery.value.isEmpty) return products;
    final q = searchQuery.value.toLowerCase();
    return products
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      products.value = await _productRepo.getProducts(
        orderBy: 'createdAt',
        descending: true,
        limit: 100,
      );
    } catch (e) {
      showToast('Gagal memuat produk', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProduct({
    required String id,
    required String name,
    required String description,
    required int pricePerDay,
    required String category,
    required int stock,
    required Map<String, dynamic> specs,
    required List<String> images,
  }) async {
    isSaving.value = true;
    try {
      final data = {
        'name': name,
        'description': description,
        'pricePerDay': pricePerDay,
        'category': category,
        'stock': stock,
        'specs': specs,
        'images': images,
        'thumbnailUrl': images.isNotEmpty ? images.first : '',
        'isActive': true,
      };

      if (id.isEmpty) {
        data['averageRating'] = 0;
        data['totalReviews'] = 0;
        data['totalBooked'] = 0;
        await _productRepo.createProduct(data);
      } else {
        await _productRepo.updateProduct(id, data);
      }

      Get.back();
      showToast('Produk berhasil disimpan', type: ToastType.success);
      await loadProducts();
    } catch (e) {
      showToast('Gagal menyimpan produk: $e', type: ToastType.error);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productRepo.deleteProduct(id);
      await loadProducts();
      showToast('Produk berhasil dihapus', type: ToastType.success);
    } catch (e) {
      showToast('Gagal menghapus produk', type: ToastType.error);
    }
  }
}
