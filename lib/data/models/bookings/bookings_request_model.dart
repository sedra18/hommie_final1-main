class BookingRequestModel {
  final int id;
  final int apartmentId;
  final int userId;
  final String userName;
  final String? userAvatar;
  final String userPhone;
  final String checkInDate;
  final String checkOutDate;
  final String paymentMethod; // 'cash', 'credit_card', 'paypal', etc.
  final double totalPrice;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  BookingRequestModel({
    required this.id,
    required this.apartmentId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.userPhone,
    required this.checkInDate,
    required this.checkOutDate,
    required this.paymentMethod,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestModel(
      id: json['id'],
      apartmentId: json['apartment_id'],
      userId: json['user_id'],
      userName: json['user']['name'] ?? 'Unknown',
      userAvatar: json['user']['avatar'],
      userPhone: json['user']['phone'] ?? '',
      checkInDate: json['check_in_date'],
      checkOutDate: json['check_out_date'],
      paymentMethod: json['payment_method'] ?? 'cash',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apartment_id': apartmentId,
      'user_id': userId,
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      'payment_method': paymentMethod,
      'total_price': totalPrice,
      'status': status,
    };
  }

  // Helper to get formatted date range
  String get dateRange => '$checkInDate - $checkOutDate';
  
  // Helper to check if pending
  bool get isPending => status == 'pending';
}