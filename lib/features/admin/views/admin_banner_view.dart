import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../controllers/admin_banner_controller.dart';

class AdminBannerView extends StatelessWidget {
  const AdminBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminBannerController>(
      init: Get.find<AdminBannerController>(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text('Kelola Banner')),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final picker = ImagePicker();
              final picked = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );
              if (picked != null) {
                await controller.addBanner(File(picked.path));
              }
            },
            child: const Icon(Ionicons.add),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const ShimmerLoading(
                  width: double.infinity,
                  height: 180,
                  borderRadius: 16,
                ),
              );
            }
            if (controller.banners.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Ionicons.images_outline,
                        size: 64, color: AppColors.textHint),
                    SizedBox(height: 16),
                    Text('Belum ada banner.'),
                    SizedBox(height: 8),
                    Text(
                      'Tap tombol + untuk menambahkan.',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                context.screen.pagePadding,
                16,
                context.screen.pagePadding,
                100,
              ),
              itemCount: controller.banners.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final banner = controller.banners[i];
                return Dismissible(
                  key: Key(banner.id),
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
                      title: 'Hapus Banner?',
                      middleText: 'Yakin ingin menghapus banner ini?',
                      textConfirm: 'Hapus',
                      textCancel: 'Batal',
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        Get.back(result: true);
                        controller.deleteBanner(banner.id);
                      },
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: banner.imageUrl,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            height: 180,
                            color: AppColors.surface,
                            child:
                                const Icon(Ionicons.image_outline, size: 48),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }
}
