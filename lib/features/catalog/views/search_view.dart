import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:teman_outdoor_v1/core/theme/app_colors.dart';
import 'package:teman_outdoor_v1/core/utils/responsive.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../controllers/catalog_controller.dart';
import '../../../data/services/firestore_service.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

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
    final controller = Get.put(
      CatalogController(Get.find<FirestoreService>()),
      tag: 'search',
    );
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: TextField(
          onChanged: controller.setSearchQuery,
          decoration: const InputDecoration(
            hintText: 'Cari alat camping...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: Obx(() {
        final screen = context.screen;
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final products = controller.filteredProducts;
        if (products.isEmpty) {
          return const EmptyState(
            icon: Ionicons.search_outline,
            title: 'Tidak Ditemukan',
            subtitle: 'Coba kata kunci lain.',
          );
        }
        return GridView.builder(
          padding: EdgeInsets.all(screen.pagePadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screen.gridColumns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: screen.gridAspectRatio,
          ),
          itemCount: products.length,
          itemBuilder: (_, i) => ProductCard(product: products[i]),
        );
      }),
    );
  }
}
