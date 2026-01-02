import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/signup/signup_step4_model.dart';
import 'dart:convert';

// ═══════════════════════════════════════════════════════════
// SIGNUP STEP 4 SERVICE - FIXED
// ✅ Returns response data at root level (not nested in "data")
// ✅ Proper error handling
// ═══════════════════════════════════════════════════════════

class SignupStep4Service {

  // ═══════════════════════════════════════════════════════════
  // UPLOAD IMAGES
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> uploadImages(SignupStep4Model model) async {
    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📤 [SERVICE] Uploading Images');
      print('   Pending User ID: ${model.pendingUserId}');
      print('   Avatar Path: ${model.avatarPath}');
      print('   ID Image Path: ${model.idImagePath}');
      print('──────────────────────────────────────────────────────────');
      
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

      print('📡 Sending request...');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: $responseBody');
      print('═══════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        return {"success": true, ...jsonDecode(responseBody)};  // ✅ Spread at root
      } else {
        return {"success": false, "error": responseBody};
      }
    } catch (e) {
      print('❌ Exception in uploadImages: $e');
      return {"success": false, "error": e.toString()};
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FINALIZE ACCOUNT - ✅ FIXED
  // Returns data at ROOT level, not nested in "data"
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> finalizeAccount(int pendingUserId) async {
    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔐 [SERVICE] Finalizing Account');
      print('   Pending User ID: $pendingUserId');
      print('   URL: ${BaseUrl.pubBaseUrl}/api/auth/register/finalize');
      print('──────────────────────────────────────────────────────────');
      
      final response = await http.post(
        Uri.parse('${BaseUrl.pubBaseUrl}/api/auth/register/finalize'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"pending_user_id": pendingUserId}),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      print('──────────────────────────────────────────────────────────');

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        
        // ✅ CRITICAL FIX: Return data at ROOT level
        // Don't wrap it in "data" key!
        return {
          "success": true,
          ...decodedBody,  // ✅ Spread operator - adds all keys to root
        };
        
        // This creates:
        // {
        //   "success": true,
        //   "message": "...",
        //   "user": {...}    ← At root level!
        // }
        
      } else {
        print('❌ Failed with status ${response.statusCode}');
        print('═══════════════════════════════════════════════════════════');
        return {"success": false, "error": response.body};
      }
    } catch (e) {
      print('❌ Exception in finalizeAccount: $e');
      print('═══════════════════════════════════════════════════════════');
      return {"success": false, "error": e.toString()};
    }
  }
}