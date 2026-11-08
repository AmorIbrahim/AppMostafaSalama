import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appmostafasalama/core/constants/api_constants.dart';
import 'package:appmostafasalama/core/constants/app_colors.dart';
import 'package:appmostafasalama/core/errors/app_exception.dart';
import 'package:appmostafasalama/core/utils/app_formatters.dart';
import 'package:appmostafasalama/models/driver_model.dart';
import 'package:appmostafasalama/models/order_model.dart';
import 'package:appmostafasalama/models/delivery_stats_model.dart';
import 'package:appmostafasalama/models/api_response_model.dart';
import 'package:appmostafasalama/providers/qr_scanner_provider.dart';

void main() {
  group('1. QR Token Extraction & Sanitization Tests', () {
    test('Extracts raw HMAC delivery token directly', () {
      const rawToken = '42-a8b3c9d7e1f42805cb798031d2be19ec';
      final extracted = QrScannerProvider.extractToken(rawToken);
      expect(extracted, equals(rawToken));
    });

    test('Extracts token from full production website URL', () {
      const fullUrl = 'https://mostafasalama.com/delivery/confirm/42-a8b3c9d7e1f42805cb798031d2be19ec';
      final extracted = QrScannerProvider.extractToken(fullUrl);
      expect(extracted, equals('42-a8b3c9d7e1f42805cb798031d2be19ec'));
    });

    test('Extracts token from full URL containing query parameters or hashes', () {
      const urlWithQuery = 'https://mostafasalama.com/delivery/confirm/99-abcdef123456?source=qr#scan';
      final extracted = QrScannerProvider.extractToken(urlWithQuery);
      expect(extracted, equals('99-abcdef123456'));
    });

    test('Handles whitespace and trimmed strings', () {
      const whitespaceToken = '   42-a8b3c9d7e1f42805cb798031d2be19ec \n ';
      final extracted = QrScannerProvider.extractToken(whitespaceToken);
      expect(extracted, equals('42-a8b3c9d7e1f42805cb798031d2be19ec'));
    });
  });

  group('2. Data Model Parsing & Serialization Tests', () {
    test('DriverModel properly parses JSON with booleans, ints, and timestamps', () {
      final json = {
        'id': 5,
        'name': 'Ahmed Mahmoud',
        'email': 'driver@mostafasalama.com',
        'phone': '01012345678',
        'role': 'delivery',
        'is_active': true,
        'must_change_password': false,
        'created_at': '2026-11-08T18:00:00.000000Z',
      };

      final driver = DriverModel.fromJson(json);
      expect(driver.id, equals(5));
      expect(driver.name, equals('Ahmed Mahmoud'));
      expect(driver.email, equals('driver@mostafasalama.com'));
      expect(driver.phone, equals('01012345678'));
      expect(driver.isActive, isTrue);
      expect(driver.mustChangePassword, isFalse);
      expect(driver.createdAt, isNotNull);

      final outJson = driver.toJson();
      expect(outJson['id'], equals(5));
      expect(outJson['name'], equals('Ahmed Mahmoud'));
    });

    test('OrderModel parses nested customer and items arrays accurately', () {
      final json = {
        'id': 42,
        'order_number': 'ORD-672DE1F2',
        'status': 'out_for_delivery',
        'total': 245.0,
        'delivery_fee': 20.0,
        'subtotal': 225.0,
        'customer': {
          'id': 18,
          'name': 'Mohamed Ali',
          'phone': '01234567890',
          'email': 'customer@example.com',
          'delivery_address': '15 Abbas El Akkad St, Nasr City, Floor 3, Apt 12'
        },
        'notes': 'Please do not ring bell',
        'items': [
          {
            'id': 81,
            'product_id': 4,
            'name': 'كشري سوبر مصطفى سلامة',
            'price': 75.0,
            'quantity': 2,
            'subtotal': 150.0,
            'bundle': null
          },
          {
            'id': 82,
            'product_id': 9,
            'name': 'طاجن مكرونة باللحمة',
            'price': 75.0,
            'quantity': 1,
            'subtotal': 75.0,
            'bundle': null
          }
        ],
        'assigned_at': '2026-11-08T18:15:00.000000Z',
        'driver_accepted_at': '2026-11-08T18:16:30.000000Z',
        'delivered_at': null,
        'created_at': '2026-11-08T18:05:00.000000Z'
      };

      final order = OrderModel.fromJson(json);
      expect(order.id, equals(42));
      expect(order.orderNumber, equals('ORD-672DE1F2'));
      expect(order.status, equals('out_for_delivery'));
      expect(order.total, equals(245.0));
      expect(order.deliveryFee, equals(20.0));
      expect(order.subtotal, equals(225.0));
      expect(order.customer.name, equals('Mohamed Ali'));
      expect(order.customer.address, contains('Abbas El Akkad'));
      expect(order.items.length, equals(2));
      expect(order.items[0].name, equals('كشري سوبر مصطفى سلامة'));
      expect(order.items[0].quantity, equals(2));
      expect(order.items[0].subtotal, equals(150.0));
      expect(order.items[1].name, equals('طاجن مكرونة باللحمة'));
    });

    test('DeliveryStatsModel correctly computes counters', () {
      final json = {
        'active_orders': 2,
        'completed_today': 8,
        'total_completed': 142,
        'pending_orders': 1,
      };

      final stats = DeliveryStatsModel.fromJson(json);
      expect(stats.activeOrders, equals(2));
      expect(stats.completedToday, equals(8));
      expect(stats.totalCompleted, equals(142));
      expect(stats.pendingOrders, equals(1));
    });

    test('PaginationModel accurately parses pagination metadata', () {
      final json = {
        'current_page': 1,
        'last_page': 3,
        'per_page': 15,
        'total': 45,
        'has_more': true,
      };

      final pagination = PaginationModel.fromJson(json);
      expect(pagination.currentPage, equals(1));
      expect(pagination.lastPage, equals(3));
      expect(pagination.hasMore, isTrue);
    });
  });

  group('3. Formatters & Localization Utilities Tests', () {
    test('Currency formats correctly in EGP in Arabic and English', () {
      final arCurrency = AppFormatters.formatCurrency(245.0, isArabic: true);
      final enCurrency = AppFormatters.formatCurrency(245.0, isArabic: false);

      expect(arCurrency, contains('245.00'));
      expect(arCurrency, contains('ج.م'));
      expect(enCurrency, contains('245.00'));
      expect(enCurrency, contains('EGP'));
    });

    test('Date & Time formatters handle null safely', () {
      expect(AppFormatters.formatDateTime(null), equals('--:--'));
      expect(AppFormatters.formatTimeOnly(null), equals('--:--'));
    });
  });

  group('4. Error Handling & Standard Error Codes Tests', () {
    test('AppException returns localized Arabic message for standard codes', () {
      final exAlreadyDelivered = AppException(
        message: 'Order already delivered',
        messageAr: 'تم تأكيد تسليم هذا الطلب مسبقاً.',
        errorCode: ApiConstants.errAlreadyDelivered,
        statusCode: 409,
      );

      expect(exAlreadyDelivered.localizedMessage(true), equals('تم تأكيد تسليم هذا الطلب مسبقاً.'));
      expect(exAlreadyDelivered.localizedMessage(false), equals('Order already delivered'));

      final exDeactivated = AppException(
        message: 'Account deactivated',
        messageAr: 'تم تعطيل هذا الحساب من قبل إدارة المطعم.',
        errorCode: ApiConstants.errAccountDeactivated,
        statusCode: 403,
      );

      expect(exDeactivated.localizedMessage(true), equals('تم تعطيل هذا الحساب من قبل إدارة المطعم.'));
    });
  });

  group('5. Brand Styling & Status Colors Tests', () {
    test('AppColors provides distinct semantic color for each order status', () {
      expect(AppColors.statusColor('pending'), equals(AppColors.info));
      expect(AppColors.statusColor('confirmed'), equals(AppColors.purple));
      expect(AppColors.statusColor('preparing'), equals(AppColors.warning));
      expect(AppColors.statusColor('out_for_delivery'), equals(const Color(0xFFFF7A00)));
      expect(AppColors.statusColor('delivered'), equals(AppColors.success));
      expect(AppColors.statusColor('cancelled'), equals(AppColors.error));
    });
  });
}
