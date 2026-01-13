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
// POST AD CONTROLLER - ULTIMATE WORKING VERSION
// ✅ Combines best features from both versions
// ✅ Has saveDraftImages() with main image index
// ✅ Proper endpoint: /api/owner/apartments
// ✅ Image validation with File checking
// ✅ Sends main_image_index to backend
// ═══════════════════════════════════════════════════════════

class PostAdController extends GetxController {
  final _tokenService = Get.find<TokenStorageService>();
  final box = GetStorage();

  final myApartments = <ApartmentModel>[].obs;
  final isLoading = false.obs;

  ApartmentModel? draft;
  List<String> draftImages = [];
  int mainImageIndex = 0; // ✅ Track which image is main

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
    print('   Description: ${description.length} chars');
    print('   Location: $governorate, $city');
    print('   Price: \$$pricePerDay/day');
    print('   Rooms: $roomsCount');
    print('   Size: ${apartmentSize.toStringAsFixed(1)} m²');
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
  // SAVE DRAFT IMAGES
  // ✅ CORRECT METHOD NAME - Used by ApartmentImagesView
  // ✅ Tracks main image index
  // ═══════════════════════════════════════════════════════════

  void saveDraftImages(List<String> imagePaths, {int mainIndex = 0}) {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('💾 SAVING DRAFT IMAGES');
    print('   Total images: ${imagePaths.length}');
    print('   Main image index: $mainIndex');

    for (var i = 0; i < imagePaths.length; i++) {
      print('   ${i + 1}. ${imagePaths[i]}${i == mainIndex ? " ⭐ (MAIN)" : ""}');
    }

    print('═══════════════════════════════════════════════════════════');

    draftImages = imagePaths;
    mainImageIndex = mainIndex.clamp(0, imagePaths.length - 1); // Ensure valid index
    
    print('✅ Draft images saved');
    print('   Main image will be: ${draftImages[mainImageIndex]}');
  }

  // ═══════════════════════════════════════════════════════════
  // PUBLISH DRAFT - ULTIMATE VERSION
  // ✅ Proper endpoint: /api/owner/apartments
  // ✅ Sends main_image_index parameter
  // ✅ File validation
  // ✅ Enhanced error handling
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
      final token = await _tokenService.getAccessToken();

      if (token == null || token.isEmpty) {
        print('❌ NO TOKEN FOUND');
        _showReLoginMessage('No authentication token found');
        throw Exception('No access token');
      }
      
      print('✅ Token found: ${token.substring(0, 20)}...');

      // ✅ CORRECT ENDPOINT
      final url = '${BaseUrl.pubBaseUrl}/api/owner/apartments';
      print('   Endpoint: $url');

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $token';

      // ═══════════════════════════════════════════════════════
      // ADD TEXT FIELDS
      // ═══════════════════════════════════════════════════════

      request.fields['title'] = draft!.title;
      request.fields['description'] = description;
      request.fields['governorate'] = draft!.governorate;
      request.fields['city'] = draft!.city;
      request.fields['price_per_day'] = draft!.pricePerDay.toString();
      request.fields['rooms_count'] = draft!.roomsCount.toString();
      request.fields['apartment_size'] = draft!.apartmentSize.toString();

      // ✅ CRITICAL: Add main image index so backend knows which is main
      request.fields['main_image_index'] = mainImageIndex.toString();

      print('');
      print('📋 Request Fields:');
      request.fields.forEach((key, value) {
        if (key == 'main_image_index') {
          print('   $key: $value ⭐ (TELLS BACKEND WHICH IS MAIN)');
        } else {
          print('   $key: $value');
        }
      });

      // ═══════════════════════════════════════════════════════
      // PROCESS AND ADD IMAGES WITH VALIDATION
      // ═══════════════════════════════════════════════════════

      print('');
      print('📸 Processing Images:');
      print('   Total to upload: ${draftImages.length}');
      print('   Main image index: $mainImageIndex');
      
      int validImages = 0;
      
