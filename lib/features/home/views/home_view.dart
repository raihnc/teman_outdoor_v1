import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/product_card.dart';
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
            return Column(
              children: [
                // Header tetap (fixed) — tidak ikut scroll
                _buildHeader(context),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.refreshData,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '🔥 Populer',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Get.toNamed(AppRoutes.catalog),
                                  child: const Text('Lihat Semua'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Obx(() {
                            if (controller.isLoading.value) {
                              return const SizedBox(
                                height: 260,
                                child: Center(
                                  child: CircularProgressIndicator(),
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
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Get.toNamed(AppRoutes.catalog),
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
                              return const SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 48),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
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
                                (_, i) => ProductCard(
                                  product: controller.newProducts[i],
                                ),
                                childCount: controller.newProducts.length,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
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
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.search),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
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
                    SizedBox(width: 13),
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

  Widget _buildHorizontalProducts(BuildContext context, List products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Belum ada produk populer.'),
      );
    }
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) =>
            SizedBox(width: 180, child: ProductCard(product: products[i])),
      ),
    );
  }
}
