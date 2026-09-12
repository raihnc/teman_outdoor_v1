import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teman_outdoor_v1/core/utils/right_to_left_joined.dart';
import 'app_routes.dart';
import '../../features/auth/views/splash_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/catalog/views/catalog_view.dart';
import '../../features/catalog/views/search_view.dart';
import '../../features/product_detail/views/product_detail_view.dart';
import '../../features/orders/views/orders_view.dart';
import '../../features/orders/views/order_detail_view.dart';
import '../../features/wishlist/views/wishlist_view.dart';
import '../../features/reviews/views/review_form_view.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/admin/views/admin_product_form_view.dart';
import '../../features/admin/views/admin_order_detail_view.dart';
import '../../features/admin/views/admin_shell.dart';
import '../../features/admin/bindings/admin_bindings.dart';
import '../widgets/main_shell.dart';
import 'admin_guard.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainShell(),
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.catalog,
      page: () => const CatalogView(),
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchView(),
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailView(),
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrdersView(),
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailView(),
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.wishlist,
      page: () => const WishlistView(),
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.reviewForm,
      page: () => const ReviewFormView(),
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.adminProductForm,
      page: () => const AdminProductFormView(),
      binding: AdminBindings(),
      middlewares: [AdminGuard()],
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.adminOrderDetail,
      page: () => const AdminOrderDetailView(),
      binding: AdminBindings(),
      middlewares: [AdminGuard()],
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.admin,
      page: () => const AdminShell(),
      binding: AdminBindings(),
      middlewares: [AdminGuard()],
      customTransition: RightToLeftJoinedTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
  ];
}
