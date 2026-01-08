import 'dart:convert';
import 'package:get/get.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;

// ═══════════════════════════════════════════════════════════
// OTP SERVICE - FIXED HEADERS
// ✅ Added Content-Type to prevent 302 Redirects
// ✅ Improved Error Extraction
// ═══════════════════════════════════════════════════════════

class OtpService extends GetxService {
  final String baseUrl = '${BaseUrl.pubBaseUrl}/api';

  // Helper for common headers
  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json', // 👈 CRITICAL: Tells Laravel we are sending JSON
      };

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
  // PASSWORD RESET
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> sendResetOtp(String phone) async {
    return _postOtp(
      phone, 
      'sendResetOtp', 
      description: 'Password Reset OTP',
    );
  }

  Future<Map<String, dynamic>> resendResetOtp(String phone) async {
    return _postOtp(
      phone, 
      'sendResetOtp', 
      description: 'Resend Password Reset OTP',
    );
  }

  // ═══════════════════════════════════════════════════════════
  // VERIFY OTP
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    return _postVerifyOtp(
      phone, 
      code, 
      'verifyRegisterOtp',
      description: 'Verify Registration OTP',
    );
  }

  Future<Map<String, dynamic>> verifyResetOtp(String phone, String code) async {
    return _postVerifyOtp(
      phone, 
      code, 
      'verifyResetOtp', 
      description: 'Verify Password Reset OTP',
    );
  }

  // ═══════════════════════════════════════════════════════════
  // RESET PASSWORD
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/auth/resetPassword');

    try {
      print('\n═══════════════════════════════════════════════════════════');
      print('🔐 [RESET PASSWORD] Sending request');
      print('   URL: $url');
      
      final response = await http.post(
        url,
        headers: _headers, // ✅ Uses Content-Type: application/json
        body: jsonEncode({
          'phone': phone,
          'password': newPassword,
        }),
      );

      return _handleResponse(response);
      
    } catch (e) {
      print('❌ Exception in resetPassword: $e');
      return {'error': 'Connection error. Please check your internet.'};
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PRIVATE NETWORK HELPERS
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> _postOtp(
    String phone, 
    String endpoint,
    {String? description}
  ) async {
    final url = Uri.parse('$baseUrl/auth/$endpoint');

    try {
      print('\n═══════════════════════════════════════════════════════════');
      print('📤 [${description ?? 'OTP'}] Sending request');
      print('   URL: $url');
      print('   Phone: $phone');
      
      final response = await http.post(
        url,
        headers: _headers, // ✅ Uses Content-Type: application/json
        body: jsonEncode({'phone': phone}),
      );

      return _handleResponse(response);
      
    } catch (e) {
      print('❌ Exception in ${description ?? 'OTP'}: $e');
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
      print('\n═══════════════════════════════════════════════════════════');
      print('🔍 [${description ?? 'VERIFY OTP'}] Sending request');
      print('   URL: $url');
      
      final response = await http.post(
        url,
        headers: _headers, // ✅ Uses Content-Type: application/json
        body: jsonEncode({
          'phone': phone,
          'code': code,
        }),
      );

      return _handleResponse(response);
      
    } catch (e) {
      print('❌ Exception in ${description ?? 'VERIFY OTP'}: $e');
      return {'error': 'Connection error. Please check your internet.'};
    }
  }

  // Centralized response handling to prevent parsing HTML as JSON
  Map<String, dynamic> _handleResponse(http.Response response) {
    print('📥 Response Status: ${response.statusCode}');
    
    // Check if the response is actually HTML (which causes the crash)
    if (response.body.contains('<!DOCTYPE html>') || response.statusCode == 302) {
      print('⚠️ SERVER ERROR: Received HTML/Redirect instead of JSON.');
      return {'error': 'Server configuration error (302 Redirect).'};
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.containsKey('error') ? {'error': data['error']} : data;
    } else {
      return _extractError(response);
    }
  }

  Map<String, dynamic> _extractError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      
      if (data.containsKey('errors')) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return {'error': firstError.first.toString()};
        }
      }
      
      return {'error': data['message'] ?? data['error'] ?? 'Request failed'};
    } catch (e) {
      return {'error': 'Request failed (Status: ${response.statusCode})'};
    }
  }
}