import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SignupService extends GetxService {
  final String baseUrl = 'http://192.168.1.8:8000/api';

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/auth/verifyRegisterOtp');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'code': otp,
        }),
      );

      print('Verify Response: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } 
      else {
        try {
          final errorBody = jsonDecode(response.body);
          return errorBody; 
          
        } catch (e) {
          return {
            'error': 'Failed to verify OTP: ${response.statusCode}',
            'body': response.body,
          };
        }
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}