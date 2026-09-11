import 'package:get/get.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../core/utils/toast.dart';

class AdminOrderController extends GetxController {
  final BookingRepository _bookingRepo;

  AdminOrderController(this._bookingRepo);

  final isLoading = true.obs;
  final bookings = <BookingModel>[].obs;
  final selectedStatus = ''.obs;

  List<BookingModel> get filteredBookings {
    if (selectedStatus.value.isEmpty) return bookings;
    return bookings
        .where((b) => b.status == selectedStatus.value)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadBookings();
  }

  Future<void> loadBookings() async {
    isLoading.value = true;
    try {
      bookings.value = await _bookingRepo.getAllBookings();
    } catch (e) {
      showToast('Gagal memuat pesanan', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(String bookingId, String newStatus) async {
    try {
      final auth = Get.find<AuthController>();
      await _bookingRepo.updateBookingStatus(
        bookingId,
        newStatus,
        auth.user.value!.uid,
      );
      await loadBookings();
      showToast('Status pesanan diperbarui', type: ToastType.success);
    } catch (e) {
      showToast('Gagal memperbarui status', type: ToastType.error);
    }
  }
}
