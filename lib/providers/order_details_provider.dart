import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/errors/app_exception.dart';
import '../models/order_model.dart';

/// Provider for single order inspection, status progression, and items breakdown
class OrderDetailsProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final int orderId;

  OrderModel? _order;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;

  OrderDetailsProvider({
    required ApiClient apiClient,
    required this.orderId,
    OrderModel? initialOrder,
  })  : _apiClient = apiClient,
        _order = initialOrder;

  OrderModel? get order => _order;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;

  /// Load complete order details including all items and instructions
  Future<void> fetchOrderDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _order = await _apiClient.getOrderDetails(orderId);
      _errorMessage = null;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load order details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Accept assigned order
  Future<bool> acceptOrder() async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _order = await _apiClient.acceptOrder(orderId);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Start delivery trip (Out for Delivery)
  Future<bool> startDelivery() async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _order = await _apiClient.startDelivery(orderId);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  void markAsDelivered(DateTime deliveredAt) {
    if (_order != null) {
      _order = _order!.copyWith(
        status: 'delivered',
        deliveredAt: deliveredAt,
      );
      notifyListeners();
    }
  }
}

