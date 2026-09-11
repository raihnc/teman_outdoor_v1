import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/review_model.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../data/services/cloudinary_service.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../data/models/booking_model.dart';
import '../../../core/utils/toast.dart';

class ReviewController extends GetxController {
  final ReviewRepository _reviewRepo;
  final CloudinaryService _cloudinaryService;

  ReviewController(this._reviewRepo, this._cloudinaryService);

  final isLoading = false.obs;
  final rating = 0.obs;
  final comment = ''.obs;
  final photos = <File>[].obs;

  late BookingModel booking;

  @override
  void onInit() {
    super.onInit();
    booking = Get.arguments as BookingModel;
  }

  void setRating(int value) => rating.value = value;
  void setComment(String value) => comment.value = value;

  Future<void> pickPhotos() async {
    if (photos.length >= 3) {
      showToast('Maksimal 3 foto', type: ToastType.warning);
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    final remaining = 3 - photos.length;
    photos.addAll(picked.take(remaining).map((f) => File(f.path)));
  }

  void removePhoto(int index) => photos.removeAt(index);

  Future<void> submitReview() async {
    if (rating.value == 0) {
      showToast('Pilih rating bintang', type: ToastType.warning);
      return;
    }

    isLoading.value = true;
    try {
      final auth = Get.find<AuthController>();

      List<String> photoUrls = [];
      if (photos.isNotEmpty) {
        photoUrls = await _cloudinaryService.uploadMultipleImages(
          photos,
          folder: 'reviews',
        );
      }

      final review = ReviewModel(
        id: '',
        userId: auth.user.value!.uid,
        userName: auth.user.value!.name,
        userPhotoUrl: auth.user.value!.photoUrl,
        productId: booking.productId,
        bookingId: booking.id,
        rating: rating.value,
        comment: comment.value,
        photos: photoUrls,
        createdAt: DateTime.now(),
      );

      await _reviewRepo.createReviewAndUpdateProduct(review);

      Get.back();
      showToast('Ulasan berhasil dikirim!', type: ToastType.success);
    } catch (e) {
      showToast('Terjadi kesalahan: $e', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
