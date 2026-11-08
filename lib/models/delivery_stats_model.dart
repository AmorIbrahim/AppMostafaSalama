/// Delivery operational statistics for the authenticated driver
class DeliveryStatsModel {
  final int activeOrders;
  final int completedToday;
  final int totalCompleted;
  final int pendingOrders;

  DeliveryStatsModel({
    this.activeOrders = 0,
    this.completedToday = 0,
    this.totalCompleted = 0,
    this.pendingOrders = 0,
  });

  factory DeliveryStatsModel.fromJson(Map<String, dynamic> json) {
    return DeliveryStatsModel(
      activeOrders: _parseInt(json['active_orders']),
      completedToday: _parseInt(json['completed_today']),
      totalCompleted: _parseInt(json['total_completed']),
      pendingOrders: _parseInt(json['pending_orders']),
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'active_orders': activeOrders,
      'completed_today': completedToday,
      'total_completed': totalCompleted,
      'pending_orders': pendingOrders,
    };
  }
}

