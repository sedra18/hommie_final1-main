import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/signup/signup_step4_model.dart';
import 'dart:convert';

class SignupStep4Service {

  Future<Map<String, dynamic>> uploadImages(SignupStep4Model model) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.pubBaseUrl}/api/auth/register/uploadImages'),
    );

    request.fields['pending_user_id'] = model.pendingUserId.toString();

    request.files.add(await http.MultipartFile.fromPath(
      'avatar',
      model.avatarPath,
      contentType: MediaType('image', 'jpeg'),
    ));

    request.files.add(await http.MultipartFile.fromPath(
      'id_image',
      model.idImagePath,
      contentType: MediaType('image', 'jpeg'),
    ));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return {"success": true, "data": jsonDecode(responseBody)};
    } else {
      return {"success": false, "error": responseBody};
    }
  }

  Future<Map<String, dynamic>> finalizeAccount(int pendingUserId) async {
    final response = await http.post(
      Uri.parse('${BaseUrl.pubBaseUrl}/api/auth/register/finalize'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"pending_user_id": pendingUserId}),
    );
print(" Response Status: ${response.statusCode}");
print(" Response Body: ${response.body}");
    if (response.statusCode == 200) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      return {"success": false, "error": response.body};
    }
  }
}
