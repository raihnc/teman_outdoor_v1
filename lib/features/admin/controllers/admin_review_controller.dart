import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/models/review_model.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../core/utils/toast.dart';

class AdminReviewController extends GetxController {
  final ReviewRepository _reviewRepo;

  AdminReviewController(this._reviewRepo);

  final isLoading = true.obs;
  final reviews = <ReviewModel>[].obs;

  StreamSubscription<List<ReviewModel>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _subscribe();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void _subscribe() {
    _sub?.cancel();
    _sub = _reviewRepo.allReviewsStream().listen((list) {
      reviews.value = list;
      isLoading.value = false;
      update();
    }, onError: (e) {
      debugPrint('AdminReviewController: stream error: $e');
      isLoading.value = false;
      update();
    });
  }

  Future<void> deleteReview(String id) async {
    try {
      await _reviewRepo.deleteReview(id);
      showToast('Ulasan berhasil dihapus', type: ToastType.success);
    } catch (e) {
      showToast('Gagal menghapus ulasan', type: ToastType.error);
    }
  }
}
