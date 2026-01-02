import 'dart:convert';
import 'package:get/get.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;

// ═══════════════════════════════════════════════════════════
// OTP SERVICE - TEMPORARY WORKAROUND
// ✅ Uses Registration OTP for password reset
// ⚠️  Backend doesn't have separate reset OTP endpoint
// ═══════════════════════════════════════════════════════════

class OtpService extends GetxService {
  final String baseUrl = '${BaseUrl.pubBaseUrl}/api';

  // ═══════════════════════════════════════════════════════════
  // REGISTRATION OTP
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    return _postOtp(phone, 'sendOtpForRegister', description: 'Registration OTP');
  }

  Future<Map<String, dynamic>> resendOtp(String phone) async {
    return _postOtp(phone, 'sendOtpForRegister', description: 'Resend Registration OTP');
  }

  // ═══════════════════════════════════════════════════════════
  // PASSWORD RESET - ✅ CORRECT ENDPOINTS
  // ═══════════════════════════════════════════════════════════
  
  /// Send OTP for password reset
  Future<Map<String, dynamic>> sendResetOtp(String phone) async {
    return _postOtp(
      phone, 
      'sendResetOtp',  // ✅ Correct endpoint!
      description: 'Password Reset OTP',
    );
  }

  /// Resend OTP for password reset
  Future<Map<String, dynamic>> resendResetOtp(String phone) async {
    return _postOtp(
      phone, 
      'sendResetOtp',  // ✅ Correct endpoint!
      description: 'Resend Password Reset OTP',
    );
  }

  // ═══════════════════════════════════════════════════════════
  // VERIFY OTP
  // ═══════════════════════════════════════════════════════════
  
  /// Verify registration OTP
  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    return _postVerifyOtp(
      phone, 
      code, 
      'verifyRegisterOtp',
      description: 'Verify Registration OTP',
    );
  }

  /// Verify password reset OTP
  Future<Map<String, dynamic>> verifyResetOtp(String phone, String code) async {
    return _postVerifyOtp(
      phone, 
      code, 
      'verifyResetOtp',  // ✅ Correct endpoint!
      description: 'Verify Password Reset OTP',
    );
  }

  // ═══════════════════════════════════════════════════════════
  // RESET PASSWORD - ✅ CORRECT ENDPOINT
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/auth/resetPassword');

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔐 [RESET PASSWORD] Sending request');
      print('   URL: $url');
      print('   Phone: $phone');
      print('──────────────────────────────────────────────────────────');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': newPassword,
        }),
      );

      print('📥 Response received');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');
      print('═══════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data.containsKey('error')) {
          return {'error': data['error']};
        }
        
        return data;
      } else {
        return _extractError(response);
      }
      
    } catch (e) {
      print('❌ Exception in resetPassword: $e');
      print('═══════════════════════════════════════════════════════════');
      
      return {'error': 'Connection error. Please check your internet.'};
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PRIVATE METHODS
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> _postOtp(
    String phone, 
    String endpoint,
    {String? description}
  ) async {
    final url = Uri.parse('$baseUrl/auth/$endpoint');

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📤 [${description ?? 'OTP'}] Sending request');
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data.containsKey('error')) {
          return {'error': data['error']};
        }
        
        return data;
      } else {
        return _extractError(response);
      }
      
    } catch (e) {
      print('❌ Exception in ${description ?? 'OTP'}: $e');
      print('═══════════════════════════════════════════════════════════');
      
      return {'error': 'Connection error. Please check your internet.'};
    }
  }

  Future<Map<String, dynamic>> _postVerifyOtp(
    String phone, 
    String code,
    String endpoint,
    {String? description}
  ) async {
    final url = Uri.parse('$baseUrl/auth/$endpoint');

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔍 [${description ?? 'VERIFY OTP'}] Sending request');
      print('   URL: $url');
      print('   Phone: $phone');
      print('   Code: ${code.replaceAll(RegExp(r'\d'), '*')}');
      print('──────────────────────────────────────────────────────────');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'code': code,
        }),
      );

      print('📥 Response received');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');
      print('═══════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data.containsKey('error')) {
          return {'error': data['error']};
        }
        
        return data;
      } else {
        return _extractError(response);
      }
      
    } catch (e) {
      print('❌ Exception in ${description ?? 'VERIFY OTP'}: $e');
      print('═══════════════════════════════════════════════════════════');
      
      return {'error': 'Connection error. Please check your internet.'};
    }
  }

  Map<String, dynamic> _extractError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      
      if (data.containsKey('errors')) {
        final errors = data['errors'] as Map<String, dynamic>;
        
        if (errors.containsKey('phone')) {
          final phoneErrors = errors['phone'] as List;
          return {'error': phoneErrors.first.toString()};
        }
        
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return {'error': firstError.first.toString()};
        }
      }
      
      if (data.containsKey('message')) {
        return {'error': data['message']};
      }
      
      if (data.containsKey('error')) {
        return {'error': data['error']};
      }
    } catch (e) {
      print('⚠️ Failed to parse error response: $e');
    }
    
    return {'error': 'Request failed (Status: ${response.statusCode})'};
  }
}