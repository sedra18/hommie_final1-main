import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TokenStorage extends GetxService {
  final GetStorage _box = GetStorage();

  Future<void> writeToken(String token) async {
    _box.write('auth_token', token);
  }

  Future<String?> readToken() async {
    return _box.read('auth_token');
  }

  Future<void> deleteToken() async {
    await _box.remove('auth_token');
  }
}