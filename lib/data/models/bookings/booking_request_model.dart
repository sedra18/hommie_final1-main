// ═══════════════════════════════════════════════════════════
// BOOKING REQUEST MODEL - ENHANCED WITH UPDATE REQUESTS
// ✅ Supports both NEW bookings and UPDATE requests
// ✅ Tracks original dates for update requests
// ✅ Has isUpdateRequest flag
// ═══════════════════════════════════════════════════════════

class BookingRequestModel {
  final int? id;
  final int? userId;
  final int? apartmentId;
  String? userName;
  String? userEmail;
  String? userAvatar;
  final String? apartmentTitle;
  final String? startDate;
  final String? endDate;
  final String? status;
  final String? paymentMethod;
  
  // ✅ NEW: Fields for update requests
  final bool? isUpdateRequest;        // Indicates if this is an update request
  final String? originalStartDate;     // Original start date before update
  final String? originalEndDate;       // Original end date before update
  final String? updateRequestStatus;   // Status of the update request

  BookingRequestModel({
    this.id,
    this.userId,
    this.apartmentId,
    this.userName,
    this.userEmail,
    this.userAvatar,
    this.apartmentTitle,
    this.startDate,
    this.endDate,
    this.status,
    this.paymentMethod,
    this.isUpdateRequest,
    this.originalStartDate,
    this.originalEndDate,
    this.updateRequestStatus,
  });

  // ═══════════════════════════════════════════════════════════
  // FROM JSON - Enhanced with update request fields
  // ═══════════════════════════════════════════════════════════
  
  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestModel(
      id: json['id'],
      userId: json['user_id'] ?? json['renter_id'],
      apartmentId: json['apartment_id'],
      userName: json['user_name'] ?? json['renter_name'],
      userEmail: json['user_email'] ?? json['renter_email'],
      userAvatar: json['user_avatar'] ?? json['renter_avatar'],
      apartmentTitle: json['apartment_title'] ?? json['apartment']?['title'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      paymentMethod: json['payment_method'],
      // ✅ NEW: Parse update request fields
      isUpdateRequest: json['is_update_request'] ?? false,
      originalStartDate: json['original_start_date'],
      originalEndDate: json['original_end_date'],
      updateRequestStatus: json['update_request_status'],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TO JSON
  // ═══════════════════════════════════════════════════════════
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'apartment_id': apartmentId,
      'user_name': userName,
      'user_email': userEmail,
      'user_avatar': userAvatar,
      'apartment_title': apartmentTitle,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'payment_method': paymentMethod,
      'is_update_request': isUpdateRequest,
      'original_start_date': originalStartDate,
      'original_end_date': originalEndDate,
      'update_request_status': updateRequestStatus,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // COPY WITH
  // ═══════════════════════════════════════════════════════════
  
  BookingRequestModel copyWith({
    int? id,
    int? userId,
    int? apartmentId,
    String? userName,
    String? userEmail,
    String? userAvatar,
    String? apartmentTitle,
    String? startDate,
    String? endDate,
    String? status,
    String? paymentMethod,
    bool? isUpdateRequest,
    String? originalStartDate,
    String? originalEndDate,
    String? updateRequestStatus,
  }) {
    return BookingRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      apartmentId: apartmentId ?? this.apartmentId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userAvatar: userAvatar ?? this.userAvatar,
      apartmentTitle: apartmentTitle ?? this.apartmentTitle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isUpdateRequest: isUpdateRequest ?? this.isUpdateRequest,
      originalStartDate: originalStartDate ?? this.originalStartDate,
      originalEndDate: originalEndDate ?? this.originalEndDate,
      updateRequestStatus: updateRequestStatus ?? this.updateRequestStatus,
    );
  }

  @override
  String toString() {
    return 'BookingRequestModel(id: $id, status: $status, isUpdate: $isUpdateRequest, apartment: $apartmentTitle)';
  }
}