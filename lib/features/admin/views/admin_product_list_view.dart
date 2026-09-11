import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/admin_product_controller.dart';

class AdminProductListView extends StatelessWidget {
  const AdminProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminProductController>(
      init: Get.find<AdminProductController>(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Kelola Produk'),
            actions: [
              IconButton(
                onPressed: () =>
                    Get.toNamed(AppRoutes.adminProductForm),
                icon: const Icon(Ionicons.add_circle_outline),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  onChanged: (v) => controller.searchQuery.value = v,
                  decoration: const InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: Icon(Ionicons.search_outline, size: 20),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 5,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, __) => const ShimmerLoading(
                        width: double.infinity,
                        height: 80,
                        borderRadius: 12,
                      ),
                    );
                  }
                  final products = controller.filteredProducts;
                  if (products.isEmpty) {
                    return const Center(
                      child: Text('Belum ada produk.'),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      context.screen.pagePadding,
                      0,
                      context.screen.pagePadding,
                      100,
                    ),
                    itemCount: products.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final product = products[i];
                      return Dismissible(
                        key: Key(product.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: AppColors.error,
                          child: const Icon(Ionicons.trash_outline,
                              color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          return await Get.defaultDialog(
                            title: 'Hapus Produk?',
                            middleText:
                                'Anda yakin ingin menghapus "${product.name}"?',
                            textConfirm: 'Hapus',
                            textCancel: 'Batal',
                            confirmTextColor: Colors.white,
                            onConfirm: () {
                              Get.back(result: true);
                              controller.deleteProduct(product.id);
                            },
                          );
                        },
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 4),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: product.thumbnailUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                width: 56,
                                height: 56,
                                color: AppColors.surface,
                                child: const Icon(Ionicons.image_outline),
                              ),
                            ),
                          ),
                          title: Text(product.name,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            '${CurrencyFormatter.formatPerDay(product.pricePerDay)} · Stok: ${product.stock}',
                          ),
                          trailing: IconButton(
                            onPressed: () => Get.toNamed(
                              AppRoutes.adminProductForm,
                              arguments: product,
                            ),
                            icon: const Icon(Ionicons.pencil_outline,
                                size: 20),
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
