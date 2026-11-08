import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/errors/app_exception.dart';
import '../models/order_model.dart';
import '../models/delivery_stats_model.dart';
import '../models/api_response_model.dart';

/// Provider managing driver's assigned orders, filtering, operations, and live metrics
class OrdersProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<OrderModel> _allOrders = [];
  DeliveryStatsModel? _stats;
  PaginationModel? _pagination;

  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  String _selectedFilter = 'all'; // 'all', 'pending', 'preparing', 'out_for_delivery', 'delivered'
  String _searchQuery = '';

  OrdersProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  List<OrderModel> get orders => _filteredOrders();
  List<OrderModel> get rawOrders => _allOrders;
  DeliveryStatsModel? get stats => _stats;
  PaginationModel? get pagination => _pagination;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  /// Fetch orders list from backend
  Future<void> fetchOrders({bool isRefresh = false}) async {
    if (isRefresh) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch both orders and driver stats
      final results = await Future.wait([
        _apiClient.getOrders(status: 'all', page: 1, perPage: 50),
        _apiClient.getMe(),
      ]);

      final ordersData = results[0];
      final meData = results[1];

      // Parse Orders
      if (ordersData['data'] != null) {
        final List list = ordersData['data']['orders'] ?? [];
        _allOrders = list
            .whereType<Map<String, dynamic>>()
            .map((json) => OrderModel.fromJson(json))
            .toList();

        if (ordersData['data']['pagination'] != null) {
          _pagination = PaginationModel.fromJson(
            ordersData['data']['pagination'] as Map<String, dynamic>,
          );
        }
      }

      // Parse Operational Stats
      if (meData['data']?['stats'] != null) {
        _stats = DeliveryStatsModel.fromJson(
          meData['data']['stats'] as Map<String, dynamic>,
        );
      } else {
        // Fallback compute stats from orders if backend doesn't provide
        _stats = _computeStatsFromOrders(_allOrders);
      }

      _errorMessage = null;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load assigned deliveries.';
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  DeliveryStatsModel _computeStatsFromOrders(List<OrderModel> orders) {
    int active = 0;
    int completed = 0;
    int pending = 0;
    final now = DateTime.now();

    for (final o in orders) {
      final st = o.status.toLowerCase();
      if (st == 'delivered') {
        if (o.deliveredAt != null &&
            o.deliveredAt!.year == now.year &&
            o.deliveredAt!.month == now.month &&
            o.deliveredAt!.day == now.day) {
          completed++;
        }
      } else if (st == 'cancelled') {
        // ignore
      } else if (st == 'pending' || st == 'confirmed') {
        pending++;
        active++;
      } else {
        active++;
      }
    }

    return DeliveryStatsModel(
      activeOrders: active,
      completedToday: completed,
      totalCompleted: completed,
      pendingOrders: pending,
    );
  }

  /// Filter orders by tab
  void setFilter(String filter) {
    _selectedFilter = filter.toLowerCase();
    notifyListeners();
  }

  /// Search orders by order number, customer name, or customer phone
  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  List<OrderModel> _filteredOrders() {
    return _allOrders.where((order) {
      // 1. Status Filter
      if (_selectedFilter != 'all') {
        if (_selectedFilter == 'pending') {
          if (order.status != 'pending' && order.status != 'confirmed') {
            return false;
          }
        } else if (_selectedFilter == 'active') {
          if (order.status == 'delivered' || order.status == 'cancelled') {
            return false;
          }
        } else if (order.status != _selectedFilter) {
          return false;
        }
      }

      // 2. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final numMatch = order.orderNumber.toLowerCase().contains(_searchQuery);
        final nameMatch = order.customer.name.toLowerCase().contains(_searchQuery);
        final phoneMatch = order.customer.phone.contains(_searchQuery);
        final addrMatch = order.customer.address.toLowerCase().contains(_searchQuery);
        return numMatch || nameMatch || phoneMatch || addrMatch;
      }

      return true;
    }).toList();
  }

  /// Driver accepts assigned order
  Future<bool> acceptOrder(int orderId) async {
    try {
      final updatedOrder = await _apiClient.acceptOrder(orderId);
      _updateLocalOrder(updatedOrder);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Driver starts delivery journey
  Future<bool> startDelivery(int orderId) async {
    try {
      final updatedOrder = await _apiClient.startDelivery(orderId);
      _updateLocalOrder(updatedOrder);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Update order when successfully delivered via QR scan
  void onOrderDelivered(int orderId, DateTime deliveredAt) {
    final index = _allOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _allOrders[index] = _allOrders[index].copyWith(
        status: 'delivered',
        deliveredAt: deliveredAt,
      );
      _stats = DeliveryStatsModel(
        activeOrders: (_stats?.activeOrders ?? 1) > 0 ? (_stats!.activeOrders - 1) : 0,
        completedToday: (_stats?.completedToday ?? 0) + 1,
        totalCompleted: (_stats?.totalCompleted ?? 0) + 1,
        pendingOrders: _stats?.pendingOrders ?? 0,
      );
      notifyListeners();
    }
  }

  void _updateLocalOrder(OrderModel updated) {
    final index = _allOrders.indexWhere((o) => o.id == updated.id);
    if (index != -1) {
      _allOrders[index] = updated;
    } else {
      _allOrders.insert(0, updated);
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

