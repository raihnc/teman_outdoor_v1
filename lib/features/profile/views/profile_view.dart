import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../features/auth/controllers/auth_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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
    return GetBuilder<AuthController>(
      init: Get.find<AuthController>(),
      builder: (authController) {
        final user = authController.user.value;
        final screen = context.screen;
        return SafeArea(
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      screen.pagePadding,
                      24,
                      screen.pagePadding,
                      0,
                    ),
                    child: Text(
                      'Profil',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            backgroundImage: user?.photoUrl.isNotEmpty == true
                                ? NetworkImage(user!.photoUrl)
                                : null,
                            child: user?.photoUrl.isEmpty != false
                                ? Text(
                                    user?.name.isNotEmpty == true
                                        ? user!.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? '',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? '',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (user?.phone.isNotEmpty == true) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    user!.phone,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screen.pagePadding,
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context,
                          icon: Ionicons.heart_outline,
                          title: 'Wishlist',
                          subtitle: 'Alat camping favorit Anda',
                          onTap: () => Get.toNamed(AppRoutes.wishlist),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Ionicons.storefront_outline,
                          title: 'Toko',
                          subtitle:
                              'Jl. Sukaria 5 No.25, Tamamaung, Kec. Panakukkang, Kota Makassar, Sulawesi Selatan 90231',
                        ),
                        _buildMenuItem(
                          context,
                          icon: Ionicons.time_outline,
                          title: 'Jam Operasional',
                          subtitle: '08:00 - 23:30 WITA',
                        ),
                        _buildMenuItem(
                          context,
                          icon: Ionicons.information_circle_outline,
                          title: 'Tentang Aplikasi',
                          subtitle: 'Versi 1.0.0',
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutSheet(authController),
                      icon: const Icon(
                        Ionicons.log_out_outline,
                        color: AppColors.error,
                      ),
                      label: const Text(
                        'Keluar',
                        style: TextStyle(color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutSheet(AuthController authController) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Ionicons.log_out_outline,
                color: AppColors.error,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text('Keluar', style: Theme.of(Get.context!).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Anda yakin ingin keluar dari akun ini?',
              textAlign: TextAlign.center,
              style: Theme.of(Get.context!).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Tidak'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      authController.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Ya, Keluar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: Theme.of(context).textTheme.labelLarge),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: onTap != null
          ? const Icon(Ionicons.chevron_forward, size: 20)
          : null,
    );
  }
}
