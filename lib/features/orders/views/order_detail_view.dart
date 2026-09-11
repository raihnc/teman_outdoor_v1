import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/constants/firestore_constants.dart';
import '../controllers/orders_controller.dart';

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key});

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
    final booking = Get.arguments;
    return GetBuilder<OrdersController>(
      init: Get.find<OrdersController>(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text('Detail Pesanan')),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              context.screen.pagePadding,
              16,
              context.screen.pagePadding,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Info
                Container(
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
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
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
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${booking.quantity}x · ${booking.duration} hari',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.formatPerDay(booking.pricePerDay),
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
                const SizedBox(height: 20),

                // Status
                _buildSection(
                  context,
                  'Status Pesanan',
                  Column(
                    children: [
                      _buildStatusTimeline(booking),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Details
                _buildSection(
                  context,
                  'Detail',
                  Column(
                    children: [
                      _buildDetailRow(
                        'Tanggal Pengambilan',
                        DateFormatter.formatFullDate(booking.pickupDate),
                      ),
                      _buildDetailRow(
                        'Tanggal Pengembalian',
                        DateFormatter.formatFullDate(booking.returnDate),
                      ),
                      _buildDetailRow(
                        'Durasi',
                        '${booking.duration} hari',
                      ),
                      _buildDetailRow(
                        'Jumlah',
                        '${booking.quantity} unit',
                      ),
                      if (booking.note.isNotEmpty)
                        _buildDetailRow('Catatan', booking.note),
                      const Divider(),
                      _buildDetailRow(
                        'Total Pembayaran',
                        CurrencyFormatter.format(booking.totalPrice),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                if (booking.status == FirestoreConstants.statusPending ||
                    booking.status == FirestoreConstants.statusConfirmed)
                  CustomButton(
                    label: 'Batalkan Pesanan',
                    color: AppColors.error,
                    onPressed: () {
                      Get.defaultDialog(
                        title: 'Batalkan Pesanan?',
                        middleText: 'Anda yakin ingin membatalkan pesanan ini?',
                        textConfirm: 'Ya',
                        textCancel: 'Tidak',
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          Get.back();
                          controller.cancelBooking(booking.id);
                        },
                      );
                    },
                  ),
                if (booking.status == FirestoreConstants.statusReadyForPickup)
                  CustomButton(
                    label: 'Sudah Diambil',
                    icon: Ionicons.checkmark_circle_outline,
                    onPressed: () => controller.markPickedUp(booking.id),
                  ),
                if (booking.status == FirestoreConstants.statusPickedUp)
                  CustomButton(
                    label: 'Kembalikan Alat',
                    icon: Ionicons.return_up_back_outline,
                    onPressed: () => controller.markReturned(booking.id),
                  ),
                if (booking.status == FirestoreConstants.statusCompleted &&
                    !booking.reviewed)
                  CustomButton(
                    label: 'Beri Ulasan',
                    icon: Ionicons.star_outline,
                    color: AppColors.warning,
                    onPressed: () => Get.toNamed('/review-form', arguments: booking),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    Widget child,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.screen.pagePadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                fontSize: isBold ? 16 : 14,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(booking) {
    final steps = FirestoreConstants.statusOrder;
    final currentIdx = steps.indexOf(booking.status);
    return Column(
      children: List.generate(steps.length, (i) {
        final isActive = i <= currentIdx;
        final isCurrent = i == currentIdx;
        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                  child: isCurrent
                      ? const Icon(Icons.circle, size: 10, color: Colors.white)
                      : isActive
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                ),
                if (i < steps.length - 1)
                  Container(
                    width: 2,
                    height: 24,
                    color: isActive && i < currentIdx
                        ? AppColors.primary
                        : AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              FirestoreConstants.statusLabel(steps[i]),
              style: TextStyle(
                color: isActive ? AppColors.textPrimary : AppColors.textHint,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        );
      }),
    );
  }
}
