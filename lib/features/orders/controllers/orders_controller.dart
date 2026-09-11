import 'package:get/get.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/utils/toast.dart';

class OrdersController extends GetxController {
  final BookingRepository _bookingRepo;

  OrdersController(this._bookingRepo);

  final isLoading = true.obs;
  final activeBookings = <BookingModel>[].obs;
  final historyBookings = <BookingModel>[].obs;
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadBookings();
  }

  Future<void> loadBookings() async {
    isLoading.value = true;
    try {
      final auth = Get.find<AuthController>();
      if (!auth.isLoggedIn) return;

      final allBookings = await _bookingRepo.getUserBookings(auth.user.value!.uid);
      activeBookings.value = allBookings
          .where((b) =>
              b.status != FirestoreConstants.statusCompleted &&
              b.status != FirestoreConstants.statusCancelled)
          .toList();
      historyBookings.value = allBookings
          .where((b) =>
              b.status == FirestoreConstants.statusCompleted ||
              b.status == FirestoreConstants.statusCancelled)
          .toList();
    } catch (e) {
      showToast('Gagal memuat pesanan', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      final auth = Get.find<AuthController>();
      await _bookingRepo.updateBookingStatus(
        bookingId,
        FirestoreConstants.statusCancelled,
        auth.user.value!.uid,
      );
      await loadBookings();
      showToast('Pesanan dibatalkan', type: ToastType.success);
    } catch (e) {
      showToast('Gagal membatalkan pesanan', type: ToastType.error);
    }
  }

  Future<void> markPickedUp(String bookingId) async {
    try {
      final auth = Get.find<AuthController>();
      await _bookingRepo.updateBookingStatus(
        bookingId,
        FirestoreConstants.statusPickedUp,
        auth.user.value!.uid,
      );
      await loadBookings();
      showToast('Status diperbarui', type: ToastType.success);
    } catch (e) {
      showToast('Gagal memperbarui status', type: ToastType.error);
    }
  }

  Future<void> markReturned(String bookingId) async {
    try {
      final auth = Get.find<AuthController>();
      await _bookingRepo.updateBookingStatus(
        bookingId,
        FirestoreConstants.statusReturned,
        auth.user.value!.uid,
      );
      await loadBookings();
      showToast('Alat berhasil dikembalikan', type: ToastType.success);
    } catch (e) {
      showToast('Gagal mengembalikan alat', type: ToastType.error);
    }
  }

  List<BookingModel> get currentBookings =>
      selectedTab.value == 0 ? activeBookings : historyBookings;
}
