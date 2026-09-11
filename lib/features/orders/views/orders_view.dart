import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/orders_controller.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

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
    return GetBuilder<OrdersController>(
      init: Get.find<OrdersController>(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text('Pesanan Saya')),
          body: Column(
            children: [
              _buildTabBar(context, controller),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildLoadingList(context);
                  }
                  final bookings = controller.currentBookings;
                  if (bookings.isEmpty) {
                    return EmptyState(
                      icon: Ionicons.receipt_outline,
                      title: controller.selectedTab.value == 0
                          ? 'Belum Ada Pesanan'
                          : 'Belum Ada Riwayat',
                      subtitle: controller.selectedTab.value == 0
                          ? 'Mulai sewa alat camping sekarang!'
                          : 'Riwayat pesanan Anda akan muncul di sini.',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: controller.loadBookings,
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        context.screen.pagePadding,
                        12,
                        context.screen.pagePadding,
                        100,
                      ),
                      itemCount: bookings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final booking = bookings[i];
                        return _buildOrderCard(context, controller, booking);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(BuildContext context, OrdersController controller) {
    return Obx(() => Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedTab.value = 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.selectedTab.value == 0
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Aktif (${controller.activeBookings.length})',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: controller.selectedTab.value == 0
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedTab.value = 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.selectedTab.value == 1
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Riwayat (${controller.historyBookings.length})',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: controller.selectedTab.value == 1
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrdersController controller,
    booking,
  ) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.orderDetail, arguments: booking),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: booking.productThumbnail,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ShimmerLoading(
                  width: 72,
                  height: 72,
                  borderRadius: 12,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  color: AppColors.surface,
                  child: const Icon(Ionicons.image_outline),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.productName,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormatter.formatDayMonth(booking.pickupDate)} · ${booking.duration} hari',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.format(booking.totalPrice),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                      StatusBadge(status: booking.status, compact: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingList(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        context.screen.pagePadding,
        12,
        context.screen.pagePadding,
        100,
      ),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const ShimmerLoading(
        width: double.infinity,
        height: 96,
        borderRadius: 16,
      ),
    );
  }
}
