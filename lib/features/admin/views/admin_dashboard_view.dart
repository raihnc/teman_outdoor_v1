import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/routes/app_routes.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/widgets/confirm_bottom_sheet.dart';
import '../controllers/admin_navigation_controller.dart';
import '../controllers/admin_product_controller.dart';
import '../controllers/admin_order_controller.dart';
import '../controllers/admin_review_controller.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<AdminProductController>();
    final orderController = Get.find<AdminOrderController>();
    final reviewController = Get.find<AdminReviewController>();
    final navController = Get.find<AdminNavigationController>();
    final authController = Get.find<AuthController>();

    final screen = context.screen;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              showConfirmBottomSheet(
                title: 'Keluar',
                message: 'Yakin ingin keluar dari akun admin?',
                confirmLabel: 'Keluar',
                cancelLabel: 'Batal',
                onConfirm: authController.signOut,
              );
            },
            icon: const Icon(Ionicons.log_out_outline, color: AppColors.error),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          screen.pagePadding,
          8,
          screen.pagePadding,
          100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroHeader(date: DateFormatter.formatFullDate(DateTime.now())),
            const SizedBox(height: 28),
            Text('Ringkasan', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Obx(() {
              final totalProducts = productController.products.length;
              final totalOrders = orderController.bookings.length;
              final pendingOrders = orderController.bookings
                  .where((b) => b.status == FirestoreConstants.statusPending)
                  .length;
              final totalReviews = reviewController.reviews.length;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Ionicons.cube_outline,
                          label: 'Produk',
                          value: '$totalProducts',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Ionicons.receipt_outline,
                          label: 'Pesanan',
                          value: '$totalOrders',
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Ionicons.time_outline,
                          label: 'Pending',
                          value: '$pendingOrders',
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Ionicons.star_outline,
                          label: 'Ulasan',
                          value: '$totalReviews',
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
            const SizedBox(height: 28),
            Text('Aksi Cepat', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    icon: Ionicons.add_outline,
                    label: 'Tambah Produk',
                    color: AppColors.primary,
                    onTap: () => Get.toNamed(AppRoutes.adminProductForm),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionTile(
                    icon: Ionicons.receipt_outline,
                    label: 'Lihat Pesanan',
                    color: AppColors.secondary,
                    onTap: () => navController.changeTab(2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final String date;

  const _HeroHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang 👋',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Kelola produk, pesanan, dan ulasan toko Anda dari sini.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.8,
      child: Container(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0.8,
        child: Container(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const Icon(
                Ionicons.chevron_forward_outline,
                size: 18,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
