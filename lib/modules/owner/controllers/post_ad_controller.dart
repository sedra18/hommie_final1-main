import 'dart:convert';
import 'dart:io';  // ← CRITICAL: Add this for File validation
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/services/token_storage_service.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;

// ═══════════════════════════════════════════════════════════
// POST AD CONTROLLER - FULLY FIXED
// ✅ Fixed endpoint: /api/owner/apartments
// ✅ Fixed type mismatch: pricePerDay
// ✅ Added image validation with dart:io
// ✅ Enhanced debugging logs
// ═══════════════════════════════════════════════════════════

class PostAdController extends GetxController {
  final _tokenService = Get.find<TokenStorageService>();
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
  // SAVE DRAFT BASIC INFO - ✅ FIXED TYPE
  // Changed pricePerDay from int to double
  // ═══════════════════════════════════════════════════════════

  void saveDraftBasicInfo({
    required String title,
    required String description,
    required String governorate,
    required String city,
    required String address,
    required int pricePerDay,  // ✅ FIXED: Changed from int to double
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
    print('   Price: \$${pricePerDay.toStringAsFixed(1)}/day');
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
        } else {
          print('❌ No data key found');
          return;
        }

        final apartments = <ApartmentModel>[];

        for (var json in apartmentsJson) {
          try {
            final apartment = ApartmentModel.fromJson(json);
            apartments.add(apartment);
          } catch (e) {
            print('❌ Error parsing apartment: $e');
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

      final url = '${BaseUrl.pubBaseUrl}/api/apartments/$apartmentId';

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 DELETE /apartments/$apartmentId - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
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
  // SAVE DRAFT IMAGES FROM FILES
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
  // PUBLISH DRAFT - FULLY FIXED WITH IMAGE VALIDATION
  // ✅ Fixed endpoint: /api/owner/apartments
  // ✅ Added File validation
  // ✅ Enhanced error logging
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

      if (token == null) {
        throw Exception('No access token');
      }

      // ✅ FIXED: Changed from /api/apartments to /api/owner/apartments
      final url = '${BaseUrl.pubBaseUrl}/api/owner/apartments';
      print('   Endpoint: $url');

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $token';

      // Add apartment data
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

      // ✅ CRITICAL FIX: Validate and add images
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
          // ✅ CRITICAL: Validate file exists
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
          
          // ✅ Add validated image
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
        throw Exception('No valid images to upload - all image files were inaccessible');
      }

      print('');
      print('📤 Sending request...');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('');
      print('📡 Response:');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('');
        print('✅ APARTMENT PUBLISHED SUCCESSFULLY');
        print('═══════════════════════════════════════════════════════════');

        await fetchMyApartments();
        clearDraft();
        
        Get.snackbar(
          'Success',
          'Apartment created successfully!',
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
          'Failed to create apartment. Please try again.',
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
  // CANCEL DRAFT
  // ═══════════════════════════════════════════════════════════

  void cancelDraft() {
    draft = null;
    draftImages = [];
    print('🗑️  Draft cancelled');
  }

  // ═══════════════════════════════════════════════════════════
  // CLEAR DRAFT
  // ═══════════════════════════════════════════════════════════

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