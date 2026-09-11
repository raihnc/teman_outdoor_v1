import 'package:get/get.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/review_repository.dart';
import '../controllers/admin_navigation_controller.dart';
import '../controllers/admin_product_controller.dart';
import '../controllers/admin_order_controller.dart';
import '../controllers/admin_review_controller.dart';

/// Binding area admin — controller hanya dibuat saat area admin dibuka.
class AdminBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AdminNavigationController());
    Get.put(AdminProductController(Get.find<ProductRepository>()));
    Get.put(AdminOrderController(Get.find<BookingRepository>()));
    Get.put(AdminReviewController(Get.find<ReviewRepository>()));
  }
}
