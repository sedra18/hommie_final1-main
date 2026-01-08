import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/user/user_model.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;

import 'package:hommie/data/services/token_storage_service.dart';

// ═══════════════════════════════════════════════════════════
// USER SERVICE
// Fetches and manages user profile data
// ═══════════════════════════════════════════════════════════

class UserService extends GetxService {
  static final String _baseUrl =
      '${BaseUrl.pubBaseUrl}/api'; // ✅ Use 10.0.2.2 for emulator

  // ✅ Observable user data
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final _isLoadingUser = false.obs;

  bool get isLoadingUser => _isLoadingUser.value;
  bool get hasUser => currentUser.value != null;

  // Getters for easy access
  String get userName => currentUser.value?.name ?? 'User';
  String get userEmail => currentUser.value?.email ?? 'user@example.com';
  int? get userId => currentUser.value?.id;
  String get userRole => currentUser.value?.role ?? '';
  String get approvalStatus => currentUser.value?.approvalStatus ?? 'unknown';

  // ═══════════════════════════════════════════════════════════
  // FETCH CURRENT USER PROFILE
  // Called on login and can be refreshed on demand
  // ═══════════════════════════════════════════════════════════

  Future<void> fetchUserProfile() async {
    try {
      _isLoadingUser.value = true;

      final tokenService = Get.put(TokenStorageService());
      final token = await tokenService.getAccessToken();

      if (token == null) {
        print('⚠️ No token found, cannot fetch user profile');
        currentUser.value = null;
        return;
      }

      print('📥 Fetching user profile...');

      final response = await http.get(
        Uri.parse('$_baseUrl/user'), // or '/user/profile'
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parse user data
        currentUser.value = UserModel.fromJson(data);

        print('✅ User profile loaded: ${currentUser.value?.name}');
        print('   Email: ${currentUser.value?.email}');
        print('   Role: ${currentUser.value?.role}');
        print('   Status: ${currentUser.value?.approvalStatus}');

        // ✅ Force UI update
        currentUser.refresh();
      } else if (response.statusCode == 404) {
        print('⚠️ User profile endpoint not found (404)');
        currentUser.value = null;
      } else {
        print('⚠️ Failed to fetch user profile: ${response.statusCode}');
        currentUser.value = null;
      }
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      currentUser.value = null;
    } finally {
      _isLoadingUser.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // UPDATE USER PROFILE
  // ═══════════════════════════════════════════════════════════

  Future<bool> updateUserProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      _isLoadingUser.value = true;

      final tokenService = Get.put(TokenStorageService());
      final token = await tokenService.getAccessToken();

      if (token == null) {
        print('⚠️ No token found, cannot update profile');
        return false;
      }

      print('📤 Updating user profile...');

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;

      final response = await http.put(
        Uri.parse('$_baseUrl/user'), // or '/user/profile'
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        currentUser.value = UserModel.fromJson(data);

        print('✅ Profile updated successfully');

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF22C55E),
          colorText: const Color(0xFFFFFFFF),
        );

        return true;
      } else {
        print('⚠️ Failed to update profile: ${response.statusCode}');

        Get.snackbar(
          'Error',
          'Failed to update profile. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFEF4444),
          colorText: const Color(0xFFFFFFFF),
        );

        return false;
      }
    } catch (e) {
      print('❌ Error updating profile: $e');

      Get.snackbar(
        'Error',
        'An error occurred while updating profile.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: const Color(0xFFFFFFFF),
      );

      return false;
    } finally {
      _isLoadingUser.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // REFRESH USER PROFILE
  // ═══════════════════════════════════════════════════════════

  Future<void> refreshUserProfile() async {
    print('🔄 Refreshing user profile...');
    await fetchUserProfile();
  }

  // ═══════════════════════════════════════════════════════════
  // CLEAR USER DATA (for logout)
  // ═══════════════════════════════════════════════════════════

  void clearUserData() {
    currentUser.value = null;
    print('🔄 User data cleared');
  }

  // ═══════════════════════════════════════════════════════════
  // GET AVATAR URL
  // ═══════════════════════════════════════════════════════════

  String? getAvatarUrl() {
    if (currentUser.value?.avatar != null) {
      // If it's a full URL, return as is
      if (currentUser.value!.avatar!.startsWith('http')) {
        return currentUser.value!.avatar;
      }
      // Otherwise, prepend base URL
      return '$_baseUrl/storage/${currentUser.value!.avatar}';
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════
  // UPLOAD AVATAR
  // ═══════════════════════════════════════════════════════════

  Future<bool> uploadAvatar(String imagePath) async {
    try {
      _isLoadingUser.value = true;

      final tokenService = Get.put(TokenStorageService());
      final token = await tokenService.getAccessToken();

      if (token == null) {
        print('⚠️ No token found, cannot upload avatar');
        return false;
      }

      print('📤 Uploading avatar...');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/user/avatar'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('avatar', imagePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        currentUser.value = UserModel.fromJson(data);

        print('✅ Avatar uploaded successfully');

        Get.snackbar(
          'Success',
          'Avatar updated successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF22C55E),
          colorText: const Color(0xFFFFFFFF),
        );

        return true;
      } else {
        print('⚠️ Failed to upload avatar: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error uploading avatar: $e');
      return false;
    } finally {
      _isLoadingUser.value = false;
    }
  }
}
