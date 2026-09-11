import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../features/booking/views/booking_sheet.dart';
import '../controllers/product_detail_controller.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/review_repository.dart';

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({super.key});

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
    return GetBuilder<ProductDetailController>(
      init: ProductDetailController(
        Get.find<ReviewRepository>(),
        Get.find<WishlistRepository>(),
        Get.find<ProductRepository>(),
      ),
      builder: (controller) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildImageHeader(context, controller),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(context.screen.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(context, controller),
                      const SizedBox(height: 20),
                      _buildSpecsSection(context, controller),
                      const SizedBox(height: 20),
                      _buildDescriptionSection(context, controller),
                      const SizedBox(height: 24),
                      _buildReviewsSection(context, controller),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: _buildBottomBar(context, controller),
        );
      },
    );
  }

  Widget _buildImageHeader(
    BuildContext context,
    ProductDetailController controller,
  ) {
    final product = controller.product;
    final screen = context.screen;
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      expandedHeight: screen.isSmallPhone ? 260 : 320,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: product.images.length,
              onPageChanged: (i) => controller.selectedImageIndex.value = i,
              itemBuilder: (_, i) {
                return CachedNetworkImage(
                  imageUrl: product.images[i],
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.surface,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.surface,
                    child: const Icon(Ionicons.image_outline, size: 48),
                  ),
                );
              },
            ),
            if (product.images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        product.images.length,
                        (i) => Container(
                          width: i == controller.selectedImageIndex.value
                              ? 24
                              : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i == controller.selectedImageIndex.value
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    )),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(
    BuildContext context,
    ProductDetailController controller,
  ) {
    final product = controller.product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            product.category.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            StarRating(rating: controller.averageRating),
            const SizedBox(width: 8),
            Text(
              '${controller.averageRating.toStringAsFixed(1)} (${controller.reviews.length} ulasan)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              CurrencyFormatter.formatPerDay(product.pricePerDay),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: product.stock > 0
                    ? AppColors.stockAvailable.withValues(alpha: 0.1)
                    : AppColors.stockOut.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.stock > 0 ? 'Stok: ${product.stock}' : 'Stok Habis',
                style: TextStyle(
                  color: product.stock > 0
                      ? AppColors.stockAvailable
                      : AppColors.stockOut,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecsSection(
    BuildContext context,
    ProductDetailController controller,
  ) {
    final specs = controller.product.specs;
    if (specs.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Spesifikasi', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: specs.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${entry.value}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(
    BuildContext context,
    ProductDetailController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Deskripsi', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          controller.product.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(
    BuildContext context,
    ProductDetailController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ulasan (${controller.reviews.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (controller.reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Belum ada ulasan.',
                style: TextStyle(color: AppColors.textHint),
              ),
            ),
          )
        else
          ...controller.reviews.map((review) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            review.userName.isNotEmpty
                                ? review.userName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.userName,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              StarRating(
                                rating: review.rating.toDouble(),
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (review.comment.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(review.comment),
                    ],
                  ],
                ),
              )),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ProductDetailController controller,
  ) {
    final screen = context.screen;
    return Container(
      padding: EdgeInsets.fromLTRB(
        screen.pagePadding,
        12,
        screen.pagePadding,
        24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Obx(() => IconButton(
                    onPressed: controller.toggleWishlist,
                    icon: Icon(
                      controller.isWishlisted.value
                          ? Ionicons.heart
                          : Ionicons.heart_outline,
                      color: controller.isWishlisted.value
                          ? AppColors.error
                          : AppColors.textPrimary,
                    ),
                  )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                label:
                    controller.product.stock > 0 ? 'Sewa Sekarang' : 'Stok Habis',
                icon: Ionicons.cart_outline,
                onPressed: controller.product.stock > 0
                    ? () {
                        final auth = Get.find<AuthController>();
                        auth.requireAuth(() {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (_) => BookingSheet(
                              product: controller.product,
                            ),
                          );
                        });
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
