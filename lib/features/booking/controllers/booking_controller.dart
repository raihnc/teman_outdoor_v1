
import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../core/utils/toast.dart';

class BookingController extends GetxController {
  final BookingRepository _bookingRepo;

  BookingController(this._bookingRepo);

  final isLoading = false.obs;
  final selectedDate = Rxn<DateTime>();
  final duration = 1.obs;
  final quantity = 1.obs;
  final note = ''.obs;

  int totalPrice(ProductModel product) {
    return product.pricePerDay * duration.value * quantity.value;
  }

  void setDuration(int days) => duration.value = days;
  void setQuantity(int qty) => quantity.value = qty.clamp(1, 10);
  void setNote(String value) => note.value = value;

  Future<void> createBooking(ProductModel product) async {
    if (selectedDate.value == null) {
      showToast('Pilih tanggal pengambilan', type: ToastType.warning);
      return;
    }

    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      Get.toNamed('/login');
      return;
    }

    isLoading.value = true;
    try {
      final pickupDate = selectedDate.value!;
      final returnDate = pickupDate.add(Duration(days: duration.value));

      final booking = BookingModel(
        id: '',
        userId: auth.user.value!.uid,
        userName: auth.user.value!.name,
        userPhone: auth.user.value!.phone,
        productId: product.id,
        productName: product.name,
        productThumbnail: product.thumbnailUrl,
        pricePerDay: product.pricePerDay,
        pickupDate: pickupDate,
        returnDate: returnDate,
        duration: duration.value,
        quantity: quantity.value,
        totalPrice: totalPrice(product),
        note: note.value,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _bookingRepo.createBooking(booking);

      Get.back();
      showToast('Booking berhasil dibuat!', type: ToastType.success);
    } catch (e) {
      showToast('Terjadi kesalahan: $e', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
