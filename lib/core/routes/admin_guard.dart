import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/controllers/auth_controller.dart';
import 'app_routes.dart';

/// Middleware route admin: non-admin dialihkan ke MainShell.
class AdminGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    if (!auth.isAdmin) {
      return const RouteSettings(name: AppRoutes.main);
    }
    return null;
  }
}
