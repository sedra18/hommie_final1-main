import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hommie/helpers/base_url.dart';

class ProfileController extends GetxController {
  final box = GetStorage();

  // متغيرات observable
  var isLoading = false.obs;
  var userData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    print('🔄 ProfileController initialized');
    fetchProfile();
  }

  // دالة جلب بيانات المستخدم من API
  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      print('🔄 جلب بيانات البروفايل...');

      final token = box.read('access_token');
      if (token == null) {
        print('❌ لا يوجد token للمستخدم');
        return;
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.pubBaseUrl}/api/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📡 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        userData.value = data;
        print('✅ تم تحميل بيانات البروفايل: $data');
        if (data['data']?['status'] != null) {
          print('🔍 حالة المستخدم: ${data['data']?['status']}');
        }
      } else {
        print('❌ فشل جلب البروفايل: ${response.statusCode}');
        print('📄 Response: ${response.body}');
      }
    } catch (e) {
      print('🚨 خطأ في جلب البروفايل: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> updateName(String firstName, String lastName) async {
    try {
      final token = box.read('access_token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${BaseUrl.pubBaseUrl}/api/profile/name'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'first_name': firstName, 'last_name': lastName}),
      );

      print('📡 Update Name Response: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      if (response.statusCode == 200) {
        // تحديث البيانات المحلية
        await fetchProfile();
        return true;
      }
      return false;
    } catch (e) {
      print('🚨 Error updating name: $e');
      return false;
    }
  }

  // ============================================
  // 🔐 الدوال المتبقية للبروفايل
  // ============================================

  // 1. تحديث البريد
  // في ProfileController.dart
  Future<bool> updateEmail(String newEmail, String currentPassword) async {
    try {
      final token = box.read('access_token');
      if (token == null) {
        print('❌ لا يوجد token');
        return false;
      }

      print('📡 تحديث البريد إلى: $newEmail');

      final response = await http.put(
        Uri.parse('${BaseUrl.pubBaseUrl}/api/profile/email'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': newEmail,
          'current_password': currentPassword,
        }),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ تم تحديث البريد بنجاح');
        await fetchProfile(); // إعادة تحميل البيانات
        return true;
      } else {
        print('❌ فشل تحديث البريد: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('🚨 خطأ في تحديث البريد: $e');
      return false;
    }
  }

  // 2. تحديث كلمة المرور
  Future<bool> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final token = box.read('access_token');
      if (token == null) return false;
      final response = await http.put(
        Uri.parse('${BaseUrl.pubBaseUrl}/api/profile/password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        }),
      );

      print('📡 Update Password Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('🚨 Error updating password: $e');
      return false;
    }
  }

  //تغير الصورة

  // 3. حذف الحساب
  Future<bool> deleteAccount() async {
    try {
      final token = box.read('access_token');
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${BaseUrl.pubBaseUrl}/api/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📡 Delete Account Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // تنظيف local storage
        box.remove('access_token');
        box.remove('user_id');
        return true;
      }
      return false;
    } catch (e) {
      print('🚨 Error deleting account: $e');
      return false;
    }
  }

  Future<bool> updateAvatar(File imageFile) async {
    try {
      final token = box.read('access_token');
      if (token == null) return false;

      print('🖼 رفع صورة جديدة...');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseUrl.pubBaseUrl}/api/profile/avatar'),
      );

      // إضافة الهيدر
      request.headers['Authorization'] = 'Bearer $token';

      // إضافة الملف
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar', // اسم الحقل حسب API
          imageFile.path,
          contentType: http.MediaType('image', 'jpeg'), // أو 'png'
        ),
      );

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📡 Avatar Update Response: ${response.statusCode}');
      print('📄 Response: $responseBody');

      if (response.statusCode == 200) {
        print('✅ تم رفع الصورة بنجاح');
        await fetchProfile(); // تحديث البيانات المحلية
        return true;
      }

      return false;
    } catch (e) {
      print('🚨 Error updating avatar: $e');
      return false;
    }
  }

  // تغير صورة الهوية
  Future<bool> updateIdImage(File imageFile) async {
    try {
      final token = box.read('access_token');
      if (token == null) return false;

      print('🖼 رفع صورة هوية جديدة...');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseUrl.pubBaseUrl}/api/profile/id-image'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'id_image', // اسم الحقل مختلف
          imageFile.path,
          contentType: http.MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📡 ID Image Update Response: ${response.statusCode}');
      print('📄 Response: $responseBody');

      if (response.statusCode == 200) {
        print('✅ تم رفع صورة الهوية بنجاح');
        await fetchProfile();
        return true;
      }

      return false;
    } catch (e) {
      print('🚨 Error updating ID image: $e');
      return false;
    }
  }

  // ============================================
  // 📞 6. إرسال OTP لتغيير الهاتف
  // ============================================
  Future<bool> sendPhoneOtp(String phone) async {
    try {
      final token = box.read('access_token');
      if (token == null) return false;
      final response = await http.post(
        Uri.parse('${BaseUrl.pubBaseUrl}/api/profile/send-phone-otp'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'phone': phone}),
      );

      print('📡 Send Phone OTP Response: ${response.statusCode}');
      print('***Response Body:${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('🚨 Error sending phone OTP: $e');
      return false;
    }
  }

  // ============================================
  // 📱 7. تحديث الهاتف (مع OTP)
  // ============================================
  Future<bool> updatePhone(String phone, String code) async {
    try {
      final token = box.read('access_token');
      if (token == null) return false;

      print('📱 تحديث الهاتف: $phone مع الكود: $code');

      final response = await http.put(
        Uri.parse('${BaseUrl.pubBaseUrl}/api/profile/phone'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'phone': phone, 'code': code}),
      );

      print('📡 Update Phone Response: ${response.statusCode}');
      print('📄 Response Body: ${response.body}'); // 👈 مهم لمعرفة الخطأ

      if (response.statusCode == 200) {
        print('✅ تم تحديث الهاتف بنجاح');
        await fetchProfile();
        return true;
      }

      // إذا كان 422، اطبعي الخطأ
      if (response.statusCode == 422) {
        final errors = json.decode(response.body);
        print('❌ Validation Errors: $errors');
      }

      return false;
    } catch (e) {
      print('🚨 Error updating phone: $e');
      return false;
    }
  }

  // Getters معدلة للـAPI هيكليته
  String get fullName {
    final user = userData.value['data']; // ⭐️ نفتح الـdata أولاً
    if (user == null) return 'المستخدم';

    final name = user['name'] ?? '';
    return name.isNotEmpty ? name : 'المستخدم';
  }

  String get email {
    final user = userData.value['data'];
    return user?['email'] ?? 'لا يوجد بريد';
  }

  String get phone {
    final user = userData.value['data'];
    return user?['phone'] ?? 'لا يوجد هاتف';
  }

  String get role {
    final user = userData.value['data'];
    return user?['role'] ?? 'owner';
  }

  String? get avatarUrl {
    final user = userData.value['data'];
    final url = user?['avatar'];
    if (url == null || url.isEmpty) return null;
    if (!url.startsWith('http')) {
      return "${BaseUrl.pubBaseUrl}/$url";
    }
    return url;
  }

  // حالة الموافقة على الحساب
  String get approvalStatus {
    final user = userData.value['data'];
    return user?['status']?.toString() ?? 'pending';
  }

  // هل الحساب موثق؟
  bool get isVerified => approvalStatus == 'approved';

  // لون البادج

  bool get isOwner => role == 'owner';
  bool get isRenter => role == 'renter';
  Color get statusColor {
    switch (approvalStatus) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (approvalStatus) {
      case 'approved':
        return 'حساب موثق';
      case 'pending':
        return 'قيد المراجعة';
      case 'rejected':
        return 'حساب مرفوض';
      default:
        return 'غير معروف';
    }
  }
}