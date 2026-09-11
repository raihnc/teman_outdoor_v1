import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/banner_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/banner_repository.dart';
import '../../../data/services/firestore_service.dart';
import '../../../core/utils/toast.dart';

class HomeController extends GetxController {
  final ProductRepository _productRepo;
  final BannerRepository _bannerRepo;
  final FirestoreService _firestoreService;

  HomeController(this._productRepo, this._bannerRepo, this._firestoreService);

  final isLoading = true.obs;
  final banners = <BannerModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final popularProducts = <ProductModel>[].obs;
  final newProducts = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _bannerRepo.getActiveBanners(),
        _loadCategories(),
        _productRepo.getPopularProducts(limit: 6),
        _productRepo.getNewProducts(limit: 6),
      ]);
      banners.value = results[0] as List<BannerModel>;
      categories.value = results[1] as List<CategoryModel>;
      popularProducts.value = results[2] as List<ProductModel>;
      newProducts.value = results[3] as List<ProductModel>;
    } catch (e) {
      showToast('Gagal memuat data', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<CategoryModel>> _loadCategories() async {
    final snapshot = await _firestoreService.getActiveCategories();
    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  Future<void> refreshData() => loadHomeData();
}
