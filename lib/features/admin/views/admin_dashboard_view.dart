import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/routes/app_routes.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel'), surfaceTintColor: Colors.transparent,),
      body: Padding(
        padding: EdgeInsets.all(context.screen.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kelola Toko',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Atur produk, pesanan, dan banner dari sini.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            _buildAdminCard(
              context,
              icon: Ionicons.cube_outline,
              title: 'Produk',
              subtitle: 'Kelola semua alat rental',
              onTap: () => Get.toNamed(AppRoutes.adminProductList),
            ),
            const SizedBox(height: 12),
            _buildAdminCard(
              context,
              icon: Ionicons.receipt_outline,
              title: 'Pesanan',
              subtitle: 'Kelola status pesanan',
              onTap: () => Get.toNamed(AppRoutes.adminOrderList),
            ),
            const SizedBox(height: 12),
            _buildAdminCard(
              context,
              icon: Ionicons.images_outline,
              title: 'Banner',
              subtitle: 'Kelola banner beranda',
              onTap: () => Get.toNamed(AppRoutes.adminBannerList),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Ionicons.chevron_forward, size: 20),
          ],
        ),
      ),
    );
  }
}
