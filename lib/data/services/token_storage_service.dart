import 'package:get_storage/get_storage.dart';

class TokenStorageService {
  final GetStorage _box = GetStorage();
  
  static const String _accessTokenKey = 'access_token';
  static const String _isApprovedKey = 'is_approved';
  static const String _userPhoneKey = 'user_phone';

  Future<void> saveAccessToken(String token) async {
    await _box.write(_accessTokenKey, token);
    print(' Token saved to storage: $token');
  }

  String? getAccessToken() {
    final token = _box.read(_accessTokenKey);
    print(' Token retrieved from storage: $token');
    return token;
  }


  Future<void> saveApprovalStatus(bool isApproved) async {
    await _box.write(_isApprovedKey, isApproved);
  }


  bool? getApprovalStatus() {
    return _box.read(_isApprovedKey);
  }


  Future<void> saveUserPhone(String phone) async {
    await _box.write(_userPhoneKey, phone);
  }


  String? getUserPhone() {
    return _box.read(_userPhoneKey);
  }


  Future<void> saveLoginData({
    required String token,
    required String phone,
    bool? isApproved,
  }) async {
    await _box.write(_accessTokenKey, token);
    await _box.write(_userPhoneKey, phone);
    if (isApproved != null) {
      await _box.write(_isApprovedKey, isApproved);
    }
    

    print(' Login data saved:');
    print(' Token: $token');
    print(' Phone: $phone');
    print(' Approved: $isApproved');
  }

  
  bool get isLoggedIn => getAccessToken() != null;

  Future<void> clearAll() async {
    await _box.remove(_accessTokenKey);
    await _box.remove(_isApprovedKey);
    await _box.remove(_userPhoneKey);
    print(' All tokens cleared');
  }


  Future<void> eraseAll() async {
    await _box.erase();
  }


  void debugPrintAll() {
    print('=== GetStorage Debug ===');
    print('Token: ${_box.read(_accessTokenKey)}');
    print('Phone: ${_box.read(_userPhoneKey)}');
    print('Approved: ${_box.read(_isApprovedKey)}');
    print('Is Logged In: $isLoggedIn');
    print('All keys: ${_box.getKeys()}');
    
  }
}