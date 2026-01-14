import 'package:hommie/data/models/user/user_model.dart';

// ═══════════════════════════════════════════════════════════
// BOOKING REQUEST MODEL - ENHANCED WITH UPDATE REQUEST SUPPORT
// ✅ All original fields preserved
// ✅ Added isUpdateRequest, originalStartDate, originalEndDate
// ✅ Supports both new bookings and update requests
// ═══════════════════════════════════════════════════════════

class BookingRequestModel {
  final int? id;
  final int apartmentId;
  final String? apartmentTitle;  
  final int? ownerId;            
  final String? ownerName;       
  final String? ownerEmail;     
  final String? ownerPhone;     
  final int? userId;
  String? userName;
  final String? userEmail;       
  String? userAvatar;
  final String? userPhone;
  final String startDate;
  final String endDate;
  final String paymentMethod;
  final double? totalPrice;
  final String? status;
  final String? createdAt;       
  final String? updatedAt;
  
  // ✅ NEW: Update request fields
  final bool? isUpdateRequest;        // Indicates if this is an update request
  final String? originalStartDate;     // Original start date before update
  final String? originalEndDate;       // Original end date before update
  final String? updateRequestStatus;   // Status of update request specifically

  BookingRequestModel({
    this.id,
    required this.apartmentId,
    this.apartmentTitle,
    this.ownerId,
    this.ownerName,
    this.ownerEmail,
    this.ownerPhone,
    this.userId,
    this.userName,
    this.userEmail,
    this.userAvatar,
    this.userPhone,
    required this.startDate,
    required this.endDate,
    required this.paymentMethod,
    this.totalPrice,
    this.status,
    this.createdAt,
    this.updatedAt,
    // ✅ NEW: Update request parameters
    this.isUpdateRequest,
    this.originalStartDate,
    this.originalEndDate,
    this.updateRequestStatus,
  });

