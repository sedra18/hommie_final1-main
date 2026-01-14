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
// POST AD CONTROLLER - WITH PAGINATION
// ✅ Loads 10 apartments at a time
// ✅ Fetches more when scrolling
// ✅ Handles paginated response
// ═══════════════════════════════════════════════════════════

class PostAdController extends GetxController {
  final _tokenService = Get.find<TokenStorageService>();
  final box = GetStorage();

  final myApartments = <ApartmentModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  
  // Pagination state
  int currentPage = 1;
  int lastPage = 1;
  bool hasMorePages = false;

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
    print('   Governorate: $governorate');
    print('   City: $city');
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
  // ═══════════════════════════════════════════════════════════

  Future<void> saveDraftImages(List<String> imagePaths, {int mainIndex = 0}) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('💾 SAVING DRAFT IMAGES');
    print('   Total: ${imagePaths.length}, Main index: $mainIndex');
    print('──────────────────────────────────────────────────────────');

    final validImages = <String>[];
    
    for (var i = 0; i < imagePaths.length; i++) {
      final path = imagePaths[i];
      final isMain = (i == mainIndex);
      
      print('   Image ${i + 1}:${isMain ? " ⭐ MAIN" : ""}');
      
      try {
        final file = File(path);
        
        if (!await file.exists()) {
          print('      ❌ Not found');
          continue;
        }
        
        final size = await file.length();
        print('      ✅ ${(size / 1024).toStringAsFixed(2)} KB');
        
        if (size == 0) {
          print('      ❌ Empty');
          continue;
        }
        
        validImages.add(path);
        
      } catch (e) {
        print('      ❌ Error: $e');
      }
    }

    if (validImages.isEmpty) {
      throw Exception('No valid images');
    }

    // Move main image to front
    final adjustedMainIndex = mainIndex.clamp(0, validImages.length - 1);
    
    if (adjustedMainIndex != 0) {
      final mainImagePath = validImages.removeAt(adjustedMainIndex);
      validImages.insert(0, mainImagePath);
      print('   🔄 Main moved to front');
    }

    draftImages = validImages;

    print('');
    print('📊 SUMMARY: ${validImages.length} images, first is main');
    print('✅ Saved');
    print('═══════════════════════════════════════════════════════════');
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH MY APARTMENTS - WITH PAGINATION
  // ✅ Loads first page (page 1)
  // ═══════════════════════════════════════════════════════════

