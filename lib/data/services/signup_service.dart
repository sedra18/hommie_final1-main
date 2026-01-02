import 'dart:convert';
import 'package:get/get.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;

// ═══════════════════════════════════════════════════════════
// SIGNUP SERVICE - COMPLETELY FIXED
// ✅ Proper error handling
// ✅ Safe response parsing
// ✅ Better logging
// ✅ No crashes
// ═══════════════════════════════════════════════════════════

class SignupService extends GetxService {
  final String baseUrl = '${BaseUrl.pubBaseUrl}/api';

  // ═══════════════════════════════════════════════════════════
  // VERIFY OTP - FIXED
  // ✅ Safe response parsing
  // ✅ Detailed error extraction
  // ✅ Better logging
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/auth/verifyRegisterOtp');

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔐 [VERIFY OTP] Request');
      print('   URL: $url');
      print('   Phone: $phone');
      print('   OTP: $otp');
      print('──────────────────────────────────────────────────────────');
      
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

      print('📥 Response received');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');
      print('──────────────────────────────────────────────────────────');

      // ✅ SUCCESS - 200
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          
          print('✅ OTP Verified Successfully');
          print('   Response data: $data');
          print('═══════════════════════════════════════════════════════════');
          
          return data;
        } catch (e) {
          print('❌ Failed to parse success response: $e');
          print('═══════════════════════════════════════════════════════════');
          
          return {
            'error': 'Failed to parse response',
            'details': response.body,
          };
        }
      }
      
      // ✅ ERROR RESPONSE
      else {
        try {
          final errorBody = jsonDecode(response.body);
          
          print('❌ Verification Failed');
          print('   Error: $errorBody');
          print('═══════════════════════════════════════════════════════════');
          
          // Extract specific error message
          if (errorBody.containsKey('message')) {
            return {'error': errorBody['message']};
          }
          
          if (errorBody.containsKey('error')) {
            return {'error': errorBody['error']};
          }
          
          // Return full error body if no specific message
          return errorBody;
          
        } catch (e) {
          print('❌ Failed to parse error response: $e');
          print('═══════════════════════════════════════════════════════════');
          
          return {
            'error': 'Failed to verify OTP (Status: ${response.statusCode})',
            'body': response.body,
          };
        }
      }
    } catch (e, stackTrace) {
      print('❌ Exception in verifyOtp: $e');
      print('   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      print('═══════════════════════════════════════════════════════════');
      
      return {
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }
}