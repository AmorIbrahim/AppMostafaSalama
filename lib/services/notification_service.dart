import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../features/orders/order_details_screen.dart';

/// Notification Service handling delivery assignments, re-assignments, and order routing
class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Handle incoming notification payload from backend
  static void handleNotificationPayload(Map<String, dynamic> data) {
    final dynamic rawOrderId = data['order_id'] ?? data['orderId'] ?? data['id'];
    if (rawOrderId != null) {
      final int? orderId = int.tryParse(rawOrderId.toString());
      if (orderId != null && navigatorKey.currentState != null) {
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(orderId: orderId),
          ),
        );
      }
    }
  }

  /// Show an in-app foreground banner when a new order assignment notification arrives
  static void showForegroundNotificationBanner({
    required BuildContext context,
    required String title,
    required String body,
    int? orderId,
  }) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
          child: const Icon(Icons.delivery_dining_rounded, color: AppColors.primary, size: 22),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              body,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          if (orderId != null)
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsScreen(orderId: orderId),
                  ),
                );
              },
              child: const Text(
                'عرض الطلب',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 18),
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          ),
        ],
      ),
    );
  }
}
