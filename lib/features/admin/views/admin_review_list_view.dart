import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/confirm_bottom_sheet.dart';
import '../../../data/models/review_model.dart';
import '../controllers/admin_review_controller.dart';
import '../controllers/admin_product_controller.dart';

class AdminReviewListView extends StatelessWidget {
  const AdminReviewListView({super.key});

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
    return GetBuilder<AdminReviewController>(
      init: Get.find<AdminReviewController>(),
      builder: (controller) {
        final productController = Get.find<AdminProductController>();
        final productNameById = <String, String>{
          for (final p in productController.products) p.id: p.name,
        };
        return Scaffold(
          appBar: AppBar(
            title: const Text('Kelola Ulasan'),
            surfaceTintColor: Colors.transparent,
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.reviews.isEmpty) {
              return const EmptyState(
                icon: Ionicons.chatbubble_ellipses_outline,
                title: 'Belum Ada Ulasan',
                subtitle: 'Ulasan penyewa akan muncul di sini.',
              );
            }
            return RefreshIndicator(
              onRefresh: () async {},
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  context.screen.pagePadding,
                  16,
                  context.screen.pagePadding,
                  100,
                ),
                itemCount: controller.reviews.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final review = controller.reviews[index];
                  return _ReviewCard(
                    review: review,
                    productName: productNameById[review.productId] ?? '',
                    onDelete: () => controller.deleteReview(review.id),
                  );
                },
              ),
            );
          }),
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final String productName;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.review,
    required this.productName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: review.userPhotoUrl.isEmpty
                    ? null
                    : NetworkImage(review.userPhotoUrl),
                child: review.userPhotoUrl.isEmpty
                    ? Text(
                        review.userName.isNotEmpty
                            ? review.userName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (productName.isNotEmpty)
                      Text(
                        productName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  showConfirmBottomSheet(
                    title: 'Hapus Ulasan?',
                    message: 'Yakin ingin menghapus ulasan ini?',
                    confirmLabel: 'Hapus',
                    onConfirm: onDelete,
                  );
                },
                icon: const Icon(Ionicons.trash_outline,
                    color: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StarRating(rating: review.rating.toDouble(), size: 16),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.comment),
          ],
          if (review.photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: List.generate(review.photos.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: review.photos[i],
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        width: 56,
                        height: 56,
                        color: AppColors.surface,
                        child: const Icon(Ionicons.image_outline, size: 20),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            DateFormatter.formatFullDate(review.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textHint,
                ),
          ),
        ],
      ),
    );
  }
}
