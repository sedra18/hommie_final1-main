// ═══════════════════════════════════════════════════════════
// USER MODEL
// Represents user data from backend
// ═══════════════════════════════════════════════════════════

class UserModel {
  final int id;
  final String name;
  final String email;
  final String role; // 'owner' or 'renter'
  final String approvalStatus; // 'pending', 'approved', 'rejected'
  final String? phone;
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.approvalStatus,
    this.phone,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  // ═══════════════════════════════════════════════════════════
  // FROM JSON - Parse from API response
  // ═══════════════════════════════════════════════════════════
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'renter',
      approvalStatus: json['approval_status'] ?? 'pending',
      phone: json['phone'],
      avatar: json['avatar'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TO JSON - Convert to JSON for API requests
  // ═══════════════════════════════════════════════════════════
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'approval_status': approvalStatus,
      'phone': phone,
      'avatar': avatar,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // ═══════════════════════════════════════════════════════════
  // COPY WITH - Create a copy with updated fields
  // ═══════════════════════════════════════════════════════════
  
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? approvalStatus,
    String? phone,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER GETTERS
  // ═══════════════════════════════════════════════════════════
  
  bool get isApproved => approvalStatus == 'approved';
  bool get isPending => approvalStatus == 'pending';
  bool get isRejected => approvalStatus == 'rejected';
  
  bool get isOwner => role == 'owner';
  bool get isRenter => role == 'renter';

  // ═══════════════════════════════════════════════════════════
  // TO STRING - For debugging
  // ═══════════════════════════════════════════════════════════
  
  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, approvalStatus: $approvalStatus)';
  }
}