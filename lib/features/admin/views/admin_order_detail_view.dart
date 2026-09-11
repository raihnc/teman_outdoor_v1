import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/constants/firestore_constants.dart';
import '../controllers/admin_order_controller.dart';

class AdminOrderDetailView extends StatelessWidget {
  const AdminOrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = Get.arguments;
    return GetBuilder<AdminOrderController>(
      init: Get.find<AdminOrderController>(),
      builder: (controller) {
        final nextStatus = _getNextStatus(booking.status);
        return Scaffold(
          appBar: AppBar(title: const Text('Detail Pesanan'), surfaceTintColor: Colors.transparent,),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status
                Center(
                  child: Column(
                    children: [
                      StatusBadge(status: booking.status),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Customer Info
                _buildSection(
                  context,
                  'Info Pelanggan',
                  Column(
                    children: [
                      _buildDetailRow('Nama', booking.userName),
                      _buildDetailRow('Telepon', booking.userPhone),
                      if (booking.note.isNotEmpty)
                        _buildDetailRow('Catatan', booking.note),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Product Info
                _buildSection(
                  context,
                  'Detail Pesanan',
                  Column(
                    children: [
                      _buildDetailRow('Produk', booking.productName),
                      _buildDetailRow(
                        'Harga/Hari',
                        CurrencyFormatter.format(booking.pricePerDay),
                      ),
                      _buildDetailRow('Durasi', '${booking.duration} hari'),
                      _buildDetailRow('Jumlah', '${booking.quantity} unit'),
                      const Divider(),
                      _buildDetailRow(
                        'Total',
                        CurrencyFormatter.format(booking.totalPrice),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Dates
                _buildSection(
                  context,
                  'Tanggal',
                  Column(
                    children: [
                      _buildDetailRow(
                        'Dipesan',
                        DateFormatter.formatDateTime(booking.createdAt),
                      ),
                      _buildDetailRow(
                        'Pengambilan',
                        DateFormatter.formatFullDate(booking.pickupDate),
                      ),
                      _buildDetailRow(
                        'Pengembalian',
                        DateFormatter.formatFullDate(booking.returnDate),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (nextStatus != null)
                  CustomButton(
                    label:
                        'Ubah ke "${FirestoreConstants.statusLabel(nextStatus)}"',
                    icon: Ionicons.arrow_forward,
                    onPressed: () => controller.updateStatus(
                      booking.id,
                      nextStatus,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
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