  // ═══════════════════════════════════════════════════════════
  // FROM JSON - Parse from API response
  // ✅ Enhanced to include update request fields
  // ═══════════════════════════════════════════════════════════
  
  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestModel(
      id: json['id'],
      apartmentId: json['apartment_id'],
      apartmentTitle: json['apartment']?['title'] ?? json['apartment_title'],  
      ownerId: json['owner_id'] ?? json['apartment']?['user_id'],  
      ownerName: json['owner']?['name'] ?? json['owner_name'] ?? json['apartment']?['owner_name'],
      ownerEmail: json['owner']?['email'] ?? json['owner_email'], 
      ownerPhone: json['owner']?['phone'] ?? json['owner_phone'],  
      userId: json['user_id'],
      userName: json['user']?['name'] ?? json['user_name'] ?? 'Unknown',
      userEmail: json['user']?['email'] ?? json['user_email'], 
      userAvatar: json['user']?['avatar'] ?? json['user_avatar'],
      userPhone: json['user']?['phone'] ?? json['user_phone'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      paymentMethod: json['payment_method'] ?? 'cash',
      totalPrice: json['total_price'] != null 
          ? (json['total_price'] as num).toDouble() 
          : null,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'],  
      updatedAt: json['updated_at'],
      // ✅ NEW: Parse update request fields
      isUpdateRequest: json['is_update_request'] ?? false,
      originalStartDate: json['original_start_date'],
      originalEndDate: json['original_end_date'],
      updateRequestStatus: json['update_request_status'],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TO JSON - For API requests (matches API specification)
  // ═══════════════════════════════════════════════════════════

  Map<String, dynamic> toJson() {
    return {
      'apartment_id': apartmentId,
      'start_date': startDate,
      'end_date': endDate,
      'payment_method': paymentMethod,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // TO JSON FULL - Include all fields (for display/updates)
  // ✅ Enhanced with update request fields
  // ═══════════════════════════════════════════════════════════
  
  Map<String, dynamic> toJsonFull() {
    return {
      if (id != null) 'id': id,
      'apartment_id': apartmentId,
      if (apartmentTitle != null) 'apartment_title': apartmentTitle,
      if (userId != null) 'user_id': userId,
      'start_date': startDate,
      'end_date': endDate,
      'payment_method': paymentMethod,
      if (totalPrice != null) 'total_price': totalPrice,
      if (status != null) 'status': status,
      // ✅ NEW: Include update request fields
      if (isUpdateRequest != null) 'is_update_request': isUpdateRequest,
      if (originalStartDate != null) 'original_start_date': originalStartDate,
      if (originalEndDate != null) 'original_end_date': originalEndDate,
      if (updateRequestStatus != null) 'update_request_status': updateRequestStatus,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // CREATE FROM USER - Helper to create booking with user info
  // ═══════════════════════════════════════════════════════════
  
  factory BookingRequestModel.fromUser({
    required UserModel user,
    required int apartmentId,
    String? apartmentTitle,
    required String startDate,
    required String endDate,
    required String paymentMethod,
    double? totalPrice,
  }) {
    return BookingRequestModel(
      apartmentId: apartmentId,
      apartmentTitle: apartmentTitle,
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      userAvatar: user.avatar,
      userPhone: user.phone,
      startDate: startDate,
      endDate: endDate,
      paymentMethod: paymentMethod,
      totalPrice: totalPrice,
      status: 'pending',
      isUpdateRequest: false, // ✅ NEW: Default to false
    );
  }

  // ═══════════════════════════════════════════════════════════
  // COPY WITH - Create a copy with updated fields
  // ✅ Enhanced with update request fields
  // ═══════════════════════════════════════════════════════════
  
  BookingRequestModel copyWith({
    int? id,
    int? apartmentId,
    String? apartmentTitle,
    int? ownerId,
    String? ownerName,
    String? ownerEmail,
    String? ownerPhone,
    int? userId,
    String? userName,
    String? userEmail,
    String? userAvatar,
    String? userPhone,
    String? startDate,
    String? endDate,
    String? paymentMethod,
    double? totalPrice,
    String? status,
    String? createdAt,
    String? updatedAt,
    // ✅ NEW: Update request parameters
    bool? isUpdateRequest,
    String? originalStartDate,
    String? originalEndDate,
    String? updateRequestStatus,
  }) {
    return BookingRequestModel(
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      apartmentTitle: apartmentTitle ?? this.apartmentTitle,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userAvatar: userAvatar ?? this.userAvatar,
      userPhone: userPhone ?? this.userPhone,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // ✅ NEW: Copy update request fields
      isUpdateRequest: isUpdateRequest ?? this.isUpdateRequest,
      originalStartDate: originalStartDate ?? this.originalStartDate,
      originalEndDate: originalEndDate ?? this.originalEndDate,
      updateRequestStatus: updateRequestStatus ?? this.updateRequestStatus,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER GETTERS
  // ═══════════════════════════════════════════════════════════
  
  /// Get formatted date range
  String get dateRange => '$startDate - $endDate';
  
  /// Check if booking is pending
  bool get isPending => status?.toLowerCase() == 'pending' || 
                        status?.toLowerCase() == 'pending_owner_approval';
  
  /// Check if booking is approved
  bool get isApproved => status?.toLowerCase() == 'approved';
  
  /// Check if booking is rejected
  bool get isRejected => status?.toLowerCase() == 'rejected';
  
  /// Check if booking is completed
  bool get isCompleted => status?.toLowerCase() == 'completed';
  
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
  // ✅ Enhanced with update request info
  // ═══════════════════════════════════════════════════════════
  
  @override
  String toString() {
    final updateFlag = isUpdateRequest == true ? ' [UPDATE]' : '';
    return 'BookingRequestModel(id: $id, apartmentId: $apartmentId, dates: $dateRange, status: $status$updateFlag)';
  }
}