      for (var i = 0; i < draftImages.length; i++) {
        final imagePath = draftImages[i];
        final isMainImage = (i == mainImageIndex);
        
        print('');
        print('   Image ${i + 1}:${isMainImage ? " ⭐ MAIN IMAGE" : ""}');
        print('      Path: $imagePath');
        
        try {
          // ✅ VALIDATE FILE EXISTS
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
          
          // ✅ Add validated image with array notation
          request.files.add(
            await http.MultipartFile.fromPath(
              'images[]',  // Backend expects this format
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
      print('   Main image index: $mainImageIndex');
      print('   Main image will be: ${draftImages[mainImageIndex]}');

      if (request.files.isEmpty) {
        throw Exception('No valid images to upload - all image files were inaccessible');
      }

      // ═══════════════════════════════════════════════════════
      // SEND REQUEST
      // ═══════════════════════════════════════════════════════

      print('');
      print('📤 Sending request...');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('');
      print('📡 Response:');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');

      // ═══════════════════════════════════════════════════════
      // HANDLE RESPONSE
      // ═══════════════════════════════════════════════════════

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
        
        // Parse response to see returned images
        try {
          final responseData = jsonDecode(response.body);
          print('📦 Backend Response:');
          print('   ${jsonEncode(responseData)}');
          
          if (responseData.containsKey('apartment')) {
            final apt = responseData['apartment'];
            print('');
            print('🖼️  Image URLs from backend:');
            print('   Main Image: ${apt['main_image']}');
            if (apt.containsKey('images')) {
              print('   All Images: ${apt['images']}');
            }
          } else if (responseData.containsKey('data')) {
            final apt = responseData['data'];
            print('');
            print('🖼️  Image URLs from backend:');
            print('   Main Image: ${apt['main_image']}');
            if (apt.containsKey('images')) {
              print('   All Images: ${apt['images']}');
            }
          }
        } catch (e) {
          print('⚠️  Could not parse response: $e');
        }
        
        print('═══════════════════════════════════════════════════════════');

        // Clear draft first
        clearDraft();
        
        // ✅ Navigate BEFORE refreshing
        Get.back();
        print('🏠 Navigated back to PostAdScreen');
        
        // Small delay to ensure navigation completes
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Refresh apartment list
        await fetchMyApartments();
        
        // Show success message
        Get.snackbar(
          'Success',
          'Apartment published successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22C55E),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
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
  // FETCH MY APARTMENTS
  // ═══════════════════════════════════════════════════════════

  Future<void> fetchMyApartments() async {
    try {
      isLoading.value = true;

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📥 FETCHING MY APARTMENTS');
      print('═══════════════════════════════════════════════════════════');

      final token = await _tokenService.getAccessToken();

      if (token == null) {
        print('⚠️  No access token found');
        return;
      }

      final url = '${BaseUrl.pubBaseUrl}/api/owner/apartments';
      print('   URL: $url');

      final response = await http.get(
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

        if (data is Map && data.containsKey('data')) {
          final dataValue = data['data'];

          if (dataValue is List) {
            apartmentsJson = dataValue;
          } else if (dataValue is Map && dataValue.containsKey('data')) {
            apartmentsJson = dataValue['data'] as List;
          } else {
            print('❌ Unexpected data format');
            return;
          }
        } else if (data is List) {
          apartmentsJson = data;
        } else {
          print('❌ No data key found');
          return;
        }

        final apartments = <ApartmentModel>[];

        for (var json in apartmentsJson) {
          try {
            final apartment = ApartmentModel.fromJson(json);
            apartments.add(apartment);
            
            print('   ✅ ${apartment.title}');
            print('      Main Image: ${apartment.mainImage}');
          } catch (e) {
            print('   ❌ Error parsing apartment: $e');
          }
        }

        myApartments.value = apartments;

        print('✅ Loaded ${apartments.length} apartments');
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
  // CLEAR DRAFT
  // ═══════════════════════════════════════════════════════════

  void clearDraft() {
    draft = null;
    draftImages = [];
    mainImageIndex = 0;
    print('🗑️  Draft cleared');
  }

  // ═══════════════════════════════════════════════════════════
  // CANCEL DRAFT
  // ═══════════════════════════════════════════════════════════

  void cancelDraft() {
    clearDraft();
    print('🗑️  Draft cancelled');
  }

  // ═══════════════════════════════════════════════════════════
  // SHOW RE-LOGIN MESSAGE
  // ═══════════════════════════════════════════════════════════

  void _showReLoginMessage(String message) {
    Get.snackbar(
      'Authentication Required',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DELETE APARTMENT
  // ═══════════════════════════════════════════════════════════

  Future<bool> deleteApartment(int apartmentId) async {
    try {
      print('🗑️  Deleting apartment $apartmentId...');
      
      final token = await _tokenService.getAccessToken();
      if (token == null) {
        print('❌ No token');
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

      print('   Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Deleted successfully');
        
        // Remove from local list
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
        print('❌ Delete failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting apartment: $e');
      return false;
    }
  }

  @override
  void onClose() {
    print('📝 Post Ad Controller closed');
    super.onClose();
  }
}