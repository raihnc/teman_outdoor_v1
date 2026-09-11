import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/widgets/nav_bar.dart';
import '../controllers/admin_navigation_controller.dart';
import 'admin_dashboard_view.dart';
import 'admin_product_list_view.dart';
import 'admin_order_list_view.dart';
import 'admin_review_list_view.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<AdminNavigationController>();

    final pages = const [
      AdminDashboardView(),
      AdminProductListView(),
      AdminOrderListView(),
      AdminReviewListView(),
    ];

    return Obx(() {
      return Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: navController.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: TransparentNavBar(
          currentIndex: navController.currentIndex.value,
          onTap: navController.changeTab,
          items: const [
            NavBarItem(
              icon: Ionicons.stats_chart_outline,
              activeIcon: Ionicons.stats_chart,
              label: 'Dashboard',
            ),
            NavBarItem(
              icon: Ionicons.cube_outline,
              activeIcon: Ionicons.cube,
              label: 'Produk',
            ),
            NavBarItem(
              icon: Ionicons.receipt_outline,
              activeIcon: Ionicons.receipt,
              label: 'Pesanan',
            ),
            NavBarItem(
              icon: Ionicons.star_outline,
              activeIcon: Ionicons.star,
              label: 'Ulasan',
            ),
          ],
        ),
      );
    });
  }
}
