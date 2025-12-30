import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/helpers/base_url.dart';

class LogoutService extends GetConnect {
  
  final String _baseUrl = BaseUrl.pubBaseUrl; 
  final box = GetStorage();
  
  @override
  void onInit() {
    httpClient.baseUrl = _baseUrl; 
    httpClient.defaultContentType = 'application/json';
    httpClient.timeout = const Duration(seconds: 8);
    httpClient.addRequestModifier<dynamic>((request) {
      final token = box.read('access_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token'; 
      }
      return request;
    });
  }
  Future<Response<dynamic>> performLogout() async {
    const String logoutUrl = '/api/auth/logout';

    final response = await post(
      logoutUrl,
      {}, 
    );
    if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 401) {
      box.remove('access_token'); 
    } 
    
    return response;
  }
}