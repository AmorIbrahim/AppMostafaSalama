import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/constants/app_colors.dart';
import '../core/network/api_client.dart';
import '../features/orders/order_details_screen.dart';

/// Top-level background message handler for Firebase Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Already initialized or platform stub
  }
}

/// Centralized Push Notification Service managing Firebase Messaging & local alerts
class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static String? _currentFcmToken;
  static bool _isInitialized = false;

  /// Returns current cached FCM token
  static String? get currentFcmToken => _currentFcmToken;

  /// Initialize Firebase Messaging, permissions, channels, and listeners
  static Future<void> init(ApiClient apiClient) async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('[NotificationService] Firebase.initializeApp bypassed/failed: $e');
      // Allow app to continue gracefully even if Firebase is unavailable in environment
      return;
    }

    _isInitialized = true;

    // Register top-level background isolate handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request runtime notification permission (Android 13+ & iOS)
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('[NotificationService] Permission status: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('[NotificationService] Permission request warning: $e');
    }

    // Configure Flutter Local Notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          final int? orderId = int.tryParse(response.payload!);
          if (orderId != null) {
            handleNotificationPayload({'order_id': orderId});
          }
        }
      },
    );

    // High importance notification channel for Android heads-up display
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'delivery_orders',
      'طلبات التوصيل - Delivery Orders',
      description: 'إشعارات إسناد وتحويل طلبات التوصيل لمطعم مصطفى سلامة',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Set foreground presentation options
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground notification listener -> show heads-up alert
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Handle user tap on notification when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationPayload(message.data);
    });

    // Check if app was opened directly from a terminated state notification tap
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        handleNotificationPayload(message.data);
      }
    });

    // Initial token registration
    await registerToken(apiClient);

    // Listen for FCM token refresh events and synchronize with Laravel
    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
      _currentFcmToken = newToken;
      await apiClient.registerDeviceToken(
        fcmToken: newToken,
        platform: defaultTargetPlatform.name,
      );
    });
  }

  /// Retrieve current FCM token and register with Laravel backend
  static Future<void> registerToken(ApiClient apiClient) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        _currentFcmToken = token;
        await apiClient.registerDeviceToken(
          fcmToken: token,
          platform: defaultTargetPlatform.name,
        );
      }
    } catch (e) {
      debugPrint('[NotificationService] registerToken error: $e');
    }
  }

  /// Remove device token from backend on driver logout
  static Future<void> unregisterToken(ApiClient apiClient) async {
    try {
      if (_currentFcmToken != null) {
        await apiClient.unregisterDeviceToken(fcmToken: _currentFcmToken!);
        _currentFcmToken = null;
      }
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('[NotificationService] unregisterToken error: $e');
    }
  }

  /// Display a heads-up local notification when received in foreground
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    final String title = notification?.title ??
        (data['title']?.toString() ?? 'أوردر جديد ليك!');
    final String body = notification?.body ??
        (data['body']?.toString() ?? 'تم تعيين أوردر جديد لك. اضغط للتفاصيل.');
    final dynamic rawOrderId = data['order_id'] ?? data['orderId'];

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'delivery_orders',
      'طلبات التوصيل - Delivery Orders',
      channelDescription: 'إشعارات إسناد وتحويل طلبات التوصيل لمطعم مصطفى سلامة',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: AppColors.primary,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final int id = rawOrderId != null
        ? (int.tryParse(rawOrderId.toString()) ?? 100)
        : (DateTime.now().millisecondsSinceEpoch ~/ 1000);

    await _localNotifications.show(
      id,
      title,
      body,
      platformDetails,
      payload: rawOrderId?.toString(),
    );
  }

  /// Extract orderId and navigate directly to the OrderDetailsScreen
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

  /// In-app MaterialBanner fallback when needed
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
