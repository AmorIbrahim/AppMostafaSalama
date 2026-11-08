import 'package:flutter/material.dart';

/// Authentic Mostafa Salama visual identity & color palette
class AppColors {
  // Brand Primary (Golden Amber)
  static const Color primary = Color(0xFFF5A900);
  static const Color primaryDark = Color(0xFFD89200);
  static const Color primaryLight = Color(0xFFFFBF33);
  static const Color primaryContainer = Color(0x2BF5A900);

  // Dark Theme Background & Surfaces (Official mostafasalama.com palette)
  static const Color darkBackground = Color(0xFF08090B);
  static const Color darkSurface = Color(0xFF15171A);
  static const Color darkCard = Color(0xFF15171A);
  static const Color darkCardElevated = Color(0xFF0D0F12);
  static const Color darkSecondarySurface = Color(0xFF1F2329);

  // Light Theme Background & Surfaces
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSecondarySurface = Color(0xFFF1F3F5);

  // Borders
  static const Color darkBorder = Color(0x33F5A900); // #F5A900 with 20% opacity
  static const Color darkBorderSubtle = Color(0x1AF5A900);
  static const Color darkDivider = Color(0xFF23272E);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFE5E7EB);

  // Text Colors
  static const Color textLightPrimary = Color(0xFF111827);
  static const Color textLightSecondary = Color(0xFF4B5563);
  static const Color textLightMuted = Color(0xFF9CA3AF);

  static const Color textDarkPrimary = Color(0xFFF5F5F5);
  static const Color textDarkSecondary = Color(0xFFD1D5DB);
  static const Color textDarkMuted = Color(0xFF9CA3AF);

  // Status & Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0x2210B981);
  static const Color warning = Color(0xFFF5A900);
  static const Color warningLight = Color(0x22F5A900);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0x22EF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0x223B82F6);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0x228B5CF6);

  // Order Lifecycle Colors
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return info;
      case 'confirmed':
        return purple;
      case 'preparing':
        return warning;
      case 'out_for_delivery':
        return const Color(0xFFFF7A00); // Bright Orange
      case 'delivered':
        return success;
      case 'cancelled':
        return error;
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  static Color statusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0x1F3B82F6);
      case 'confirmed':
        return const Color(0x1F8B5CF6);
      case 'preparing':
        return const Color(0x1FF5A900);
      case 'out_for_delivery':
        return const Color(0x26FF7A00);
      case 'delivered':
        return const Color(0x1F10B981);
      case 'cancelled':
        return const Color(0x1FEF4444);
      default:
        return const Color(0x1F9CA3AF);
    }
  }
}

