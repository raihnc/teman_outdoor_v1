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
            body: Column(
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 0.8,
                    color: AppColors.background,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryDark,
                              border: Border.all(
                                color: AppColors.primaryLight,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 33,
                              backgroundColor: Colors.transparent,
                              backgroundImage: user?.photoUrl.isNotEmpty == true
                                  ? NetworkImage(user!.photoUrl)
                                  : null,
                              child: user?.photoUrl.isEmpty != false
                                  ? Text(
                                      user?.name.isNotEmpty == true
                                          ? user!.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name.toUpperCase() ?? '',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user?.email ?? '',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                if (user?.phone.isNotEmpty == true) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    user!.phone,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screen.pagePadding),
                  child: _buildMenuGroup(
                    context,
                    title: 'Layanan',
                    children: [
                      _buildMenuItem(
                        context,
                        icon: Ionicons.heart_outline,
                        title: 'Wishlist',
                        subtitle: 'Alat camping favorit Anda',
                        onTap: () => Get.toNamed(AppRoutes.wishlist),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screen.pagePadding),
                  child: _buildMenuGroup(
                    context,
                    title: 'Informasi',
                    children: [
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
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    screen.pagePadding,
                    24,
                    screen.pagePadding,
                    0,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutSheet(authController),
                    icon: const Icon(
                      Ionicons.log_out_outline,
                      color: AppColors.background,
                    ),
                    label: const Text(
                      'Keluar',
                      style: TextStyle(color: AppColors.background),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screen = context.screen;
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
        screen.pagePadding,
        10,
        screen.pagePadding,
        10,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          
        ],
      ),
    );
  }

  Widget _buildMenuGroup(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 20),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Card(
          elevation: 0.8,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: 68,
                    color: AppColors.divider,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
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
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Ionicons.log_out_outline,
                color: AppColors.background,
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
      enableFeedback: false,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(title, style: Theme.of(context).textTheme.labelLarge),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: onTap != null
          ? const Icon(Ionicons.chevron_forward, size: 20)
          : null,
    );
  }
}
