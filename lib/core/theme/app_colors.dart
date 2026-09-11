import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF2D6A4F);
  static const primaryLight = Color(0xFF40916C);
  static const primaryDark = Color(0xFF1B4332);
  static const secondary = Color(0xFFD4A373);
  static const secondaryLight = Color(0xFFE9C46A);

  static const surface = Color(0xFFFAFAF8);
  static const background = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);

  static const error = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  static const border = Color(0xFFE5E7EB);
  static const divider = Color(0xFFF3F4F6);

  static const stockAvailable = Color(0xFF16A34A);
  static const stockLow = Color(0xFFF59E0B);
  static const stockOut = Color(0xFFDC2626);

  static Color statusColor(String status) {
    return switch (status) {
      'pending' => warning,
      'confirmed' => info,
      'ready_for_pickup' => primary,
      'picked_up' => secondary,
      'returned' => primaryLight,
      'completed' => success,
      'cancelled' => error,
      _ => textSecondary,
    };
  }
}
