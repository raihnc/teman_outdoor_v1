import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/services/firestore_service.dart';
import '../../../core/utils/toast.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  final ProductRepository _productRepo;
  final FirestoreService _firestoreService;

  HomeController(this._productRepo, this._firestoreService);

  final isLoading = true.obs;
  final categories = <CategoryModel>[].obs;
  final popularProducts = <ProductModel>[].obs;
  final newProducts = <ProductModel>[].obs;

  final List<StreamSubscription<dynamic>> _subs = [];

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    // Re-subscribe saat user login/logout (controller ini dibuat saat app
    // start, sebelum auth siap — tanpa ini stream mati kena permission-denied).
    ever(auth.user, (_) {
      if (auth.isLoggedIn) {
        _subscribe();
      } else {
        _cancelSubs();
        isLoading.value = true;
      }
    });
    _subscribe();
  }

  @override
  void onClose() {
    _cancelSubs();
    super.onClose();
  }

  void _cancelSubs() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
  }

  void _subscribe() {
    _cancelSubs();
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      isLoading.value = true;
      return;
    }
    isLoading.value = true;

    _subs.add(_firestoreService.activeCategoriesStream().listen((snap) {
      categories.value = snap.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
      _firstData();
    }, onError: (e) {
      debugPrint('HomeController: categories stream error: $e');
      _firstData(err: true);
    }));

    _subs.add(_productRepo.popularProductsStream(limit: 6).listen((list) {
      popularProducts.value = list;
      _firstData();
    }, onError: (e) {
      debugPrint('HomeController: popular stream error: $e');
      _firstData(err: true);
    }));

    _subs.add(_productRepo.newProductsStream(limit: 6).listen((list) {
      newProducts.value = list;
      _firstData();
    }, onError: (e) {
      debugPrint('HomeController: new products stream error: $e');
      _firstData(err: true);
    }));
  }

  void _firstData({bool err = false}) {
    if (isLoading.value) {
      if (err) {
        showToast('Gagal memuat data', type: ToastType.error);
      }
      isLoading.value = false;
    }
  }

  /// Untuk RefreshIndicator — membuang & membuat ulang listener.
  Future<void> refreshData() async {
    _subscribe();
  }
}
