import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/empty_state.dart';
import '../controllers/catalog_controller.dart';
import '../../../data/repositories/product_repository.dart';

class CatalogView extends StatelessWidget {
  const CatalogView({super.key});

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
    return GetBuilder<CatalogController>(
      init: CatalogController(Get.find<ProductRepository>()),
      builder: (controller) {
        final screen = context.screen;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Katalog'),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Ionicons.swap_vertical_outline),
                onSelected: controller.setSortBy,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'newest', child: Text('Terbaru')),
                  PopupMenuItem(value: 'popular', child: Text('Terlaris')),
                  PopupMenuItem(
                      value: 'price_low', child: Text('Harga Terendah')),
                  PopupMenuItem(
                      value: 'price_high', child: Text('Harga Tertinggi')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(context, controller),
              _buildCategoryFilter(context, controller),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildLoadingGrid(context);
                  }
                  final products = controller.filteredProducts;
                  if (products.isEmpty) {
                    return EmptyState(
                      title: 'Tidak Ada Produk',
                      subtitle: 'Tidak ditemukan alat camping yang sesuai.',
                      actionText: 'Reset Filter',
                      onAction: () {
                        controller.setCategory('');
                        controller.setSearchQuery('');
                      },
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: controller.refreshProducts,
                    child: GridView.builder(
                      padding: EdgeInsets.fromLTRB(
                        screen.pagePadding,
                        12,
                        screen.pagePadding,
                        100,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: screen.gridColumns,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: screen.gridAspectRatio,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, i) =>
                          ProductCard(product: products[i]),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, CatalogController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Cari alat camping...',
          prefixIcon:
              const Icon(Ionicons.search_outline, size: 20),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: const Icon(Ionicons.close_circle, size: 20),
              onPressed: () => controller.setSearchQuery(''),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(
    BuildContext context,
    CatalogController controller,
  ) {
    final categories = [
      '',
      'Tenda',
      'Sleeping Bag',
      'Kompor',
      'Backpack',
      'Matras',
      'Lainnya',
    ];
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final cat = categories[index];
          final isSelected = controller.selectedCategory.value == cat;
          return FilterChip(
            label: Text(cat.isEmpty ? 'Semua' : cat),
            selected: isSelected,
            onSelected: (_) => controller.setCategory(cat),
            selectedColor: AppColors.primary,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: 13,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid(BuildContext context) {
    final screen = context.screen;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        screen.pagePadding,
        12,
        screen.pagePadding,
        100,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screen.gridColumns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: screen.gridAspectRatio,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => ProductCardShimmer(),
    );
  }
}
