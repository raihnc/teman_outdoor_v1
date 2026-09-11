import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../core/utils/toast.dart';

class AdminProductController extends GetxController {
  final ProductRepository _productRepo;

  AdminProductController(this._productRepo);

  final isLoading = true.obs;
  final isSaving = false.obs;
  final products = <ProductModel>[].obs;
  final searchQuery = ''.obs;

  StreamSubscription<List<ProductModel>>? _productsSub;

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
    final auth = Get.find<AuthController>();
    ever(auth.user, (_) {
      if (auth.isLoggedIn) {
        _subscribe();
      } else {
        _productsSub?.cancel();
        isLoading.value = true;
      }
    });
    _subscribe();
  }

  @override
  void onClose() {
    _productsSub?.cancel();
    super.onClose();
  }

  /// List produk real-time — perubahan stok/nama/produk baru langsung tampil.
  void _subscribe() {
    _productsSub?.cancel();
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      isLoading.value = true;
      return;
    }
    _productsSub = _productRepo
        .activeProductsStream(
          orderBy: 'createdAt',
          descending: true,
          limit: 100,
        )
        .listen((list) {
      products.value = list;
      isLoading.value = false;
      update();
    }, onError: (e) {
      debugPrint('AdminProductController: stream error: $e');
      showToast('Gagal memuat produk', type: ToastType.error);
      isLoading.value = false;
      update();
    });
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
        data['createdAt'] = FieldValue.serverTimestamp();
        await _productRepo.createProduct(data);
      } else {
        data['updatedAt'] = FieldValue.serverTimestamp();
        await _productRepo.updateProduct(id, data);
      }

      Get.back();
      showToast('Produk berhasil disimpan', type: ToastType.success);
    } catch (e) {
      showToast('Gagal menyimpan produk: $e', type: ToastType.error);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productRepo.deleteProduct(id);
      showToast('Produk berhasil dihapus', type: ToastType.success);
    } catch (e) {
      showToast('Gagal menghapus produk', type: ToastType.error);
    }
  }
}
