import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:hommie/data/models/signup/signup_step2_model.dart';

class SignupStep2Service extends GetxService {
  final String baseUrl = 'http://192.168.1.8:8000/api';

  Future<Map<String, dynamic>> registerStep2({
    required int pendingUserId,
    required SignupStep2Model signupStep2Data,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register/page2');

    final body = {
      "pending_user_id": pendingUserId,
      "email": signupStep2Data.email,
      "password": signupStep2Data.password,
      "role": signupStep2Data.role.name,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('Request sent to: $url');
      print('Request body: $body');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      if (response.statusCode == 422) {
        return {
          'error': 'Validation error',
          'details': jsonDecode(response.body),
        };
      }

      return {
        'error': 'Failed: ${response.statusCode}',
        'details': response.body,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
