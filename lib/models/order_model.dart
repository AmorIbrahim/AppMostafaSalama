// Models for Order, Customer, and Order Items

class CustomerModel {
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final String address;

  CustomerModel({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.address,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      address: json['delivery_address']?.toString() ?? json['address']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }
}

class OrderItemModel {
  final int id;
  final int? productId;
  final String name;
  final double price;
  final int quantity;
  final double subtotal;
  final String? bundle;

  OrderItemModel({
    required this.id,
    this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.bundle,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final qty = _parseInt(json['quantity']) > 0 ? _parseInt(json['quantity']) : 1;
    final prc = _parseDouble(json['price']);
    final sub = json['subtotal'] != null ? _parseDouble(json['subtotal']) : (prc * qty);

    return OrderItemModel(
      id: _parseInt(json['id']),
      productId: json['product_id'] != null ? _parseInt(json['product_id']) : null,
      name: json['name']?.toString() ?? '',
      price: prc,
      quantity: qty,
      subtotal: sub,
      bundle: json['bundle']?.toString(),
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
      'bundle': bundle,
    };
  }
}

class OrderModel {
  final int id;
  final String orderNumber;
  final String status;
  final double total;
  final double deliveryFee;
  final double subtotal;
  final CustomerModel customer;
  final String? notes;
  final String? paymentMethod;
  final String? paymentStatus;
  final int itemsCount;
  final List<OrderItemModel> items;
  final DateTime? assignedAt;
  final DateTime? driverAcceptedAt;
  final DateTime? deliveredAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    this.deliveryFee = 0.0,
    this.subtotal = 0.0,
    required this.customer,
    this.notes,
    this.paymentMethod,
    this.paymentStatus,
    this.itemsCount = 0,
    this.items = const [],
    this.assignedAt,
    this.driverAcceptedAt,
    this.deliveredAt,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final customerJson = json['customer'] is Map<String, dynamic>
        ? json['customer'] as Map<String, dynamic>
        : <String, dynamic>{};

    List<OrderItemModel> itemsList = [];
    if (json['items'] is List) {
      itemsList = (json['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => OrderItemModel.fromJson(item))
          .toList();
    }

    final totalVal = _parseDouble(json['total']);
    final deliveryFeeVal = _parseDouble(json['delivery_fee']);
    final subtotalVal = json['subtotal'] != null
        ? _parseDouble(json['subtotal'])
        : (totalVal - deliveryFeeVal);

    return OrderModel(
      id: _parseInt(json['id']),
      orderNumber: json['order_number']?.toString() ?? 'ORD-${json['id']}',
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      total: totalVal,
      deliveryFee: deliveryFeeVal,
      subtotal: subtotalVal > 0 ? subtotalVal : totalVal,
      customer: CustomerModel.fromJson(customerJson),
      notes: json['notes']?.toString(),
      paymentMethod: json['payment_method']?.toString() ?? 'Cash on Delivery (دفع عند الاستلام)',
      paymentStatus: json['payment_status']?.toString() ?? 'Pending (قيد الدفع)',
      itemsCount: json['items_count'] != null
          ? _parseInt(json['items_count'])
          : (itemsList.isNotEmpty ? itemsList.length : 1),
      items: itemsList,
      assignedAt: json['assigned_at'] != null ? DateTime.tryParse(json['assigned_at'].toString()) : null,
      driverAcceptedAt: json['driver_accepted_at'] != null
          ? DateTime.tryParse(json['driver_accepted_at'].toString())
          : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  OrderModel copyWith({
    int? id,
    String? orderNumber,
    String? status,
    double? total,
    double? deliveryFee,
    double? subtotal,
    CustomerModel? customer,
    String? notes,
    String? paymentMethod,
    String? paymentStatus,
    int? itemsCount,
    List<OrderItemModel>? items,
    DateTime? assignedAt,
    DateTime? driverAcceptedAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      total: total ?? this.total,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      subtotal: subtotal ?? this.subtotal,
      customer: customer ?? this.customer,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      itemsCount: itemsCount ?? this.itemsCount,
      items: items ?? this.items,
      assignedAt: assignedAt ?? this.assignedAt,
      driverAcceptedAt: driverAcceptedAt ?? this.driverAcceptedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
