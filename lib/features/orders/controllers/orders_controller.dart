import 'dart:async';
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

  StreamSubscription<List<BookingModel>>? _bookingsSub;

  @override
  void onInit() {
    super.onInit();
    loadBookings();
    ever(Get.find<AuthController>().user, (_) {
      _subscribe();
      loadBookings();
    });
  }

  @override
  void onClose() {
    _bookingsSub?.cancel();
    super.onClose();
  }

  Future<void> loadBookings() async {
    isLoading.value = true;
    try {
      final auth = Get.find<AuthController>();
      if (!auth.isLoggedIn) return;

      final allBookings = await _bookingRepo.getUserBookings(auth.user.value!.uid);
      _partition(allBookings);
    } catch (e) {
      showToast('Gagal memuat pesanan', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  /// Update real-time daftar pesanan (pengganti push notification v1.0):
  /// status berubah otomatis saat admin/kondisi toko mengubah data.
  void _subscribe() {
    _bookingsSub?.cancel();
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) return;

    _bookingsSub = _bookingRepo.userBookingsStream(auth.user.value!.uid)
        .listen((list) {
      _partition(list);
    }, onError: (_) {});
  }

  void _partition(List<BookingModel> allBookings) {
    isLoading.value = false;
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
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      final auth = Get.find<AuthController>();
      await _bookingRepo.cancelBooking(
        bookingId,
        auth.user.value!.uid,
      );
      await loadBookings();
      showToast('Pesanan dibatalkan', type: ToastType.success);
    } catch (e) {
      showToast(e.toString(), type: ToastType.error);
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
      await _bookingRepo.markReturned(bookingId, auth.user.value!.uid);
      await loadBookings();
      showToast('Alat berhasil dikembalikan', type: ToastType.success);
    } catch (e) {
      showToast(e.toString(), type: ToastType.error);
    }
  }

  List<BookingModel> get currentBookings =>
      selectedTab.value == 0 ? activeBookings : historyBookings;
}
