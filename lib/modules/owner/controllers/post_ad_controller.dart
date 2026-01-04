import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/services/token_storage_service.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;

// ═══════════════════════════════════════════════════════════
// POST AD CONTROLLER - WITH 401 HANDLING
// ✅ Validates token before publishing
// ✅ Handles 401 errors gracefully
// ✅ Prompts user to re-login after approval
// ═══════════════════════════════════════════════════════════

class PostAdController extends GetxController {
  final _tokenService = Get.put(TokenStorageService());
  final box = GetStorage();

  final myApartments = <ApartmentModel>[].obs;
  final isLoading = false.obs;

  ApartmentModel? draft;
  List<String> draftImages = [];

  @override
  void onInit() {
    super.onInit();
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📝 POST AD CONTROLLER - INITIALIZING');
    print('═══════════════════════════════════════════════════════════');
    
    fetchMyApartments();
  }

  // ═══════════════════════════════════════════════════════════
  // SAVE DRAFT BASIC INFO
  // ═══════════════════════════════════════════════════════════

  void saveDraftBasicInfo({
    required String title,
    required String description,
    required String governorate,
    required String city,
    required String address,
    required int pricePerDay,
    required int roomsCount,
    required double apartmentSize,
  }) {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('💾 SAVING DRAFT BASIC INFO');
    print('──────────────────────────────────────────────────────────');
    print('   Title: $title');
    print('   governorate: $governorate');
    print('   city: $city');
    print('   price_per_day: $pricePerDay');
    print('   rooms_count: $roomsCount');
    print('   apartment_size: $apartmentSize');
    print('═══════════════════════════════════════════════════════════');

    draft = ApartmentModel(
      id: 0,
      title: title,
      description: description,
      governorate: governorate,
      city: city,
      address: address,
      pricePerDay: pricePerDay,
      roomsCount: roomsCount,
      apartmentSize: apartmentSize,
      mainImage: '',
      imageUrls: [],
      avgRating: 0.0,
      ownerName: null,
      isFavorite: false,
    );

    print('✅ Draft basic info saved');
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH MY APARTMENTS
  // ✅ FIXED: Only shows apartments published by current owner
  // Filters by user_id to ensure each owner sees only their own apartments
  // ═══════════════════════════════════════════════════════════

  Future<void> fetchMyApartments() async {
    try {
      isLoading.value = true;

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📥 FETCHING MY APARTMENTS ONLY');
      print('═══════════════════════════════════════════════════════════');

      final token = await _tokenService.getAccessToken();

      if (token == null) {
        print('⚠️  No access token found');
        return;
      }
      
      // ✅ CRITICAL: Get current user ID
      final currentUserId = await _tokenService.getUserId();
      
      if (currentUserId == null) {
        print('⚠️  No user ID found');
        return;
      }
      
      print('   Current User ID: $currentUserId');

      final url = '${BaseUrl.pubBaseUrl}/api/owner/apartments';
      print('   URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('   Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> apartmentsJson;

        if (data is List) {
          apartmentsJson = data;
        } else if (data is Map && data.containsKey('data')) {
          final dataValue = data['data'];
          if (dataValue is List) {
            apartmentsJson = dataValue;
          } else if (dataValue is Map && dataValue.containsKey('data')) {
            apartmentsJson = dataValue['data'] as List;
          } else {
            apartmentsJson = [];
          }
        } else {
          apartmentsJson = [];
        }

        print('   Total apartments from API: ${apartmentsJson.length}');

        final apartments = <ApartmentModel>[];

        for (var json in apartmentsJson) {
          try {
            final apartment = ApartmentModel.fromJson(json);
            
            // ✅ CRITICAL: Only add apartments that belong to current owner
            if (apartment.userId == currentUserId) {
              apartments.add(apartment);
              print('   ✅ Added: ${apartment.title} (user_id: ${apartment.userId})');
            } else {
              print('   ⏭️  Skipped: ${apartment.title} (user_id: ${apartment.userId}, not mine)');
            }
          } catch (e) {
            print('❌ Error parsing apartment: $e');
          }
        }

        myApartments.value = apartments;
        
        print('');
        print('📊 FILTERING RESULTS:');
        print('   Total apartments: ${apartmentsJson.length}');
        print('   My apartments: ${apartments.length}');
        print('   Other owners: ${apartmentsJson.length - apartments.length}');
        print('✅ Loaded ${apartments.length} of MY apartments only');
        print('═══════════════════════════════════════════════════════════');
      } else {
        print('❌ Failed with status ${response.statusCode}');
        print('   Response: ${response.body}');
        print('═══════════════════════════════════════════════════════════');
      }
    } catch (e) {
      print('❌ Error fetching apartments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // DELETE APARTMENT
  // ═══════════════════════════════════════════════════════════

  Future<bool> deleteApartment(int apartmentId) async {
    try {
      print('🗑️  Deleting apartment ID: $apartmentId');

      final token = await _tokenService.getAccessToken();

      if (token == null) {
        print('⚠️  No access token');
        return false;
      }

      final url = '${BaseUrl.pubBaseUrl}/api/owner/apartments/$apartmentId';

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 DELETE /apartments/$apartmentId - Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Apartment deleted successfully');

        myApartments.removeWhere((apt) => apt.id == apartmentId);

        Get.snackbar(
          'Success',
          'Apartment deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22C55E),
          colorText: Colors.white,
        );

        return true;
      } else {
        print('❌ Failed to delete: ${response.statusCode}');
        print('Response: ${response.body}');

        Get.snackbar(
          'Error',
          'Failed to delete apartment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        return false;
      }
    } catch (e) {
      print('❌ Error deleting apartment: $e');

      Get.snackbar(
        'Error',
        'Failed to delete apartment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SAVE DRAFT IMAGES
  // ═══════════════════════════════════════════════════════════

  Future<void> saveDraftImagesFromFiles(List<String> imagePaths) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('💾 SAVING DRAFT IMAGES FROM FILES');
    print('──────────────────────────────────────────────────────────');
    print('   Number of images: ${imagePaths.length}');

    for (var i = 0; i < imagePaths.length; i++) {
      print('   ${i + 1}. ${imagePaths[i]}');
    }

    print('═══════════════════════════════════════════════════════════');

    draftImages = imagePaths;
    print('✅ Draft images saved');
  }

  // ═══════════════════════════════════════════════════════════
  // PUBLISH DRAFT - WITH TOKEN VALIDATION & 401 HANDLING
  // ✅ Checks token before making request
  // ✅ Handles 401 errors with helpful message
  // ✅ Prompts user to re-login
  // ═══════════════════════════════════════════════════════════

  Future<void> publishDraft() async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📤 PUBLISHING DRAFT APARTMENT');
    print('═══════════════════════════════════════════════════════════');

    if (draft == null) {
      throw Exception('No draft to publish');
    }

    if (draft!.title.isEmpty) {
      throw Exception('Missing title');
    }

    final description = draft!.description ?? '';
    if (description.isEmpty) {
      throw Exception('Missing description');
    }

    if (draftImages.isEmpty) {
      throw Exception('Missing images');
    }

    try {
      // ✅ STEP 1: Validate token exists
      final token = await _tokenService.getAccessToken();

      if (token == null || token.isEmpty) {
        print('❌ NO TOKEN FOUND');
        _showReLoginMessage('No authentication token found');
        throw Exception('No access token');
      }
      
      print('✅ Token found: ${token.substring(0, 20)}...');

      final url = '${BaseUrl.pubBaseUrl}/api/apartments';
      print('   Endpoint: $url');

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      request.fields['title'] = draft!.title;
      request.fields['description'] = description;
      request.fields['governorate'] = draft!.governorate;
      request.fields['city'] = draft!.city;
      request.fields['price_per_day'] = draft!.pricePerDay.toString();
      request.fields['rooms_count'] = draft!.roomsCount.toString();
      request.fields['apartment_size'] = draft!.apartmentSize.toString();

      print('');
      print('📋 Request Fields:');
      request.fields.forEach((key, value) {
        print('   $key: $value');
      });

      // Process images
      print('');
      print('📸 Processing Images:');
      print('   Total to upload: ${draftImages.length}');
      
      int validImages = 0;
      
      for (var i = 0; i < draftImages.length; i++) {
        final imagePath = draftImages[i];
        print('');
        print('   Image ${i + 1}:');
        print('      Path: $imagePath');
        
        try {
          final file = File(imagePath);
          final exists = await file.exists();
          print('      Exists: $exists');
          
          if (!exists) {
            print('      ❌ SKIPPED - File not found');
            continue;
          }
          
          final fileSize = await file.length();
          print('      Size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
          
          if (fileSize == 0) {
            print('      ❌ SKIPPED - Empty file');
            continue;
          }
          
          request.files.add(
            await http.MultipartFile.fromPath(
              'images[]',
              imagePath,
            ),
          );
          
          validImages++;
          print('      ✅ Added successfully');
          
        } catch (e) {
          print('      ❌ ERROR: $e');
        }
      }

      print('');
      print('📦 Upload Summary:');
      print('   Total files: ${request.files.length}');
      print('   Valid images: $validImages');

      if (request.files.isEmpty) {
        throw Exception('No valid images to upload');
      }

      print('');
      print('📤 Sending request...');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('');
      print('📡 Response:');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');

      // ✅ STEP 2: Handle 401 Unauthenticated
      if (response.statusCode == 401) {
        print('');
        print('❌ 401 UNAUTHENTICATED - TOKEN INVALID');
        print('═══════════════════════════════════════════════════════════');
        
        _showReLoginMessage('Your session has expired');
        throw Exception('Authentication failed - please login again');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('');
        print('✅ APARTMENT PUBLISHED SUCCESSFULLY');
        print('═══════════════════════════════════════════════════════════');

        await fetchMyApartments();
        clearDraft();
        
        Get.snackbar(
          'Success',
          'Apartment published successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22C55E),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        print('');
        print('❌ FAILED TO PUBLISH');
        print('   Status: ${response.statusCode}');
        print('═══════════════════════════════════════════════════════════');
        
        Get.snackbar(
          'Error',
          'Failed to publish apartment (${response.statusCode})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        throw Exception('Failed to publish apartment');
      }
    } catch (e) {
      print('');
      print('❌ ERROR PUBLISHING APARTMENT');
      print('   Error: $e');
      print('═══════════════════════════════════════════════════════════');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SHOW RE-LOGIN MESSAGE
  // ✅ Helpful message for 401 errors
  // ═══════════════════════════════════════════════════════════
  
  void _showReLoginMessage(String reason) {
    Get.snackbar(
      '🔐 Re-login Required',
      '$reason.\n\nAfter admin approval, you must logout and login again to activate publishing.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 8),
      icon: const Icon(Icons.lock_outline, color: Colors.white, size: 32),
      margin: const EdgeInsets.all(16),
      mainButton: TextButton(
        onPressed: () {
          // Logout and redirect
          box.erase();
          Get.offAllNamed('/');
        },
        child: const Text(
          'LOGOUT NOW',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CLEAR & CANCEL DRAFT
  // ═══════════════════════════════════════════════════════════

  void cancelDraft() {
    draft = null;
    draftImages = [];
    print('🗑️  Draft cancelled');
  }

  void clearDraft() {
    draft = null;
    draftImages = [];
    print('🧹 Draft cleared');
  }

  @override
  void onClose() {
    print('📝 Post Ad Controller closed');
    super.onClose();
  }
}