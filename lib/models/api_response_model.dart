/// Generic pagination metadata from Laravel backend
class PaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  PaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: _parseInt(json['current_page'], fallback: 1),
      lastPage: _parseInt(json['last_page'], fallback: 1),
      perPage: _parseInt(json['per_page'], fallback: 15),
      total: _parseInt(json['total'], fallback: 0),
      hasMore: json['has_more'] == true ||
          (_parseInt(json['current_page']) < _parseInt(json['last_page'])),
    );
  }

  static int _parseInt(dynamic val, {int fallback = 0}) {
    if (val == null) return fallback;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? fallback;
  }
}

/// Generic API response wrapper matching Laravel's response standard
class ApiResponse<T> {
  final bool success;
  final String message;
  final String? errorCode;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.errorCode,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data)? fromData,
  ) {
    return ApiResponse<T>(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      errorCode: json['error_code']?.toString(),
      data: json['data'] != null && fromData != null ? fromData(json['data']) : null,
    );
  }
}

