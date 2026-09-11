import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../../../features/auth/controllers/auth_controller.dart';

class ProductDetailController extends GetxController {
  final ReviewRepository _reviewRepo;
  final WishlistRepository _wishlistRepo;

  ProductDetailController(this._reviewRepo, this._wishlistRepo);

  late ProductModel product;
  final isLoading = true.obs;
  final reviews = <ReviewModel>[].obs;
  final isWishlisted = false.obs;
  final selectedImageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    product = Get.arguments as ProductModel;
    _loadReviews();
    _checkWishlist();
  }

  Future<void> _loadReviews() async {
    try {
      reviews.value = await _reviewRepo.getProductReviews(product.id);
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> _checkWishlist() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) return;
    try {
      final ids = await _wishlistRepo.getWishlistIds(auth.user.value!.uid);
      isWishlisted.value = ids.contains(product.id);
    } catch (_) {}
  }

  Future<void> toggleWishlist() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      Get.toNamed('/login');
      return;
    }
    isWishlisted.value = !isWishlisted.value;
    try {
      await _wishlistRepo.toggleWishlist(
        auth.user.value!.uid,
        product.id,
        isWishlisted.value,
      );
    } catch (e) {
      isWishlisted.value = !isWishlisted.value;
    }
  }

  int get totalRating {
    if (reviews.isEmpty) return 0;
    int sum = 0;
    for (final r in reviews) {
      sum += r.rating;
    }
    return sum;
  }

  double get averageRating {
    if (reviews.isEmpty) return 0;
    return totalRating / reviews.length;
  }
}
