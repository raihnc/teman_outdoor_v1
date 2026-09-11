import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/firestore_constants.dart';
import '../controllers/admin_order_controller.dart';

class AdminOrderListView extends StatelessWidget {
  const AdminOrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminOrderController>(
      init: Get.find<AdminOrderController>(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text('Kelola Pesanan'), surfaceTintColor: Colors.transparent),
          body: Column(
            children: [
              _buildStatusFilter(context, controller),
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
                        height: 96,
                        borderRadius: 12,
                      ),
                    );
                  }
                  final bookings = controller.filteredBookings;
                  if (bookings.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada pesanan.'),
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
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final booking = bookings[i];
                        return _buildOrderCard(
                            context, controller, booking);
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

  Widget _buildStatusFilter(
    BuildContext context,
    AdminOrderController controller,
  ) {
    final statuses = [
      ('', 'Semua'),
      ('pending', 'Menunggu'),
      ('confirmed', 'Dikonfirmasi'),
      ('ready_for_pickup', 'Siap Diambil'),
      ('picked_up', 'Diambil'),
      ('returned', 'Dikembalikan'),
      ('completed', 'Selesai'),
      ('cancelled', 'Dibatalkan'),
    ];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (status, label) = statuses[i];
          return Obx(() => FilterChip(
                label: Text(label, style: const TextStyle(fontSize: 12)),
                selected: controller.selectedStatus.value == status,
                onSelected: (_) =>
                    controller.selectedStatus.value = status,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: controller.selectedStatus.value == status
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ));
        },
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    AdminOrderController controller,
    booking,
  ) {
    final nextStatus = _getNextStatus(booking.status);
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.adminOrderDetail,
        arguments: booking,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.productName,
                        style: Theme.of(context).textTheme.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${booking.userName} · ${DateFormatter.formatDateTime(booking.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: booking.status, compact: true),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  CurrencyFormatter.format(booking.totalPrice),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
                const Spacer(),
                Text(
                  '${booking.duration} hari · ${booking.quantity} unit',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (nextStatus != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => controller.updateStatus(
                    booking.id,
                    nextStatus,
                  ),
                  icon: const Icon(Ionicons.arrow_forward, size: 16),
                  label: Text(
                    'Ubah ke "${FirestoreConstants.statusLabel(nextStatus)}"',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _getNextStatus(String current) {
    return switch (current) {
      'pending' => 'confirmed',
      'confirmed' => 'ready_for_pickup',
      'picked_up' => 'returned',
      'returned' => 'completed',
      _ => null,
    };
  }
}
