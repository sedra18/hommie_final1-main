import 'dart:convert';
import 'package:get/get.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:hommie/data/models/signup/signup_step2_model.dart';



class SignupStep2Service extends GetxService {
  final String baseUrl = '${BaseUrl.pubBaseUrl}/api';

 
  
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
 
      print('API CALL: registerPage2');
      print('Request sent to: $url');
      print('Request body: $body');
      
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('──────────────────────────────────────────────────────────');
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
      print(' Exception in registerStep2: $e');
      return {'error': e.toString()};
    }
  }

  
  
  Future<Map<String, dynamic>> registerFinalize({
    required int pendingUserId,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register/finalize');

    final body = {
      "pending_user_id": pendingUserId,
    };

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print(' API CALL: registerFinalize');
 
      print('Request sent to: $url');
      print('Request body: $body');
      
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('──────────────────────────────────────────────────────────');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');


      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      if (response.statusCode == 422) {
        return {
          'error': 'Validation error',
          'details': jsonDecode(response.body),
        };
      }

      return {
        'error': 'Failed to finalize registration: ${response.statusCode}',
        'details': response.body,
      };
    } catch (e) {
      print('Exception in registerFinalize: $e');
      return {'error': e.toString()};
    }
  }
}