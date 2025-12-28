import 'package:get_storage/get_storage.dart';

class TokenStorageService {
  final GetStorage _box = GetStorage();
  
  static const String _accessTokenKey = 'access_token';
  static const String _isApprovedKey = 'is_approved';
  static const String _userPhoneKey = 'user_phone';


  int _callCount = 0;
  DateTime? _lastPrint;

  Future<void> saveAccessToken(String token) async {
    await _box.write(_accessTokenKey, token);
    print(' Token saved to storage');
  }

  String? getAccessToken() {
    _callCount++;
    

    final now = DateTime.now();
    if (_lastPrint == null || now.difference(_lastPrint!) > Duration(seconds: 1)) {
      print('');
      print(' INFINITE LOOP DETECTED!');
      print('   getAccessToken called $_callCount times in 1 second');
      print('   Called from:');

      final stack = StackTrace.current.toString().split('\n');
      for (int i = 1; i < 5 && i < stack.length; i++) {
        print('   $i: ${stack[i].trim()}');
      }
      print('');
      
      _callCount = 0;
      _lastPrint = now;
    }
    
    final token = _box.read(_accessTokenKey);
    return token;
  }

  Future<void> saveApprovalStatus(bool isApproved) async {
    await _box.write(_isApprovedKey, isApproved);
    print(' Approval status saved: $isApproved');
  }

  bool? getApprovalStatus() {
    return _box.read(_isApprovedKey);
  }

  Future<void> saveUserPhone(String phone) async {
    await _box.write(_userPhoneKey, phone);
    print(' User phone saved');
  }

  String? getUserPhone() {
    return _box.read(_userPhoneKey);
  }

  Future<void> clearAll() async {
    await _box.erase();
    print(' All data cleared');
  }

  bool get isLoggedIn {
  
    final token = _box.read(_accessTokenKey);
    return token != null;
  }
}