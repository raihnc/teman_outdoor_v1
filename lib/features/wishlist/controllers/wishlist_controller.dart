import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../core/utils/toast.dart';

class WishlistController extends GetxController {
  final WishlistRepository _wishlistRepo;

  WishlistController(this._wishlistRepo);

  final isLoading = true.obs;
  final products = <ProductModel>[].obs;

  StreamSubscription<List<String>>? _idsSub;

  @override
  void onInit() {
    super.onInit();
    _subscribe();
  }

  @override
  void onClose() {
    _idsSub?.cancel();
    super.onClose();
  }

  /// Id wishlist real-time: menambah/menghapus item langsung terlihat.
  void _subscribe() {
    _idsSub?.cancel();
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      isLoading.value = false;
      return;
    }

    _idsSub = _wishlistRepo
        .wishlistIdsStream(auth.user.value!.uid)
        .listen((ids) {
      _loadProducts(ids);
    }, onError: (_) {
      showToast('Gagal memuat wishlist', type: ToastType.error);
      isLoading.value = false;
    });
  }

  Future<void> _loadProducts(List<String> ids) async {
    try {
      products.value = await _wishlistRepo.getProductsByIds(ids);
    } catch (_) {
      showToast('Gagal memuat wishlist', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeItem(String productId) async {
    try {
      final auth = Get.find<AuthController>();
      if (!auth.isLoggedIn) return;
      await _wishlistRepo.toggleWishlist(auth.user.value!.uid, productId, false);
      products.removeWhere((p) => p.id == productId);
    } catch (e) {
      showToast('Gagal menghapus dari wishlist', type: ToastType.error);
    }
  }

  /// Untuk RefreshIndicator — re-subscribe stream agar ambil data terbaru.
  Future<void> loadWishlist() async {
    _subscribe();
  }
}
