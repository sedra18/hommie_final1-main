import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/services/apartments_service.dart';
import 'package:http/http.dart' as http;
import 'package:hommie/helpers/base_url.dart';

// ═══════════════════════════════════════════════════════════
// OWNER HOME CONTROLLER
// Shows owner's apartments + all other apartments
// No userId needed - uses ID comparison
// ═══════════════════════════════════════════════════════════

class OwnerHomeController extends GetxController {
  final myApartments = <ApartmentModel>[].obs;      // My apartments
  final otherApartments = <ApartmentModel>[].obs;   // Others' apartments
  final allApartments = <ApartmentModel>[].obs;     // All apartments combined
  
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  
  final box = GetStorage();
  
  @override
  void onInit() {
    super.onInit();
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🏠 OWNER HOME CONTROLLER - INITIALIZING');
    print('═══════════════════════════════════════════════════════════');
    loadApartments();
  }
  
  // ═══════════════════════════════════════════════════════════
  // LOAD ALL APARTMENTS
  // ═══════════════════════════════════════════════════════════
  
  Future<void> loadApartments() async {
    if (isLoading.value) {
      print('⚠️  Already loading apartments');
      return;
    }
    
    isLoading.value = true;
    
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📥 LOADING APARTMENTS FOR OWNER');
    print('═══════════════════════════════════════════════════════════');
    
    try {
      // Step 1: Get MY apartments (owner endpoint)
      print('📥 Step 1: Fetching MY apartments...');
      await _loadMyApartments();
      
      // Step 2: Get ALL apartments (public endpoint)
      print('📥 Step 2: Fetching ALL apartments...');
      await _loadAllApartments();
      
      // Step 3: Separate my apartments from others
      print('🔄 Step 3: Separating apartments...');
      _separateApartments();
      
      print('');
      print('✅ APARTMENTS LOADED SUCCESSFULLY:');
      print('   My apartments: ${myApartments.length}');
      print('   Other apartments: ${otherApartments.length}');
      print('   Total: ${allApartments.length}');
      print('═══════════════════════════════════════════════════════════');
      
    } catch (e) {
      print('');
      print('❌ ERROR LOADING APARTMENTS');
      print('   Error: $e');
      print('═══════════════════════════════════════════════════════════');
    } finally {
      isLoading.value = false;
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // LOAD MY APARTMENTS (from owner endpoint)
  // ═══════════════════════════════════════════════════════════
  
  Future<void> _loadMyApartments() async {
    try {
      final token = box.read('access_token');
      if (token == null) {
        print('⚠️  No token found - cannot fetch owner apartments');
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
        
        print('   ✅ Loaded ${myApartments.length} of my apartments');
        
        if (myApartments.isNotEmpty) {
          print('   My apartment IDs: ${myApartments.map((a) => a.id).toList()}');
        }
        
      } else if (response.statusCode == 401) {
        print('   ❌ Authentication failed');
        myApartments.clear();
      } else {
        print('   ❌ Failed with status ${response.statusCode}');
        print('   Response: ${response.body}');
        myApartments.clear();
      }
      
    } catch (e) {
      print('   ❌ Error: $e');
      myApartments.clear();
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // LOAD ALL APARTMENTS (from public endpoint)
  // ═══════════════════════════════════════════════════════════
  
  Future<void> _loadAllApartments() async {
    try {
      final apartments = await ApartmentsService.fetchApartments();
      allApartments.value = apartments;
      
      print('   ✅ Loaded ${allApartments.length} total apartments');
      
    } catch (e) {
      print('   ❌ Error: $e');
      allApartments.clear();
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // SEPARATE MY APARTMENTS FROM OTHERS
  // ═══════════════════════════════════════════════════════════
  
  void _separateApartments() {
    // Get IDs of my apartments
    final myIds = myApartments.map((apt) => apt.id).toSet();
    
    print('   My apartment IDs: $myIds');
    
    // Filter: apartments NOT in my IDs = other apartments
    otherApartments.value = allApartments
        .where((apt) => !myIds.contains(apt.id))
        .toList();
    
    print('   ✅ Separated:');
    print('      - My apartments: ${myApartments.length}');
    print('      - Other apartments: ${otherApartments.length}');
  }
  
  // ═══════════════════════════════════════════════════════════
  // CHECK IF APARTMENT IS MINE
  // ═══════════════════════════════════════════════════════════
  
  bool isMyApartment(int apartmentId) {
    final isMine = myApartments.any((apt) => apt.id == apartmentId);
    return isMine;
  }
  
  bool isMyApartmentObj(ApartmentModel apartment) {
    return isMyApartment(apartment.id);
  }
  
  // ═══════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════
  
  Future<void> refresh() async {
    if (isRefreshing.value) return;
    
    isRefreshing.value = true;
    
    print('');
    print('🔄 REFRESHING APARTMENTS...');
    
    try {
      await _loadMyApartments();
      await _loadAllApartments();
      _separateApartments();
      
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
  
  Future<void> deleteApartment(int apartmentId) async {
    print('');
    print('🗑️  Deleting apartment: $apartmentId');
    
    try {
      final token = box.read('access_token');
      if (token == null) {
        throw Exception('No token');
      }
      
      final url = Uri.parse('${BaseUrl.pubBaseUrl}/owner/apartments/$apartmentId');
      
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Apartment deleted successfully');
        
        // Remove from lists
        myApartments.removeWhere((apt) => apt.id == apartmentId);
        allApartments.removeWhere((apt) => apt.id == apartmentId);
        
        Get.snackbar(
          'Deleted',
          'Apartment deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check, color: Colors.white),
        );
        
      } else {
        throw Exception('Failed to delete: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Error deleting: $e');
      
      Get.snackbar(
        'Error',
        'Failed to delete apartment',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }
  
  @override
  void onClose() {
    print('🏠 Owner Home Controller closed');
    super.onClose();
  }
}