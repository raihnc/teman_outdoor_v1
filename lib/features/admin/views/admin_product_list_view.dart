import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/confirm_bottom_sheet.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/admin_product_controller.dart';

class AdminProductListView extends StatelessWidget {
  const AdminProductListView({super.key});

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
    return GetBuilder<AdminProductController>(
      init: Get.find<AdminProductController>(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            title: const Text('Kelola Produk'),
            actions: [
              IconButton(
                onPressed: () => Get.toNamed(AppRoutes.adminProductForm),
                icon: const Icon(Ionicons.add_circle_outline, size: 24),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.screen.pagePadding,
                  4,
                  context.screen.pagePadding,
                  12,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    onChanged: (v) => controller.searchQuery.value = v,
                    decoration: const InputDecoration(
                      hintText: 'Cari produk...',
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Ionicons.search_outline,
                        size: 20,
                        color: AppColors.textHint,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final products = controller.filteredProducts;
                  if (products.isEmpty) {
                    return const Center(child: Text('Belum ada produk.'));
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      context.screen.pagePadding,
                      0,
                      context.screen.pagePadding,
                      100,
                    ),
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final product = products[i];
                      return Dismissible(
                        key: Key(product.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Ionicons.trash_outline,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (_) async {
                          return await showConfirmBottomSheet(
                            title: 'Hapus Produk?',
                            message:
                                'Anda yakin ingin menghapus "${product.name}"?',
                            confirmLabel: 'Hapus',
                            onConfirm: () =>
                                controller.deleteProduct(product.id),
                          );
                        },
                        child: Card(
                          elevation: 0.8,
                          child: Container(
                            padding: const EdgeInsets.all(12),

                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: product.thumbnailUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    placeholder: (_, _) => Container(
                                      width: 60,
                                      height: 60,
                                      color: AppColors.surface,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, _, _) => Container(
                                      width: 60,
                                      height: 60,
                                      color: AppColors.surface,
                                      child: const Icon(
                                        Ionicons.image_outline,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelLarge,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        CurrencyFormatter.formatPerDay(
                                          product.pricePerDay,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      _StockChip(stock: product.stock),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Get.toNamed(
                                    AppRoutes.adminProductForm,
                                    arguments: product,
                                  ),
                                  icon: const Icon(
                                    Ionicons.create_outline,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StockChip extends StatelessWidget {
  final int stock;

  const _StockChip({required this.stock});

  @override
  Widget build(BuildContext context) {
    final out = stock <= 0;
    final color = out ? AppColors.error : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        out ? 'Stok Habis' : 'Stok $stock',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
