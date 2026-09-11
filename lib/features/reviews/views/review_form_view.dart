import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/review_controller.dart';
import '../../../data/services/cloudinary_service.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/review_repository.dart';

class ReviewFormView extends StatelessWidget {
  const ReviewFormView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return GetBuilder<ReviewController>(
      init: ReviewController(
          Get.find<ReviewRepository>(),
          Get.find<BookingRepository>(),
          Get.find<CloudinaryService>(),
        ),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text('Beri Ulasan'), surfaceTintColor: Colors.transparent),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              context.screen.pagePadding,
              16,
              context.screen.pagePadding,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bagaimana pengalaman Anda?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                // Rating
                Center(
                  child: Obx(() => StarRating(
                        rating: controller.rating.value.toDouble(),
                        size: 40,
                        interactive: true,
                        onRatingChanged: controller.setRating,
                      )),
                ),
                const SizedBox(height: 32),

                // Comment
                Text(
                  'Komentar',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 4,
                  maxLength: 500,
                  onChanged: controller.setComment,
                  decoration: const InputDecoration(
                    hintText: 'Ceritakan pengalaman Anda...',
                  ),
                ),
                const SizedBox(height: 16),

                // Photos
                Text(
                  'Foto (opsional)',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...List.generate(controller.photos.length, (i) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  controller.photos[i],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => controller.removePhoto(i),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Ionicons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        if (controller.photos.length < 3)
                          GestureDetector(
                            onTap: controller.pickPhotos,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.border, width: 2),
                              ),
                              child: const Icon(
                                Ionicons.camera_outline,
                                color: AppColors.textHint,
                                size: 28,
                              ),
                            ),
                          ),
                      ],
                    )),
                const SizedBox(height: 32),

                // Submit
                Obx(() => CustomButton(
                      label: 'Kirim Ulasan',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.submitReview,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
