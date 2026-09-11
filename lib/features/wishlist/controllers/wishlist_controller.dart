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

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    isLoading.value = true;
    try {
      final auth = Get.find<AuthController>();
      if (!auth.isLoggedIn) {
        isLoading.value = false;
        return;
      }
      products.value = await _wishlistRepo.getWishlistProducts(auth.user.value!.uid);
    } catch (e) {
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
}
