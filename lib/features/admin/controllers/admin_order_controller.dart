import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/utils/toast.dart';

class AdminOrderController extends GetxController {
  final BookingRepository _bookingRepo;

  AdminOrderController(this._bookingRepo);

  final isLoading = true.obs;
  final bookings = <BookingModel>[].obs;
  final selectedStatus = ''.obs;

  StreamSubscription<List<BookingModel>>? _bookingsSub;
  final _seenBookingIds = <String>{};

  List<BookingModel> get filteredBookings {
    if (selectedStatus.value.isEmpty) return bookings;
    return bookings
        .where((b) => b.status == selectedStatus.value)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    ever(auth.user, (_) {
      if (auth.isLoggedIn) {
        _subscribe();
      } else {
        _bookingsSub?.cancel();
        isLoading.value = true;
      }
    });
    loadBookings();
    _subscribe();
  }

  @override
  void onClose() {
    _bookingsSub?.cancel();
    super.onClose();
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

  /// Real-time sinkronisasi daftar order + notifikasi booking baru masuk
  /// (fallback dashboard, PRD risiko: OneSignal delay/not delivered).
  void _subscribe() {
    _bookingsSub?.cancel();
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      isLoading.value = true;
      return;
    }
    _bookingsSub = _bookingRepo.allBookingsStream().listen((list) {
      final freshPending = list
          .where((b) =>
              b.status == FirestoreConstants.statusPending &&
              !_seenBookingIds.contains(b.id))
          .toList();
      for (final b in list) {
        _seenBookingIds.add(b.id);
      }
      bookings.value = list;
      isLoading.value = false;
      update();
      if (freshPending.isNotEmpty) {
        final name = freshPending.first.userName.isNotEmpty
            ? freshPending.first.userName
            : 'Pengguna';
        showToast('Booking baru: $name — ${freshPending.first.productName}',
            type: ToastType.info);
      }
    }, onError: (e) {
      debugPrint('AdminOrderController: stream error: $e');
    });
  }

  Future<void> updateStatus(String bookingId, String newStatus) async {
    try {
      final auth = Get.find<AuthController>();
      if (newStatus == FirestoreConstants.statusCancelled) {
        await _bookingRepo.cancelBooking(
          bookingId,
          auth.user.value!.uid,
          asAdmin: true,
        );
      } else {
        await _bookingRepo.updateBookingStatus(
          bookingId,
          newStatus,
          auth.user.value!.uid,
        );
      }
      await loadBookings();
      showToast('Status pesanan diperbarui', type: ToastType.success);
    } catch (e) {
      showToast('Gagal memperbarui status', type: ToastType.error);
    }
  }
}
