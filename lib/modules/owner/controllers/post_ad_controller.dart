import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════
// POST AD CONTROLLER - FULLY CORRECTED
// Uses ApartmentModel (NOT OwnerApartmentModel)
// ═══════════════════════════════════════════════════════════

class PostAdController extends GetxController {
  // ✅ CORRECTED: Use ApartmentModel (not OwnerApartmentModel)
  final myApartments = <ApartmentModel>[].obs;
  
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  
  final box = GetStorage();
  
  // ═══════════════════════════════════════════════════════════
  // DRAFT DATA (for apartment creation form)
  // ═══════════════════════════════════════════════════════════
  
  final RxMap<String, dynamic> draftData = <String, dynamic>{}.obs;
  
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
  // FETCH MY APARTMENTS
  // ═══════════════════════════════════════════════════════════
  
  Future<void> fetchMyApartments() async {
    if (isLoading.value) {
      print('⚠️  Already loading apartments');
      return;
    }
    
    isLoading.value = true;
    
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📥 FETCHING MY APARTMENTS');
    print('═══════════════════════════════════════════════════════════');
    
    try {
      final token = box.read('access_token');
      
      if (token == null) {
        print('❌ No token found');
        myApartments.clear();
        return;
      }
      
      final url = Uri.parse('${BaseUrl.pubBaseUrl}/owner/apartments');
      print('   URL: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('   Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Handle different response structures
        List<dynamic> apartmentsJson = [];
        
        if (decoded is List) {
          apartmentsJson = decoded;
        } else if (decoded is Map) {
          if (decoded['data'] is List) {
            apartmentsJson = decoded['data'];
          } else if (decoded['data'] is Map && decoded['data']['data'] is List) {
            apartmentsJson = decoded['data']['data'];
          }
        }
        
        // ✅ CORRECTED: Parse as ApartmentModel (not OwnerApartmentModel)
        myApartments.value = apartmentsJson
            .map((json) {
              try {
                return ApartmentModel.fromJson(json);
              } catch (e) {
                print('   ⚠️  Failed to parse apartment: $e');
                return null;
              }
            })
            .whereType<ApartmentModel>()
            .toList();
        
        print('');
        print('✅ APARTMENTS LOADED:');
        print('   My apartments: ${myApartments.length}');
        
        if (myApartments.isNotEmpty) {
          print('   Apartment IDs: ${myApartments.map((a) => a.id).toList()}');
        }
        
        print('═══════════════════════════════════════════════════════════');
        
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed');
        print('═══════════════════════════════════════════════════════════');
        
        myApartments.clear();
        
        Get.snackbar(
          'Authentication Error',
          'Please login again',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        
      } else {
        print('❌ Failed with status ${response.statusCode}');
        print('   Response: ${response.body}');
        print('═══════════════════════════════════════════════════════════');
        
        myApartments.clear();
      }
      
    } catch (e) {
      print('');
      print('❌ ERROR FETCHING APARTMENTS');
      print('   Error: $e');
      print('═══════════════════════════════════════════════════════════');
      
      myApartments.clear();
      
      Get.snackbar(
        'Error',
        'Failed to load apartments',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════
  
  Future<void> refresh() async {
    if (isRefreshing.value) return;
    
    isRefreshing.value = true;
    
    print('');
    print('🔄 REFRESHING MY APARTMENTS...');
    
    try {
      await fetchMyApartments();
      print('✅ Refresh complete');
      
    } catch (e) {
      print('❌ Refresh failed: $e');
    } finally {
      isRefreshing.value = false;
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // DELETE APARTMENT
  // ═══════════════════════════════════════════════════════════
  
  Future<void> deleteApartment(String apartmentId) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🗑️  DELETING APARTMENT: $apartmentId');
    print('═══════════════════════════════════════════════════════════');
    
    try {
      final token = box.read('access_token');
      
      if (token == null) {
        throw Exception('No authentication token');
      }
      
      final url = Uri.parse('${BaseUrl.pubBaseUrl}/owner/apartments/$apartmentId');
      print('   URL: $url');
      
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('   Status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Apartment deleted successfully');
        
        // Remove from list
        myApartments.removeWhere((apt) => apt.id.toString() == apartmentId);
        
        print('   Remaining apartments: ${myApartments.length}');
        print('═══════════════════════════════════════════════════════════');
        
      } else {
        print('❌ Failed with status ${response.statusCode}');
        print('   Response: ${response.body}');
        print('═══════════════════════════════════════════════════════════');
        
        throw Exception('Failed to delete apartment: ${response.statusCode}');
      }
      
    } catch (e) {
      print('');
      print('❌ ERROR DELETING APARTMENT');
      print('   Error: $e');
      print('═══════════════════════════════════════════════════════════');
      
      rethrow;
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // DRAFT MANAGEMENT METHODS
  // ═══════════════════════════════════════════════════════════
  
  /// Save basic apartment info to draft
  void saveDraftBasicInfo({
    required String title,
    required String description,
    required String governorate,
    required String city,
    required String address,
    required double pricePerDay,
    required int roomsCount,
    required double apartmentSize,
  }) {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('💾 SAVING DRAFT BASIC INFO');
    print('──────────────────────────────────────────────────────────');
    print('   Title: $title');
    print('   Description: ${description.length} chars');
    print('   Location: $city, $governorate');
    print('   Price: \$$pricePerDay/day');
    print('   Rooms: $roomsCount');
    print('   Size: $apartmentSize m²');
    print('═══════════════════════════════════════════════════════════');
    
    draftData.value = {
      'title': title,
      'description': description,
      'governorate': governorate,
      'city': city,
      'address': address,
      'pricePerDay': pricePerDay,
      'roomsCount': roomsCount,
      'apartmentSize': apartmentSize,
    };
    
    print('✅ Draft basic info saved');
  }
  
  /// Save apartment images to draft (from file paths)
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
    
    draftData['imagePaths'] = imagePaths;
    
    print('✅ Draft images saved');
  }
  
  /// Publish the draft apartment
  Future<void> publishDraft() async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📤 PUBLISHING DRAFT APARTMENT');
    print('═══════════════════════════════════════════════════════════');
    
    try {
      final token = box.read('access_token');
      
      if (token == null) {
        throw Exception('No authentication token');
      }
      
      // Validate draft data
      if (draftData['title'] == null || draftData['title'].toString().isEmpty) {
        throw Exception('Missing title');
      }
      
      if (draftData['imagePaths'] == null || 
          (draftData['imagePaths'] as List).isEmpty) {
        throw Exception('Missing images');
      }
      
      print('──────────────────────────────────────────────────────────');
      print('📋 DRAFT DATA:');
      print('   Title: ${draftData['title']}');
      print('   Description: ${draftData['description']}');
      print('   Location: ${draftData['city']}, ${draftData['governorate']}');
      print('   Price: \$${draftData['pricePerDay']}/day');
      print('   Images: ${(draftData['imagePaths'] as List).length}');
      print('──────────────────────────────────────────────────────────');
      
      // Create multipart request
      final url = Uri.parse('${BaseUrl.pubBaseUrl}/owner/apartments');
      print('   URL: $url');
      
      var request = http.MultipartRequest('POST', url);
      
      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      
      // Add text fields
      request.fields['title'] = draftData['title'].toString();
      request.fields['description'] = draftData['description'].toString();
      request.fields['governorate'] = draftData['governorate'].toString();
      request.fields['city'] = draftData['city'].toString();
      request.fields['address'] = draftData['address'].toString();
      request.fields['price_per_day'] = draftData['pricePerDay'].toString();
      request.fields['rooms_count'] = draftData['roomsCount'].toString();
      request.fields['apartment_size'] = draftData['apartmentSize'].toString();
      
      // Add images
      final imagePaths = draftData['imagePaths'] as List<String>;
      
      print('📷 Adding images to request...');
      for (var i = 0; i < imagePaths.length; i++) {
        final imagePath = imagePaths[i];
        final file = File(imagePath);
        
        if (await file.exists()) {
          final multipartFile = await http.MultipartFile.fromPath(
            'images[]',  // Use 'images[]' for array of images
            imagePath,
          );
          
          request.files.add(multipartFile);
          print('   ✓ Added image ${i + 1}: ${file.path.split('/').last}');
        } else {
          print('   ⚠️  Image not found: $imagePath');
        }
      }
      
      print('──────────────────────────────────────────────────────────');
      print('📤 Sending request...');
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('   Status: ${response.statusCode}');
      print('   Response: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('');
        print('✅ APARTMENT PUBLISHED SUCCESSFULLY');
        print('═══════════════════════════════════════════════════════════');
        
        // Clear draft
        draftData.clear();
        
        // Reload apartments list
        await fetchMyApartments();
        
      } else {
        print('');
        print('❌ PUBLISH FAILED');
        print('   Status: ${response.statusCode}');
        print('   Response: ${response.body}');
        print('═══════════════════════════════════════════════════════════');
        
        throw Exception('Failed to publish: ${response.statusCode}');
      }
      
    } catch (e) {
      print('');
      print('❌ ERROR PUBLISHING APARTMENT');
      print('   Error: $e');
      print('═══════════════════════════════════════════════════════════');
      
      rethrow;
    }
  }
  
  /// Cancel draft and clear data
  void cancelDraft() {
    print('');
    print('❌ DRAFT CANCELLED');
    print('   Clearing draft data...');
    
    draftData.clear();
    
    print('✅ Draft data cleared');
  }
  
  // ═══════════════════════════════════════════════════════════
  // NAVIGATE TO ADD APARTMENT
  // ═══════════════════════════════════════════════════════════
  
  void onAddApartmentPressed() {
    print('');
    print('➕ Navigate to add apartment form');
    
    // Clear any existing draft
    cancelDraft();
    
    // TODO: Replace with your actual route
    Get.toNamed('/apartment-form');
    
    // OR if using direct navigation:
    // Get.to(() => ApartmentFormScreen());
  }
  
  @override
  void onClose() {
    print('📝 Post Ad Controller closed');
    super.onClose();
  }
}