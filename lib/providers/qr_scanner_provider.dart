import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/network/api_client.dart';
import '../core/errors/app_exception.dart';
import '../models/order_model.dart';

/// Provider handling QR code reading, token sanitization, duplicate scan prevention, and backend delivery confirmation
class QrScannerProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  bool _isProcessing = false;
  bool _isDelivered = false;
  String? _errorMessage;
  OrderModel? _confirmedOrder;
  Map<String, dynamic>? _confirmationDetails;
  String? _lastScannedValue;
  DateTime? _lastScanTime;

  QrScannerProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  bool get isProcessing => _isProcessing;
  bool get isDelivered => _isDelivered;
  String? get errorMessage => _errorMessage;
  OrderModel? get confirmedOrder => _confirmedOrder;
  Map<String, dynamic>? get confirmationDetails => _confirmationDetails;

  /// Extract token from raw barcode value (handles both raw tokens and full delivery URLs)
  static String extractToken(String raw) {
    String trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    // If it's a URL like https://mostafasalama.com/delivery/confirm/42-a8b3c9d7...
    if (trimmed.contains('/delivery/confirm/')) {
      final parts = trimmed.split('/delivery/confirm/');
      if (parts.length > 1) {
        return parts[1].split('?').first.split('#').first.trim();
      }
    } else if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
    }

    return trimmed;
  }

  /// Process scanned barcode with strict concurrency and double-submission protection
  Future<bool> processBarcode(String rawBarcode, {int? expectedOrderId}) async {
    // 1. Lock check: prevent concurrent processing
    if (_isProcessing || _isDelivered) return false;

    // 2. Debounce: prevent duplicate scan within 2.5 seconds for identical code
    final now = DateTime.now();
    if (_lastScannedValue == rawBarcode &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!).inMilliseconds < 2500) {
      return false;
    }

    final token = extractToken(rawBarcode);
    if (token.isEmpty) {
      _errorMessage = 'Invalid QR code scanned.';
      notifyListeners();
      return false;
    }

    _lastScannedValue = rawBarcode;
    _lastScanTime = now;
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Haptic feedback on barcode detection
      HapticFeedback.mediumImpact();

      // Submit to backend
      final response = await _apiClient.confirmQrDelivery(
        qrToken: token,
        orderId: expectedOrderId,
      );

      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        if (data['order'] != null) {
          _confirmedOrder = OrderModel.fromJson(data['order'] as Map<String, dynamic>);
        }
        if (data['delivery_confirmation'] != null) {
          _confirmationDetails = data['delivery_confirmation'] as Map<String, dynamic>;
        }
      }

      // Haptic celebration on success
      HapticFeedback.heavyImpact();

      _isDelivered = true;
      _isProcessing = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _isProcessing = false;
      _errorMessage = e.message;
      HapticFeedback.vibrate();
      notifyListeners();
      return false;
    } catch (e) {
      _isProcessing = false;
      _errorMessage = 'Failed to confirm delivery with restaurant server.';
      HapticFeedback.vibrate();
      notifyListeners();
      return false;
    }
  }

  /// Reset scanner state for a new scan
  void resetScanner() {
    _isProcessing = false;
    _isDelivered = false;
    _errorMessage = null;
    _confirmedOrder = null;
    _confirmationDetails = null;
    _lastScannedValue = null;
    _lastScanTime = null;
    notifyListeners();
  }
}

