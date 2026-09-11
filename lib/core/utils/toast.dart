import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';

enum ToastType { success, error, warning, info }

void showToast(String message, {ToastType type = ToastType.info}) {
  final Color background = switch (type) {
    ToastType.success => AppColors.success,
    ToastType.error => AppColors.error,
    ToastType.warning => AppColors.warning,
    ToastType.info => AppColors.textPrimary,
  };

  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: background,
    textColor: Colors.white,
    fontSize: 14.0,
  );
}
