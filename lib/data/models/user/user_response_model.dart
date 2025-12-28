import 'package:get/get.dart';

// ═══════════════════════════════════════════════════════════
// IMPROVED USER RESPONSE MODEL
// With all fields needed for complete user data storage
// ═══════════════════════════════════════════════════════════

class UserResponseModel {
  final int? id;
  final String? token;
  final String? email;
  final String? phoneNumber;
  final bool? isApproved;
  final String? role;

  UserResponseModel({
    this.id,
    this.token,
    this.email,
    this.phoneNumber,
    this.isApproved,
    this.role,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle both flat and nested user object
    final user = json['user'] as Map<String, dynamic>?;
    
    return UserResponseModel(
      // ID can be at root or in user object
      id: json['id'] as int? ?? 
          (user != null ? user['id'] as int? : null),
      
      // Token at root level
      token: json['token'] as String?,
      
      // Email can be at root or in user object
      email: json['email'] as String? ?? 
             (user != null ? user['email'] as String? : null),
      
      // Phone number can be at root or in user object
      phoneNumber: json['phone_number'] as String? ?? 
                   (user != null ? user['phone_number'] as String? : null),
      
      // is_approved can be at root or in user object
      isApproved: json['is_approved'] as bool? ?? 
                  (user != null ? user['is_approved'] as bool? : null),
      
      // Role from user object
      role: user != null ? user['role'] as String? : json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'email': email,
      'phone_number': phoneNumber,
      'is_approved': isApproved,
      'role': role,
    };
  }

  @override
  String toString() {
    return 'UserResponseModel(id: $id, email: $email, role: $role, isApproved: $isApproved, hasToken: ${token != null})';
  }
}

class AuthService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'http://192.168.1.3:8000';
    httpClient.defaultContentType = 'application/json';
  }

  Future<Response<UserResponseModel>> loginuser(UserLoginModel user) async {
    final response = await post(
      '/api/auth/login',
      user.toJson(),
    );

    if (response.statusCode == 200 &&
        response.body is Map<String, dynamic>) {
      return Response(
        statusCode: 200,
        body: UserResponseModel.fromJson(response.body),
      );
    }

    return Response(
      statusCode: response.statusCode,
      statusText: response.statusText,
    );
  }

  Future<Response> sendResetOtp(String phone) {
    return post('/api/auth/sendResetOtp', {'phone': phone});
  }

  Future<Response> verifyResetOtp(String phone, String code) {
    return post('/api/auth/verifyResetOtp', {
      'phone': phone,
      'code': code,
    });
  }

  Future<Response> resetPassword(String phone, String newPassword) {
    return post('/api/auth/resetPassword', {
      'phone': phone,
      'password': newPassword,
    });
  }
}

// Placeholder for UserLoginModel (if not defined)
class UserLoginModel {
  final String email;
  final String password;

  UserLoginModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}