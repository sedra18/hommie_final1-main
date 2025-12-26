import 'package:get/get.dart';
import 'package:hommie/data/models/user/user_login_model.dart';
import 'package:hommie/helpers/base_url.dart';

class UserResponseModel {
  final String? token;
  final bool? isApproved;
  final String? role;

  UserResponseModel({this.token, this.isApproved, this.role});

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    return UserResponseModel(
      token: json['token'] as String?,
      isApproved: json['is_approved'] as bool?,
      role: json['user'] != null ? json['user']['role'] as String? : null,
    );
  }
}

class AuthService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = '${BaseUrl.pubBaseUrl}';
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
