import 'package:get_storage/get_storage.dart';

// ═══════════════════════════════════════════════════════════
// TOKEN STORAGE SERVICE - ENHANCED
// Stores and retrieves authentication tokens and user info
// ═══════════════════════════════════════════════════════════

class TokenStorageService {
  final _storage = GetStorage();
  
  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _userEmailKey = 'user_email';

  // ═══════════════════════════════════════════════════════════
  // SAVE TOKENS
  // ═══════════════════════════════════════════════════════════
  
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await _storage.write(_refreshTokenKey, refreshToken);
    }
    print('✅ Tokens saved successfully');
  }

  // ═══════════════════════════════════════════════════════════
  // GET ACCESS TOKEN
  // ═══════════════════════════════════════════════════════════
  
  Future<String?> getAccessToken() async {
    return _storage.read(_accessTokenKey);
  }

  // ═══════════════════════════════════════════════════════════
  // GET REFRESH TOKEN
  // ═══════════════════════════════════════════════════════════
  
  Future<String?> getRefreshToken() async {
    return _storage.read(_refreshTokenKey);
  }

  // ═══════════════════════════════════════════════════════════
  // SAVE USER INFO
  // Save user ID and other info after login/signup
  // ═══════════════════════════════════════════════════════════
  
  Future<void> saveUserInfo({
    required int userId,
    String? role,
    String? email,
  }) async {
    await _storage.write(_userIdKey, userId);
    if (role != null) {
      await _storage.write(_userRoleKey, role);
    }
    if (email != null) {
      await _storage.write(_userEmailKey, email);
    }
    print('✅ User info saved: ID=$userId, Role=$role');
  }

  // ═══════════════════════════════════════════════════════════
  // GET USER ID
  // Returns the currently logged-in user's ID
  // ═══════════════════════════════════════════════════════════
  
  Future<int?> getUserId() async {
    final id = _storage.read(_userIdKey);
    if (id != null) {
      // Handle both int and String types from storage
      if (id is int) {
        return id;
      } else if (id is String) {
        return int.tryParse(id);
      }
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════
  // GET USER ROLE
  // ═══════════════════════════════════════════════════════════
  
  Future<String?> getUserRole() async {
    return _storage.read(_userRoleKey);
  }

  // ═══════════════════════════════════════════════════════════
  // GET USER EMAIL
  // ═══════════════════════════════════════════════════════════
  
  Future<String?> getUserEmail() async {
    return _storage.read(_userEmailKey);
  }

  // ═══════════════════════════════════════════════════════════
  // CHECK IF LOGGED IN
  // ═══════════════════════════════════════════════════════════
  
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ═══════════════════════════════════════════════════════════
  // CLEAR ALL DATA (Logout)
  // ═══════════════════════════════════════════════════════════
  
  Future<void> clearAll() async {
    await _storage.remove(_accessTokenKey);
    await _storage.remove(_refreshTokenKey);
    await _storage.remove(_userIdKey);
    await _storage.remove(_userRoleKey);
    await _storage.remove(_userEmailKey);
    print('✅ All tokens and user info cleared');
  }

  // ═══════════════════════════════════════════════════════════
  // UPDATE ACCESS TOKEN (for token refresh)
  // ═══════════════════════════════════════════════════════════
  
  Future<void> updateAccessToken(String newAccessToken) async {
    await _storage.write(_accessTokenKey, newAccessToken);
    print('✅ Access token updated');
  }
}