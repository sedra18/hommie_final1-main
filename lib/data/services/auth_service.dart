import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/data/models/user/user_login_model.dart';
import 'package:hommie/data/models/user/user_response_model.dart' hide UserLoginModel;
import 'package:hommie/helpers/base_url.dart';

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
  // ═══════════════════════════════════════════════════════════

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
        
        print('✅ User state loaded from storage');
        print('   Role: $savedRole');
        print('   User ID: $savedUserId');
        print('   Is Logged In: $savedIsLoggedIn');
      } else {
        print('ℹ️ No saved user state found');
      }
    } catch (e) {
      print('⚠️ Error loading user state: $e');
      _clearUserState();
    }
  }

  /// Save user state to storage
  void saveUserState({
    required String token,
    required String role,
    required int userId,
    Map<String, dynamic>? userData,
  }) {
    try {
      _storage.write(_tokenKey, token);
      _storage.write(_roleKey, role);
      _storage.write(_userIdKey, userId);
      _storage.write(_isLoggedInKey, true);
      
      if (userData != null) {
        _storage.write(_userKey, userData);
        this.userData.value = userData;
      }
      
      isLoggedIn.value = true;
      userRole.value = role;
      this.userId.value = userId;
      
      print('✅ User state saved to storage');
    } catch (e) {
      print('❌ Error saving user state: $e');
    }
  }

  /// Clear user state from storage
  void _clearUserState() {
    try {
      _storage.remove(_tokenKey);
      _storage.remove(_userKey);
      _storage.remove(_roleKey);
      _storage.remove(_userIdKey);
      _storage.remove(_isLoggedInKey);
      
      isLoggedIn.value = false;
      userRole.value = '';
      userId.value = null;
      userData.value = null;
      
      print('✅ User state cleared');
    } catch (e) {
      print('❌ Error clearing user state: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    _clearUserState();
    print('✅ User logged out');
  }

  /// Get current token
  String? getToken() {
    return _storage.read(_tokenKey);
  }

  /// Get user role
  String? getUserRole() {
    return _storage.read(_roleKey);
  }

  /// Get user ID
  int? getUserId() {
    return _storage.read(_userIdKey);
  }

  /// Check if user is logged in
  bool checkIsLoggedIn() {
    return _storage.read(_isLoggedInKey) ?? false;
  }
}