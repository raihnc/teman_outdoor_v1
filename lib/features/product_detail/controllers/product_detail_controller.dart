import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../features/auth/controllers/auth_controller.dart';

class ProductDetailController extends GetxController {
  final ReviewRepository _reviewRepo;
  final WishlistRepository _wishlistRepo;
  final ProductRepository _productRepo;

  ProductDetailController(this._reviewRepo, this._wishlistRepo, this._productRepo);

  late ProductModel product;
  final isLoading = true.obs;
  final reviews = <ReviewModel>[].obs;
  final isWishlisted = false.obs;
  final selectedImageIndex = 0.obs;

  StreamSubscription<List<ReviewModel>>? _reviewsSub;
  StreamSubscription<ProductModel?>? _productSub;
  StreamSubscription<List<String>>? _wishlistSub;

  @override
  void onInit() {
    super.onInit();
    product = Get.arguments as ProductModel;

    _reviewsSub = _reviewRepo.productReviewsStream(product.id).listen((list) {
      reviews.value = list;
      isLoading.value = false;
      update();
    }, onError: (_) {
      isLoading.value = false;
      update();
    });

    // Dokumen produk live: stok/harga/rating berubah langsung tampil.
    _productSub = _productRepo.productStream(product.id).listen((p) {
      if (p != null) {
        product = p;
        update();
      }
    }, onError: (_) {});

    _checkWishlist();
  }

  @override
  void onClose() {
    _reviewsSub?.cancel();
    _productSub?.cancel();
    _wishlistSub?.cancel();
    super.onClose();
  }

  Future<void> _checkWishlist() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) return;

    _wishlistSub?.cancel();
    _wishlistSub = _wishlistRepo
        .wishlistIdsStream(auth.user.value!.uid)
        .listen((ids) {
      isWishlisted.value = ids.contains(product.id);
      update();
    }, onError: (_) {});
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
