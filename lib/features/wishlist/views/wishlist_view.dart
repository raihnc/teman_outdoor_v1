import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:teman_outdoor_v1/core/theme/app_colors.dart';
import 'package:teman_outdoor_v1/core/utils/responsive.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/wishlist_controller.dart';
import '../../../data/repositories/wishlist_repository.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

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
    return GetBuilder<WishlistController>(
      init: WishlistController(Get.find<WishlistRepository>()),
      builder: (controller) {
        final screen = context.screen;
        return Scaffold(
          appBar: AppBar(title: const Text('Wishlist')),
          body: Obx(() {
            if (controller.isLoading.value) {
              return GridView.builder(
                padding: EdgeInsets.all(screen.pagePadding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screen.gridColumns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: screen.gridAspectRatio,
                ),
                itemCount: 4,
                itemBuilder: (_, __) => ProductCardShimmer(),
              );
            }
            if (controller.products.isEmpty) {
              return EmptyState(
                icon: Ionicons.heart_outline,
                title: 'Wishlist Kosong',
                subtitle: 'Simpan alat camping favorit Anda di sini.',
                actionText: 'Jelajahi Katalog',
                onAction: () => Get.toNamed(AppRoutes.catalog),
              );
            }
            return RefreshIndicator(
              onRefresh: controller.loadWishlist,
              child: GridView.builder(
                padding: EdgeInsets.all(screen.pagePadding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screen.gridColumns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: screen.gridAspectRatio,
                ),
                itemCount: controller.products.length,
                itemBuilder: (_, i) =>
                    ProductCard(product: controller.products[i]),
              ),
            );
          }),
        );
      },
    );
  }
}
