/// Delivery Driver Model representing the authenticated driver entity
class DriverModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;
  final bool mustChangePassword;
  final DateTime? createdAt;

  DriverModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.isActive = true,
    this.mustChangePassword = false,
    this.createdAt,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'delivery',
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
      mustChangePassword: json['must_change_password'] == true ||
          json['must_change_password'] == 1 ||
          json['must_change_password'] == '1',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'is_active': isActive,
      'must_change_password': mustChangePassword,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  DriverModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
    bool? mustChangePassword,
    DateTime? createdAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

