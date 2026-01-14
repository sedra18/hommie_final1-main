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
// POST AD CONTROLLER - ULTIMATE FIX
// ✅ Fixes quotes and backslashes in URLs
// ✅ Handles null main_image by using first image
// ✅ First image is always main image
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
    required int apartmentSize,
  }) {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('💾 SAVING DRAFT BASIC INFO');
    print('──────────────────────────────────────────────────────────');
    print('   Title: $title');
    print('   governorate: $governorate');
    print('   city: $city');
    print('   address: $address');
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
  // SAVE DRAFT IMAGES
  // ✅ Main image is ALWAYS FIRST
  // ═══════════════════════════════════════════════════════════

  Future<void> saveDraftImages(List<String> imagePaths, {int mainIndex = 0}) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('💾 SAVING DRAFT IMAGES');
    print('   Total images: ${imagePaths.length}');
    print('   Main image index: $mainIndex');
    print('──────────────────────────────────────────────────────────');

    final validImages = <String>[];
    
    for (var i = 0; i < imagePaths.length; i++) {
      final path = imagePaths[i];
      final isMain = (i == mainIndex);
      
      print('   Image ${i + 1}:${isMain ? " ⭐ MAIN" : ""}');
      print('      Path: $path');
      
      try {
        final file = File(path);
        final exists = await file.exists();
        
        if (!exists) {
          print('      ❌ File does not exist - SKIPPED');
          continue;
        }
        
        final size = await file.length();
        print('      Size: ${(size / 1024).toStringAsFixed(2)} KB');
        
        if (size == 0) {
          print('      ❌ Empty file - SKIPPED');
          continue;
        }
        
        validImages.add(path);
        print('      ✅ Valid');
        
      } catch (e) {
        print('      ❌ Error: $e - SKIPPED');
      }
    }

    if (validImages.isEmpty) {
      print('');
      print('❌ NO VALID IMAGES FOUND');
      print('═══════════════════════════════════════════════════════════');
      throw Exception('No valid images found');
    }

    // ✅ Move main image to front
    final adjustedMainIndex = mainIndex.clamp(0, validImages.length - 1);
    
    if (adjustedMainIndex != 0) {
      final mainImagePath = validImages.removeAt(adjustedMainIndex);
      validImages.insert(0, mainImagePath);
      print('   🔄 Reordered: Main image moved to position 0');
    }

    draftImages = validImages;

    print('');
    print('📊 SUMMARY:');
    print('   Valid images: ${validImages.length}');
    print('   ⭐ MAIN IMAGE: ${validImages[0]}');
    print('✅ Draft images saved');
    print('═══════════════════════════════════════════════════════════');
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
      
      final currentUserId = await _tokenService.getUserId();
      
      if (currentUserId == null) {
        print('⚠️  No user ID found');
        return;
      }
      
      print('   Current User ID: $currentUserId');

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
            // ✅ Fix URLs BEFORE parsing
            final fixedJson = _fixImageUrls(json);
            
            final apartment = ApartmentModel.fromJson(fixedJson);
            
            // ✅ Check both user_id and owner_id
            final apartmentUserId = apartment.userId ?? json['owner_id'];
            
            if (apartmentUserId == currentUserId) {
              apartments.add(apartment);
              print('      ✅ Added: ${apartment.title}');
              print('         User ID: $apartmentUserId (matches)');
              print('         Main Image: ${apartment.mainImage}');
            } else {
              print('      ⏭️  Skipped: ${apartment.title}');
              print('         User ID: $apartmentUserId (doesn\'t match $currentUserId)');
            }
          } catch (e, stackTrace) {
            print('      ❌ Error parsing: $e');
          }
        }

        myApartments.value = apartments;
        
        print('');
        print('📊 RESULTS:');
        print('   My apartments: ${apartments.length}');
        print('✅ Loaded successfully');
        print('═══════════════════════════════════════════════════════════');
      } else {
        print('❌ Failed: ${response.statusCode}');
        print('   Response: ${response.body}');
        print('═══════════════════════════════════════════════════════════');
      }
    } catch (e) {
      print('❌ Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FIX IMAGE URLS - ULTIMATE FIX
  // ✅ Removes quotes
  // ✅ Removes backslashes  
  // ✅ Handles null main_image
  // ═══════════════════════════════════════════════════════════
  
  Map<String, dynamic> _fixImageUrls(Map<String, dynamic> json) {
    final baseUrl = BaseUrl.pubBaseUrl;
    
    // Helper function to clean a single URL
    String cleanImageUrl(String url) {
      if (url.isEmpty || url.startsWith('http')) {
        return url;
      }
      
      // ✅ Remove quotes, backslashes, and clean path
      String cleaned = url
          .replaceAll('"', '')           // Remove quotes
          .replaceAll('\\', '/')         // Fix backslashes
          .replaceAll('//', '/')         // Fix double slashes
          .trim();
      
      // Remove 'storage/' prefix if present
      if (cleaned.startsWith('storage/')) {
        cleaned = cleaned.substring(8);
      }
      
      return '$baseUrl/storage/$cleaned';
    }
    
    // Fix images array FIRST
    List<String> fixedImagesList = [];
    
    if (json.containsKey('images')) {
      final images = json['images'];
      
      if (images is String && images.isNotEmpty) {
        try {
          final imagesList = jsonDecode(images) as List;
          fixedImagesList = imagesList
              .map((img) => cleanImageUrl(img.toString()))
              .where((url) => url.isNotEmpty)
              .toList();
        } catch (e) {
          print('         ⚠️  Error parsing images: $e');
        }
      } else if (images is List) {
        fixedImagesList = images
            .map((img) => cleanImageUrl(img.toString()))
            .where((url) => url.isNotEmpty)
            .toList();
      }
    }
    
    // Fix main_image
    String? mainImageUrl;
    
    if (json.containsKey('main_image') && json['main_image'] != null) {
      final mainImage = json['main_image'].toString();
      
      if (mainImage.isNotEmpty && mainImage != 'null') {
        mainImageUrl = cleanImageUrl(mainImage);
      }
    }
    
    // ✅ If main_image is null/empty, use first image
    if (mainImageUrl == null || mainImageUrl.isEmpty) {
      if (fixedImagesList.isNotEmpty) {
        mainImageUrl = fixedImagesList[0];
        print('         🔧 Fixed null main_image → using first image');
      } else {
        mainImageUrl = '';
      }
    }
    
    json['main_image'] = mainImageUrl;
    
    // Update images in json
    if (fixedImagesList.isNotEmpty) {
      json['images'] = jsonEncode(fixedImagesList);
    }
    
    return json;
  }

  // ═══════════════════════════════════════════════════════════
  // PUBLISH DRAFT
  // ═══════════════════════════════════════════════════════════

  Future<void> publishDraft() async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📤 PUBLISHING DRAFT');
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
        print('❌ NO TOKEN');
        _showReLoginMessage('No authentication token found');
        throw Exception('No access token');
      }
      
      print('✅ Token: ${token.substring(0, 20)}...');

      final url = '${BaseUrl.pubBaseUrl}/api/owner/apartments';
      print('   Endpoint: $url');

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      request.fields['title'] = draft!.title;
      request.fields['description'] = description;
      request.fields['governorate'] = draft!.governorate;
      request.fields['city'] = draft!.city;
      request.fields['address'] = draft!.address ?? '';
      request.fields['price_per_day'] = draft!.pricePerDay.toString();
      request.fields['rooms_count'] = draft!.roomsCount.toString();
      request.fields['apartment_size'] = draft!.apartmentSize.toString();

      print('');
      print('📋 Fields:');
      request.fields.forEach((key, value) {
        print('   $key: $value');
      });

      // Add images (first is main)
      print('');
      print('📸 Images:');
      print('   Total: ${draftImages.length}');
      print('   ⭐ FIRST = MAIN');
      
      int validImages = 0;
      
      for (var i = 0; i < draftImages.length; i++) {
        final imagePath = draftImages[i];
        final isMainImage = (i == 0);
        
        print('');
        print('   Image ${i + 1}:${isMainImage ? " ⭐ MAIN" : ""}');
        
        try {
          final file = File(imagePath);
          
          if (!await file.exists()) {
            print('      ❌ Not found');
            continue;
          }
          
          final fileSize = await file.length();
          print('      Size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
          
          if (fileSize == 0) {
            print('      ❌ Empty');
            continue;
          }
          
          request.files.add(
            await http.MultipartFile.fromPath('images[]', imagePath),
          );
          
          validImages++;
          print('      ✅ Added');
          
        } catch (e) {
          print('      ❌ Error: $e');
        }
      }

      print('');
      print('📦 Summary: $validImages images');

      if (request.files.isEmpty) {
        throw Exception('No valid images');
      }

      print('📤 Sending...');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('');
      print('📡 Response: ${response.statusCode}');

      if (response.statusCode == 401) {
        print('❌ 401 UNAUTHENTICATED');
        _showReLoginMessage('Session expired');
        throw Exception('Authentication failed');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ SUCCESS');
        
        try {
          final responseData = jsonDecode(response.body);
          
          if (responseData.containsKey('data')) {
            final apt = responseData['data'];
            print('   Main Image: ${apt['main_image']}');
            print('   Images: ${apt['images']}');
          }
        } catch (e) {
          print('   Could not parse response');
        }
        
        print('═══════════════════════════════════════════════════════════');

        clearDraft();
        Get.back();
        
        await Future.delayed(const Duration(milliseconds: 100));
        await fetchMyApartments();
        
        Get.snackbar(
          'Success',
          'Apartment published!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22C55E),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        print('❌ FAILED: ${response.statusCode}');
        print('   Body: ${response.body}');
        
        Get.snackbar(
          'Error',
          'Failed (${response.statusCode})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        throw Exception('Failed to publish');
      }
    } catch (e) {
      print('❌ ERROR: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // DELETE APARTMENT
  // ═══════════════════════════════════════════════════════════

  Future<bool> deleteApartment(int apartmentId) async {
    try {
      final token = await _tokenService.getAccessToken();

      if (token == null) {
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

      if (response.statusCode == 200 || response.statusCode == 204) {
        myApartments.removeWhere((apt) => apt.id == apartmentId);
        
        Get.snackbar(
          'Success',
          'Apartment deleted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22C55E),
          colorText: Colors.white,
        );

        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════

  void clearDraft() {
    draft = null;
    draftImages = [];
    print('🧹 Draft cleared');
  }

  void cancelDraft() {
    clearDraft();
  }
  
  void _showReLoginMessage(String reason) {
    Get.snackbar(
      '🔐 Re-login Required',
      '$reason. Please logout and login again.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 8),
      icon: const Icon(Icons.lock_outline, color: Colors.white, size: 32),
      margin: const EdgeInsets.all(16),
      mainButton: TextButton(
        onPressed: () {
          box.erase();
          Get.offAllNamed('/');
        },
        child: const Text(
          'LOGOUT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    print('📝 Post Ad Controller closed');
    super.onClose();
  }
}