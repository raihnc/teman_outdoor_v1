import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: Get.find<HomeController>(),
      builder: (controller) {
        return ResponsiveBuilder(
          builder: (context, screen) {
            return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: BannerShimmer(),
                    );
                  }
                  if (controller.banners.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _buildBannerCarousel(context, controller);
                }),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    'Kategori',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 6,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, __) => const ShimmerLoading(
                          width: 72,
                          height: 72,
                          borderRadius: 16,
                        ),
                      ),
                    );
                  }
                  return _buildCategoryChips(context, controller);
                }),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🔥 Populer',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.catalog),
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return SizedBox(
                      height: 260,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 4,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, __) =>
                            SizedBox(width: 180, child: ProductCardShimmer()),
                      ),
                    );
                  }
                  return _buildHorizontalProducts(
                    context,
                    controller.popularProducts,
                  );
                }),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '✨ Baru Ditambahkan',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.catalog),
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: Obx(() {
                  if (controller.isLoading.value) {
                    return SliverGrid(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: screen.gridColumns,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: screen.gridAspectRatio,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => ProductCardShimmer(),
                        childCount: 4,
                      ),
                    );
                  }
                  return SliverGrid(
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: screen.gridColumns,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: screen.gridAspectRatio,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => ProductCard(product: controller.newProducts[i]),
                      childCount: controller.newProducts.length,
                    ),
                  );
                }),
              ),
            ],
          ),
        );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Ionicons.leaf,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teman Outdoor',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Makassar',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.search),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Ionicons.search_outline,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Cari alat camping...',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCarousel(BuildContext context, HomeController controller) {
    return CarouselSlider.builder(
      itemCount: controller.banners.length,
      options: CarouselOptions(
        height: 180,
        viewportFraction: 0.88,
        enableInfiniteScroll: controller.banners.length > 1,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        enlargeCenterPage: true,
        padEnds: false,
      ),
      itemBuilder: (_, index, __) {
        final banner = controller.banners[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: banner.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (_, __) => Container(
                color: AppColors.surface,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surface,
                child: const Icon(Ionicons.image_outline),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChips(BuildContext context, HomeController controller) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final cat = controller.categories[index];
          return GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.catalog, arguments: cat.name),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Ionicons.compass,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat.name,
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalProducts(BuildContext context, List products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Belum ada produk populer.'),
      );
    }
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) =>
            SizedBox(width: 180, child: ProductCard(product: products[i])),
      ),
    );
  }
}
