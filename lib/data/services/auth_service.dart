import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/data/models/user/user_login_model.dart';
import 'package:hommie/data/models/user/user_response_model.dart' hide UserLoginModel;
import 'package:hommie/helpers/base_url.dart';

// ═══════════════════════════════════════════════════════════
// COMPLETE AUTH SERVICE
// ✅ Combines API calls AND state management
// ✅ Handles login, password reset, etc.
// ✅ Persists user state across app restarts
// ═══════════════════════════════════════════════════════════

class AuthService extends GetConnect {
  final GetStorage _storage = GetStorage();
  
  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _roleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _isLoggedInKey = 'is_logged_in';
  
  // Observable states
  final RxBool isLoggedIn = false.obs;
  final RxString userRole = ''.obs;
  final Rxn<int> userId = Rxn<int>();
  final Rxn<Map<String, dynamic>> userData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    
    // Configure HTTP client
    httpClient.baseUrl = BaseUrl.pubBaseUrl;
    httpClient.defaultContentType = 'application/json';
    
    // Load saved user state
    _loadUserState();
    
    print('🔐 AuthService initialized');
  }

  // ═══════════════════════════════════════════════════════════
  // API METHODS - LOGIN & PASSWORD RESET
  // ═══════════════════════════════════════════════════════════

  /// Login user with phone and password
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

  /// Send OTP for password reset
  Future<Response> sendResetOtp(String phone) {
    return post('/api/auth/sendResetOtp', {'phone': phone});
  }

  /// Verify OTP code
  Future<Response> verifyResetOtp(String phone, String code) {
    return post('/api/auth/verifyResetOtp', {
      'phone': phone,
      'code': code,
    });
  }

  /// Reset password with new password
  Future<Response> resetPassword(String phone, String newPassword) {
    return post('/api/auth/resetPassword', {
      'phone': phone,
      'password': newPassword,
    });
  }

  // ═══════════════════════════════════════════════════════════
  // STATE MANAGEMENT METHODS
  // ═════════════════════════════════════════════════════════════

  /// Load user state from storage
  void _loadUserState() {
    try {
      final savedIsLoggedIn = _storage.read(_isLoggedInKey) ?? false;
      final savedRole = _storage.read(_roleKey);
      final savedUserId = _storage.read(_userIdKey);
      final savedUserData = _storage.read(_userKey);
      
      if (savedIsLoggedIn) {
        isLoggedIn.value = true;
        userRole.value = savedRole ?? '';
        userId.value = savedUserId;
        
        if (savedUserData != null) {
          userData.value = Map<String, dynamic>.from(savedUserData);
        }
        
        print('✅ User state loaded: Role=$savedRole, ID=$savedUserId');
      } else {
        print('ℹ️ No saved user state found');
      }
    } catch (e) {
      print('❌ Error loading user state: $e');
    }
  }

  /// Save user state to storage
  Future<void> saveUserState({
    required String token,
    required Map<String, dynamic> user,
    required String role,
  }) async {
    try {
      await _storage.write(_tokenKey, token);
      await _storage.write(_userKey, user);
      await _storage.write(_roleKey, role);
      await _storage.write(_userIdKey, user['id']);
      await _storage.write(_isLoggedInKey, true);
      
      // Update observables
      isLoggedIn.value = true;
      userRole.value = role;
      userId.value = user['id'];
      userData.value = user;
      
      print('✅ User state saved successfully');
    } catch (e) {
      print('❌ Error saving user state: $e');
    }
  }

  /// Clear user state (logout)
  Future<void> clearUserState() async {
    try {
      await _storage.remove(_tokenKey);
      await _storage.remove(_userKey);
      await _storage.remove(_roleKey);
      await _storage.remove(_userIdKey);
      await _storage.write(_isLoggedInKey, false);
      
      // Clear observables
      isLoggedIn.value = false;
      userRole.value = '';
      userId.value = null;
      userData.value = null;
      
      print('✅ User state cleared');
    } catch (e) {
      print('❌ Error clearing user state: $e');
    }
  }

  /// Get stored token
  String? getToken() {
    return _storage.read(_tokenKey);
  }

  /// Get stored user ID
  int? getUserId() {
    return _storage.read(_userIdKey);
  }

  /// Get stored user role
  String? getUserRole() {
    return _storage.read(_roleKey);
  }

  /// Check if user is logged in
  bool checkIsLoggedIn() {
    return _storage.read(_isLoggedInKey) ?? false;
  }
}