import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/product_model.dart';
import '../controllers/booking_controller.dart';

class BookingSheet extends StatelessWidget {
  final ProductModel product;

  const BookingSheet({super.key, required this.product});

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
    return GetBuilder<BookingController>(
      init: Get.find<BookingController>(),
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pesan ${product.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),

                // Pickup Date
                Text(
                  'Tanggal Pengambilan',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          controller.selectedDate.value ??
                          now.add(const Duration(days: 1)),
                      firstDate: now.add(const Duration(days: 1)),
                      lastDate: now.add(const Duration(days: 30)),
                      locale: const Locale('id', 'ID'),
                    );
                    if (picked != null) {
                      controller.selectedDate.value = picked;
                      controller.update();
                    }
                  },
                  child: Obx(
                    () => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Ionicons.calendar_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            controller.selectedDate.value != null
                                ? '${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}'
                                : 'Pilih tanggal',
                            style: TextStyle(
                              color: controller.selectedDate.value != null
                                  ? AppColors.textPrimary
                                  : AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Duration
                Text(
                  'Durasi Sewa',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [1, 2, 3, 5, 7].map((days) {
                      final isSelected = controller.duration.value == days;
                      return GestureDetector(
                        onTap: () => controller.setDuration(days),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            '$days hari',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Quantity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jumlah',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Obx(
                      () => Row(
                        children: [
                          IconButton(
                            onPressed: controller.quantity.value > 1
                                ? () => controller.setQuantity(
                                    controller.quantity.value - 1,
                                  )
                                : null,
                            icon: const Icon(Ionicons.remove_circle_outline),
                          ),
                          Text(
                            '${controller.quantity.value}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: controller.quantity.value < product.stock
                                ? () => controller.setQuantity(
                                    controller.quantity.value + 1,
                                  )
                                : null,
                            icon: const Icon(Ionicons.add_circle_outline),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Note
                TextField(
                  maxLines: 2,
                  maxLength: 200,
                  onChanged: controller.setNote,
                  decoration: const InputDecoration(
                    hintText: 'Catatan tambahan (opsional)',
                  ),
                ),
                const SizedBox(height: 16),

                // Summary
                Obx(
                  () => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total'),
                        Text(
                          CurrencyFormatter.format(
                            controller.totalPrice(product),
                          ),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.createBooking(product),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Konfirmasi Booking'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
