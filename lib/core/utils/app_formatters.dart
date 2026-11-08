import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Formatter utilities for currency (EGP), timestamps, phone calling, and map directions
class AppFormatters {
  /// Format money in Egyptian Pounds (EGP / ج.م)
  static String formatCurrency(double amount, {bool isArabic = true}) {
    final formatter = NumberFormat('#,##0.00');
    final formatted = formatter.format(amount);
    return isArabic ? '$formatted ج.م' : '$formatted EGP';
  }

  /// Format date and time
  static String formatDateTime(DateTime? dateTime, {bool isArabic = true}) {
    if (dateTime == null) return '--:--';
    final localTime = dateTime.toLocal();
    final formatter = DateFormat('yyyy/MM/dd  hh:mm a', isArabic ? 'ar' : 'en');
    return formatter.format(localTime);
  }

  /// Format time only
  static String formatTimeOnly(DateTime? dateTime, {bool isArabic = true}) {
    if (dateTime == null) return '--:--';
    final localTime = dateTime.toLocal();
    final formatter = DateFormat('hh:mm a', isArabic ? 'ar' : 'en');
    return formatter.format(localTime);
  }

  /// Launch phone call application
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'\s+|-'), '');
    final Uri uri = Uri(scheme: 'tel', path: cleaned);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
    } catch (_) {}
    return false;
  }

  /// Launch Google Maps navigation for an address
  static Future<bool> openGoogleMaps(String address) async {
    final encoded = Uri.encodeComponent(address);
    // Try geo intent first, then standard universal web URL
    final Uri webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    try {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}

