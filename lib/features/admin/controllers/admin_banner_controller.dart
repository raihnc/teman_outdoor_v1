import 'dart:io';
import 'package:get/get.dart';
import '../../../data/repositories/banner_repository.dart';
import '../../../data/services/cloudinary_service.dart';
import '../../../data/models/banner_model.dart';
import '../../../core/utils/toast.dart';

class AdminBannerController extends GetxController {
  final BannerRepository _bannerRepo;
  final CloudinaryService _cloudinaryService;

  AdminBannerController(this._bannerRepo, this._cloudinaryService);

  final isLoading = true.obs;
  final isSaving = false.obs;
  final banners = <BannerModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadBanners();
  }

  Future<void> loadBanners() async {
    isLoading.value = true;
    try {
      banners.value = await _bannerRepo.getActiveBanners();
    } catch (e) {
      showToast('Gagal memuat banner', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addBanner(File imageFile) async {
    isSaving.value = true;
    try {
      final url = await _cloudinaryService.uploadImage(
        imageFile,
        folder: 'banners',
      );
      await _bannerRepo.createBanner({
        'imageUrl': url,
        'title:': '',
        'linkType': 'none',
        'linkValue': '',
        'isActive': true,
        'sortOrder': banners.length,
      });
      await loadBanners();
      showToast('Banner berhasil ditambahkan', type: ToastType.success);
    } catch (e) {
      showToast('Gagal menambahkan banner', type: ToastType.error);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteBanner(String id) async {
    try {
      await _bannerRepo.deleteBanner(id);
      await loadBanners();
      showToast('Banner berhasil dihapus', type: ToastType.success);
    } catch (e) {
      showToast('Gagal menghapus banner', type: ToastType.error);
    }
  }
}
