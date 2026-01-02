// ═══════════════════════════════════════════════════════════
// BOOKING REQUEST MODEL - FIXED
// ✅ Matches API specification
// ✅ Uses start_date and end_date (not check_in/check_out)
// ✅ Gets user info from UserModel
// ═══════════════════════════════════════════════════════════

import 'package:hommie/data/models/user/user_model.dart';

class BookingRequestModel {
  final int? id;
  final int apartmentId;
  final int? userId;
  final String? userName;
  final String? userAvatar;
  final String? userPhone;
  final String startDate;  // ✅ CHANGED from checkInDate
  final String endDate;    // ✅ CHANGED from checkOutDate
  final String paymentMethod;
  final double? totalPrice;
  final String? status;
  final DateTime? createdAt;

  BookingRequestModel({
    this.id,
    required this.apartmentId,
    this.userId,
    this.userName,
    this.userAvatar,
    this.userPhone,
    required this.startDate,
    required this.endDate,
    required this.paymentMethod,
    this.totalPrice,
    this.status,
    this.createdAt,
  });

  // ═══════════════════════════════════════════════════════════
  // FROM JSON - Parse from API response
  // ═══════════════════════════════════════════════════════════
  
  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestModel(
      id: json['id'],
      apartmentId: json['apartment_id'],
      userId: json['user_id'],
      userName: json['user']?['name'] ?? 'Unknown',
      userAvatar: json['user']?['avatar'],
      userPhone: json['user']?['phone'] ?? '',
      startDate: json['start_date'] ?? '',  // ✅ FIXED
      endDate: json['end_date'] ?? '',      // ✅ FIXED
      paymentMethod: json['payment_method'] ?? 'cash',
      totalPrice: json['total_price'] != null 
          ? (json['total_price'] as num).toDouble() 
          : null,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TO JSON - For API requests (matches API specification)
  // ═══════════════════════════════════════════════════════════
  
  Map<String, dynamic> toJson() {
    return {
      'apartment_id': apartmentId,
      'start_date': startDate,    // ✅ FIXED
      'end_date': endDate,        // ✅ FIXED
      'payment_method': paymentMethod,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // TO JSON FULL - Include all fields (for display/updates)
  // ═══════════════════════════════════════════════════════════
  
  Map<String, dynamic> toJsonFull() {
    return {
      if (id != null) 'id': id,
      'apartment_id': apartmentId,
      if (userId != null) 'user_id': userId,
      'start_date': startDate,
      'end_date': endDate,
      'payment_method': paymentMethod,
      if (totalPrice != null) 'total_price': totalPrice,
      if (status != null) 'status': status,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // CREATE FROM USER - Helper to create booking with user info
  // ═══════════════════════════════════════════════════════════
  
  factory BookingRequestModel.fromUser({
    required UserModel user,
    required int apartmentId,
    required String startDate,
    required String endDate,
    required String paymentMethod,
    double? totalPrice,
  }) {
    return BookingRequestModel(
      apartmentId: apartmentId,
      userId: user.id,
      userName: user.name,
      userAvatar: user.avatar,
      userPhone: user.phone,
      startDate: startDate,
      endDate: endDate,
      paymentMethod: paymentMethod,
      totalPrice: totalPrice,
      status: 'pending',
    );
  }

  // ═══════════════════════════════════════════════════════════
  // COPY WITH - Create a copy with updated fields
  // ═══════════════════════════════════════════════════════════
  
  BookingRequestModel copyWith({
    int? id,
    int? apartmentId,
    int? userId,
    String? userName,
    String? userAvatar,
    String? userPhone,
    String? startDate,
    String? endDate,
    String? paymentMethod,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
  }) {
    return BookingRequestModel(
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      userPhone: userPhone ?? this.userPhone,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER GETTERS
  // ═══════════════════════════════════════════════════════════
  
  /// Get formatted date range
  String get dateRange => '$startDate - $endDate';
  
  /// Check if booking is pending
  bool get isPending => status == 'pending';
  
  /// Check if booking is approved
  bool get isApproved => status == 'approved';
  
  /// Check if booking is rejected
  bool get isRejected => status == 'rejected';
  
  /// Calculate number of days
  int get numberOfDays {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      return end.difference(start).inDays;
    } catch (e) {
      return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // TO STRING - For debugging
  // ═══════════════════════════════════════════════════════════
  
  @override
  String toString() {
    return 'BookingRequestModel(id: $id, apartmentId: $apartmentId, dates: $dateRange, status: $status)';
  }
}