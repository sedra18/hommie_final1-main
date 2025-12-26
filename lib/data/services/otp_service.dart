import 'dart:convert';
import 'package:get/get.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;

class OtpService extends GetxService {
  final String baseUrl = '${BaseUrl.pubBaseUrl}/api';

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    return _postOtp(phone, 'sendOtpForRegister');
  }

  Future<Map<String, dynamic>> resendResetOtp(String phone) async {
  return _postOtp(phone, 'sendOtpForRegister');
}

  Future<Map<String, dynamic>> _postOtp(String phone, String endpoint) async {
    final url = Uri.parse('$baseUrl/auth/$endpoint');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      print('Request sent to: $url');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Failed to send OTP: ${response.statusCode}'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
