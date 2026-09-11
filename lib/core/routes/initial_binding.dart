import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/banner_repository.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/cloudinary_service.dart';
import '../controllers/navigation_controller.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/booking/controllers/booking_controller.dart';
import '../../features/orders/controllers/orders_controller.dart';
import '../../features/admin/controllers/admin_product_controller.dart';
import '../../features/admin/controllers/admin_order_controller.dart';
import '../../features/admin/controllers/admin_banner_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put(FirestoreService(), permanent: true);
    Get.put(FirebaseAuthService(), permanent: true);
    Get.put(CloudinaryService(), permanent: true);
    Get.put(NavigationController(), permanent: true);

    // Repositories
    Get.put(AuthRepository(
      authService: Get.find<FirebaseAuthService>(),
      firestoreService: Get.find<FirestoreService>(),
    ), permanent: true);
    Get.put(ProductRepository(Get.find<FirestoreService>()), permanent: true);
    Get.put(BookingRepository(Get.find<FirestoreService>()), permanent: true);
    Get.put(ReviewRepository(Get.find<FirestoreService>()), permanent: true);
    Get.put(WishlistRepository(Get.find<FirestoreService>()), permanent: true);
    Get.put(BannerRepository(Get.find<FirestoreService>()), permanent: true);

    // Controllers
    Get.put(AuthController(Get.find<AuthRepository>()), permanent: true);
    Get.put(HomeController(
      Get.find<ProductRepository>(),
      Get.find<BannerRepository>(),
      Get.find<FirestoreService>(),
    ), permanent: true);
    Get.put(BookingController(Get.find<BookingRepository>()), permanent: true);
    Get.put(OrdersController(Get.find<BookingRepository>()), permanent: true);
    Get.put(AdminProductController(Get.find<ProductRepository>()),
        permanent: true);
    Get.put(AdminOrderController(Get.find<BookingRepository>()),
        permanent: true);
    Get.put(AdminBannerController(
      Get.find<BannerRepository>(),
      Get.find<CloudinaryService>(),
    ), permanent: true);
  }
}