  Future<void> fetchMyApartments({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      myApartments.clear();
    }
    
    try {
      isLoading.value = true;

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📥 FETCHING MY APARTMENTS (Page $currentPage)');
      print('═══════════════════════════════════════════════════════════');

      final token = await _tokenService.getAccessToken();

      if (token == null) {
        print('⚠️  No token');
        return;
      }
      
      final currentUserId = await _tokenService.getUserId();
      
      if (currentUserId == null) {
        print('⚠️  No user ID');
        return;
      }
      
      print('   User ID: $currentUserId');

      final url = '${BaseUrl.pubBaseUrl}/api/owner/apartments?page=$currentPage';
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

        // ✅ Extract pagination info
        final paginationInfo = _extractPaginationInfo(data);
        currentPage = paginationInfo['currentPage'] ?? 1;
        lastPage = paginationInfo['lastPage'] ?? 1;
        hasMorePages = currentPage < lastPage;
        
        print('   📄 Pagination: Page $currentPage of $lastPage');
        print('   📄 Has more: $hasMorePages');

        // ✅ Handle paginated response
        List<dynamic> apartmentsJson = _parsePaginatedResponse(data);

        print('   Total from API: ${apartmentsJson.length}');

        final apartments = <ApartmentModel>[];

        for (var json in apartmentsJson) {
          try {
            final apartmentId = json['id'];
            
            print('');
            print('   📦 Fetching details for #$apartmentId...');
            
            final detailsJson = await _fetchApartmentDetails(apartmentId, token);
            
            if (detailsJson != null) {
              final fixedJson = _fixImageUrls(detailsJson);
              final apartment = ApartmentModel.fromJson(fixedJson);
              
              final apartmentUserId = apartment.userId ?? detailsJson['owner_id'] ?? detailsJson['user_id'];
              
              if (apartmentUserId == currentUserId) {
                apartments.add(apartment);
                print('      ✅ Added: ${apartment.title}');
                print('         Main: ${apartment.mainImage.isNotEmpty ? "✅" : "❌"}');
                print('         Images: ${apartment.imageUrls.length}');
              } else {
                print('      ⏭️  Not yours');
              }
            } else {
              print('      ❌ Could not fetch details');
            }
            
          } catch (e) {
            print('      ❌ Error: $e');
          }
        }

        myApartments.addAll(apartments);
        
        print('');
        print('📊 RESULTS:');
        print('   This page: ${apartments.length}');
        print('   Total loaded: ${myApartments.length}');
        print('   More pages: ${hasMorePages ? "Yes" : "No"}');
        print('✅ Done');
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
  // LOAD MORE APARTMENTS
  // ✅ Called when user scrolls to bottom
  // ═══════════════════════════════════════════════════════════

  Future<void> loadMoreApartments() async {
    // Don't load if already loading or no more pages
    if (isLoadingMore.value || !hasMorePages) {
      return;
    }

    try {
      isLoadingMore.value = true;
      currentPage++; // Move to next page

      print('');
      print('📥 LOADING MORE (Page $currentPage)...');

      final token = await _tokenService.getAccessToken();
      if (token == null) return;

      final currentUserId = await _tokenService.getUserId();
      if (currentUserId == null) return;

      final url = '${BaseUrl.pubBaseUrl}/api/owner/apartments?page=$currentPage';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update pagination info
        final paginationInfo = _extractPaginationInfo(data);
        lastPage = paginationInfo['lastPage'] ?? lastPage;
        hasMorePages = currentPage < lastPage;

        List<dynamic> apartmentsJson = _parsePaginatedResponse(data);
        
        print('   Found: ${apartmentsJson.length} apartments');

        final apartments = <ApartmentModel>[];

        for (var json in apartmentsJson) {
          try {
            final apartmentId = json['id'];
            final detailsJson = await _fetchApartmentDetails(apartmentId, token);
            
            if (detailsJson != null) {
              final fixedJson = _fixImageUrls(detailsJson);
              final apartment = ApartmentModel.fromJson(fixedJson);
              
              final apartmentUserId = apartment.userId ?? detailsJson['owner_id'];
              
              if (apartmentUserId == currentUserId) {
                apartments.add(apartment);
              }
            }
          } catch (e) {
            print('   ❌ Error loading apartment: $e');
          }
        }

        myApartments.addAll(apartments);
        
        print('   ✅ Loaded ${apartments.length} more apartments');
        print('   Total: ${myApartments.length}');
        print('   Has more: $hasMorePages');
      }
    } catch (e) {
      print('❌ Error loading more: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // EXTRACT PAGINATION INFO
  // ═══════════════════════════════════════════════════════════
  
  Map<String, int> _extractPaginationInfo(dynamic data) {
    if (data is Map && data.containsKey('data') && data['data'] is Map) {
      final paginatedData = data['data'] as Map<String, dynamic>;
      
      return {
        'currentPage': paginatedData['current_page'] ?? 1,
        'lastPage': paginatedData['last_page'] ?? 1,
        'total': paginatedData['total'] ?? 0,
      };
    }
    
    return {
      'currentPage': 1,
      'lastPage': 1,
      'total': 0,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH APARTMENT DETAILS
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>?> _fetchApartmentDetails(int id, String token) async {
    try {
      final url = '${BaseUrl.pubBaseUrl}/api/apartments/$id';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map) {
          if (data.containsKey('data')) {
            return data['data'] as Map<String, dynamic>;
          } else if (data.containsKey('apartment')) {
            return data['apartment'] as Map<String, dynamic>;
          } else {
            return data as Map<String, dynamic>;
          }
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PARSE PAGINATED RESPONSE
  // ═══════════════════════════════════════════════════════════
  
  List<dynamic> _parsePaginatedResponse(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    }
    
    if (responseData is Map) {
      if (responseData.containsKey('data')) {
        final dataValue = responseData['data'];
        
        if (dataValue is List) {
          return dataValue;
        }
        
        if (dataValue is Map) {
          if (dataValue.containsKey('data') && dataValue['data'] is List) {
            return dataValue['data'] as List;
          }
        }
      }
    }
    
    return [];
  }

  // ═══════════════════════════════════════════════════════════
  // FIX IMAGE URLS
  // ═══════════════════════════════════════════════════════════
  
  Map<String, dynamic> _fixImageUrls(Map<String, dynamic> json) {
    final baseUrl = BaseUrl.pubBaseUrl;
    
    String cleanUrl(String url) {
      if (url.isEmpty || url.startsWith('http')) {
        return url;
      }
      
      String cleaned = url
          .replaceAll('"', '')
          .replaceAll('\\', '/')
          .replaceAll('//', '/')
          .trim();
      
      if (cleaned.startsWith('storage/')) {
        cleaned = cleaned.substring(8);
      }
      
      return '$baseUrl/storage/$cleaned';
    }
    
    // Fix images array
    List<String> fixedImagesList = [];
    
    if (json.containsKey('images')) {
      final images = json['images'];
      
      if (images is String && images.isNotEmpty) {
        try {
          final imagesList = jsonDecode(images) as List;
          fixedImagesList = imagesList
              .map((img) => cleanUrl(img.toString()))
              .where((url) => url.isNotEmpty)
              .toList();
        } catch (e) {
          // Silent
        }
      } else if (images is List) {
        fixedImagesList = images
            .map((img) => cleanUrl(img.toString()))
            .where((url) => url.isNotEmpty)
            .toList();
      }
    }
    
    // Fix main_image
    String? mainImageUrl;
    
    if (json.containsKey('main_image') && json['main_image'] != null) {
      final mainImage = json['main_image'].toString();
      
      if (mainImage.isNotEmpty && mainImage != 'null') {
        mainImageUrl = cleanUrl(mainImage);
      }
    }
    
    // Use first image if main is null
    if (mainImageUrl == null || mainImageUrl.isEmpty) {
      if (fixedImagesList.isNotEmpty) {
        mainImageUrl = fixedImagesList[0];
      } else {
        mainImageUrl = '';
      }
    }
    
    json['main_image'] = mainImageUrl;
    
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
    print('📤 PUBLISHING');
    print('═══════════════════════════════════════════════════════════');

    if (draft == null || draftImages.isEmpty) {
      throw Exception('Missing draft or images');
    }

    try {
      final token = await _tokenService.getAccessToken();

      if (token == null) {
        _showReLoginMessage('No token');
        throw Exception('No token');
      }

      final url = '${BaseUrl.pubBaseUrl}/api/owner/apartments';
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['title'] = draft!.title;
      request.fields['description'] = draft!.description ?? '';
      request.fields['governorate'] = draft!.governorate;
      request.fields['city'] = draft!.city;
      request.fields['address'] = draft!.address ?? '';
      request.fields['price_per_day'] = draft!.pricePerDay.toString();
      request.fields['rooms_count'] = draft!.roomsCount.toString();
      request.fields['apartment_size'] = draft!.apartmentSize.toString();

      print('   Fields: ${request.fields.length}');

      // Add images
      for (var i = 0; i < draftImages.length; i++) {
        final file = File(draftImages[i]);
        
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('images[]', draftImages[i]),
          );
        }
      }

      print('   Images: ${request.files.length} (first is main)');
      print('   Sending...');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('   Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ SUCCESS');
        
        clearDraft();
        Get.back();
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Refresh from first page
        await fetchMyApartments(refresh: true);
        
        Get.snackbar(
          'Success',
          'Apartment published!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22C55E),
          colorText: Colors.white,
        );
      } else {
        print('❌ FAILED: ${response.statusCode}');
        throw Exception('Failed');
      }
    } catch (e) {
      print('❌ ERROR: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════

  Future<bool> deleteApartment(int apartmentId) async {
    try {
      final token = await _tokenService.getAccessToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${BaseUrl.pubBaseUrl}/api/owner/apartments/$apartmentId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        myApartments.removeWhere((apt) => apt.id == apartmentId);
        Get.snackbar('Success', 'Deleted', backgroundColor: Colors.green, colorText: Colors.white);
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
  }

  void cancelDraft() {
    clearDraft();
  }
  
  void _showReLoginMessage(String reason) {
    Get.snackbar(
      'Re-login Required',
      reason,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      mainButton: TextButton(
        onPressed: () {
          box.erase();
          Get.offAllNamed('/');
        },
        child: const Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  void onClose() {
    print('📝 Controller closed');
    super.onClose();
  }
}