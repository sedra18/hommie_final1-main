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
<<<<<<< HEAD

    // ⬇⬇⬇ أضف هذا السطر فقط ⬇⬇⬇
    httpClient.timeout = Duration(seconds: 30);

    // طباعة للتحقق
    print('🔗 [AuthService] السيرفر: ${httpClient.baseUrl}');
  }

  Future<Response<UserResponseModel>> loginuser(UserLoginModel user) async {
    try {
      // 1. طباعة للمعلومات
      print('🎯 [AuthService] أرسل طلب تسجيل دخول');
      print('📞 [AuthService] الرقم: ${user.phone}');
      print('🔗 [AuthService] العنوان: ${httpClient.baseUrl}/api/auth/login');

      // 2. إرسال الطلب
      final response = await post('/api/auth/login', user.toJson());

      // 3. طباعة النتيجة
      print('📥 [AuthService] ورد الرد');
      print('📊 [AuthService] الرمز: ${response.statusCode}');
      print('📄 [AuthService] المحتوى: ${response.body}');

      // 4. إذا كان الرد 200
      if (response.statusCode == 200 && response.body != null) {
        print('✅ [AuthService] نجح الاتصال');

        // 5. تحويل المحتوى لـ UserResponseModel
        final userResponse = UserResponseModel.fromJson(response.body!);

        // 6. إرجاع النتيجة
        return Response(
          statusCode: 200,
          body: userResponse,
          bodyString: response.bodyString,
          headers: response.headers,
        );
      }

      // 7. إذا فشل
      return Response(
        statusCode: response.statusCode ?? 500,
        statusText: response.statusText,
        body: null,
      );
    } catch (e) {
      print('❌ [AuthService] خطأ: $e');
      return Response(statusCode: 500, statusText: e.toString(), body: null);
    }
=======
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
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
  }

  Future<Response> sendResetOtp(String phone) {
    return post('/api/auth/sendResetOtp', {'phone': phone});
  }

  Future<Response> verifyResetOtp(String phone, String code) {
<<<<<<< HEAD
    return post('/api/auth/verifyResetOtp', {'phone': phone, 'code': code});
=======
    return post('/api/auth/verifyResetOtp', {
      'phone': phone,
      'code': code,
    });
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
  }

  Future<Response> resetPassword(String phone, String newPassword) {
    return post('/api/auth/resetPassword', {
      'phone': phone,
      'password': newPassword,
    });
  }
}
