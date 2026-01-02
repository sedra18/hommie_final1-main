import 'dart:convert';
import 'package:get/get.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;

// ═══════════════════════════════════════════════════════════
// OTP SERVICE - FIXED
// ✅ Extracts real error messages from backend
// ✅ Better logging
// ✅ Handles all response formats
// ═══════════════════════════════════════════════════════════

class OtpService extends GetxService {
  final String baseUrl = '${BaseUrl.pubBaseUrl}/api';

  // ═══════════════════════════════════════════════════════════
  // SEND OTP FOR REGISTRATION
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    return _postOtp(phone, 'sendOtpForRegister');
  }

  // ═══════════════════════════════════════════════════════════
  // RESEND OTP
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> resendResetOtp(String phone) async {
    return _postOtp(phone, 'sendOtpForRegister');
  }

  // ═══════════════════════════════════════════════════════════
  // POST OTP - FIXED ERROR EXTRACTION
  // ✅ Extracts actual error messages from backend
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> _postOtp(String phone, String endpoint) async {
    final url = Uri.parse('$baseUrl/auth/$endpoint');

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📤 [OTP SERVICE] Sending request');
      print('   URL: $url');
      print('   Phone: $phone');
      print('──────────────────────────────────────────────────────────');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      print('📥 Response received');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');
      print('═══════════════════════════════════════════════════════════');

      // ✅ SUCCESS - 200 OK
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Some backends return 200 with error field
        if (data.containsKey('error')) {
          return {'error': data['error']};
        }
        
        return data;
      }
      
      // ✅ EXTRACT ERROR FROM FAILED RESPONSE
      else {
        try {
          final data = jsonDecode(response.body);
          
          // Laravel validation errors (422)
          if (data.containsKey('errors')) {
            final errors = data['errors'] as Map<String, dynamic>;
            
            // Get phone field error
            if (errors.containsKey('phone')) {
              final phoneErrors = errors['phone'] as List;
              return {'error': phoneErrors.first.toString()};
            }
            
            // Get first error from any field
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return {'error': firstError.first.toString()};
            }
          }
          
          // Simple message field
          if (data.containsKey('message')) {
            return {'error': data['message']};
          }
          
          // Error field
          if (data.containsKey('error')) {
            return {'error': data['error']};
          }
        } catch (e) {
          // Failed to parse JSON
          print('⚠️ Failed to parse error response: $e');
        }
        
        // Generic error with status code
        return {'error': 'Failed to send OTP (Status: ${response.statusCode})'};
      }
      
    } catch (e) {
      print('❌ Exception in OTP service: $e');
      print('═══════════════════════════════════════════════════════════');
      
      return {'error': 'Connection error. Please check your internet.'};
    }
  }
}