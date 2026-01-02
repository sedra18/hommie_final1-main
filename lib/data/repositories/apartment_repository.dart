import 'dart:convert';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/services/token_storage_service.dart';
import 'package:get/get.dart';

// ═══════════════════════════════════════════════════════════
// APARTMENT REPOSITORY - WITH BROWSE ALL APARTMENTS
// ✅ Added browseAllApartments() method for public browsing
// ✅ Handles Laravel paginated response: { data: { data: [...] } }
// ═══════════════════════════════════════════════════════════

class ApartmentRepository {
  static String _baseUrl = '${BaseUrl.pubBaseUrl}/api';
  final _tokenService = Get.put(TokenStorageService());

  // ═══════════════════════════════════════════════════════════
  // BROWSE ALL APARTMENTS (PUBLIC - NO USER FILTER)
  // This method tries multiple endpoints to find one that returns ALL apartments
  // ═══════════════════════════════════════════════════════════
  
  Future<List<ApartmentModel>> browseAllApartments() async {
    try {
      final token = await _tokenService.getAccessToken();
      
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🏠 BROWSING ALL APARTMENTS');
      print('──────────────────────────────────────────────────────────');
      
      // ✅ Try different endpoints to find one that works
      final endpoints = [
        '/apartments/browse',
        '/apartments/all', 
        '/public/apartments',
        '/apartments',  // Try regular endpoint without auth
      ];
      
      for (var endpoint in endpoints) {
        try {
          print('🔍 Trying endpoint: $_baseUrl$endpoint');
          
          final response = await http.get(
            Uri.parse('$_baseUrl$endpoint'),
            headers: {
              'Accept': 'application/json',
              if (token != null && endpoint != '/apartments') 
                'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 5));

          print('   Status: ${response.statusCode}');

          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            
            // Parse apartments
            List<dynamic> apartmentsJson = _parseResponse(responseData);
            
            print('   Found: ${apartmentsJson.length} apartments');
            
            if (apartmentsJson.isNotEmpty) {
              print('✅ SUCCESS! Using endpoint: $endpoint');
              print('═══════════════════════════════════════════════════════════');
              
              final apartments = <ApartmentModel>[];
              
              for (var i = 0; i < apartmentsJson.length; i++) {
                try {
                  final apartment = ApartmentModel.fromJson(apartmentsJson[i]);
                  apartments.add(apartment);
                } catch (e) {
                  print('❌ Error parsing apartment $i: $e');
                }
              }

              print('✅ Successfully loaded ${apartments.length} apartments');
              return apartments;
            }
          }
        } catch (e) {
          print('   ⚠️ Failed: $e');
          continue; // Try next endpoint
        }
      }
      
      print('❌ All endpoints failed or returned empty');
      print('═══════════════════════════════════════════════════════════');
      return [];
      
    } catch (e, stackTrace) {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('❌ EXCEPTION BROWSING APARTMENTS');
      print('   Error: $e');
      print('   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      print('═══════════════════════════════════════════════════════════');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PARSE RESPONSE - Helper method
  // ═══════════════════════════════════════════════════════════
  
  List<dynamic> _parseResponse(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    } else if (responseData is Map) {
      if (responseData.containsKey('data')) {
        final dataValue = responseData['data'];
        
        if (dataValue is List) {
          return dataValue;
        } else if (dataValue is Map && dataValue.containsKey('data')) {
          return dataValue['data'] as List;
        }
      } else if (responseData.containsKey('apartments')) {
        return responseData['apartments'] as List;
      }
    }
    return [];
  }

  // ═══════════════════════════════════════════════════════════
  // GET ALL APARTMENTS (Original - might be filtered by user)
  // Use browseAllApartments() instead for public browsing
  // ═══════════════════════════════════════════════════════════
  
  Future<List<ApartmentModel>> getAllApartments() async {
    try {
      final token = await _tokenService.getAccessToken();
      
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📥 FETCHING APARTMENTS (May be filtered)');
      print('   URL: $_baseUrl/apartments');
      print('   Token: ${token != null ? "${token.substring(0, 20)}..." : "NO TOKEN"}');
      print('═══════════════════════════════════════════════════════════');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/apartments'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        List<dynamic> apartmentsJson = _parseResponse(responseData);

        print('🔢 Processing ${apartmentsJson.length} apartments...');

        final apartments = <ApartmentModel>[];
        
        for (var i = 0; i < apartmentsJson.length; i++) {
          try {
            final apartment = ApartmentModel.fromJson(apartmentsJson[i]);
            apartments.add(apartment);
          } catch (e) {
            print('❌ Error parsing apartment $i: $e');
          }
        }

        print('✅ Successfully loaded ${apartments.length} apartments');
        print('═══════════════════════════════════════════════════════════');
        return apartments;
      } else {
        print('❌ Failed: Status ${response.statusCode}');
        print('Response: ${response.body}');
        print('═══════════════════════════════════════════════════════════');
        return [];
      }
    } catch (e, stackTrace) {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('❌ EXCEPTION FETCHING APARTMENTS');
      print('   Error: $e');
      print('   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      print('═══════════════════════════════════════════════════════════');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GET APARTMENT BY ID
  // Fetch detailed information about a specific apartment
  // ═══════════════════════════════════════════════════════════
  
  Future<ApartmentModel?> getApartmentById(int id) async {
    try {
      final token = await _tokenService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/apartments/$id'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('📡 GET /apartments/$id - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle different response formats
        Map<String, dynamic> apartmentJson;
        
        if (data is Map && data.containsKey('data')) {
          apartmentJson = data['data'] as Map<String, dynamic>;
        } else if (data is Map && data.containsKey('apartment')) {
          apartmentJson = data['apartment'] as Map<String, dynamic>;
        } else if (data is Map) {
          apartmentJson = data as Map<String, dynamic>;
        } else {
          print('⚠️ Unexpected response format');
          return null;
        }

        final apartment = ApartmentModel.fromJson(apartmentJson);
        print('✅ Fetched apartment: ${apartment.title}');
        return apartment;
      } else {
        print('❌ Failed to fetch apartment: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching apartment: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // DELETE APARTMENT
  // Delete an apartment (owner only)
  // ═══════════════════════════════════════════════════════════
  
  Future<bool> deleteApartment(int id) async {
    try {
      final token = await _tokenService.getAccessToken();
      
      if (token == null) {
        print('⚠️ No token found');
        return false;
      }
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/apartments/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 DELETE /apartments/$id - Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Apartment deleted successfully');
        return true;
      } else {
        print('❌ Failed to delete apartment: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting apartment: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CREATE APARTMENT
  // Create a new apartment (owner only)
  // ═══════════════════════════════════════════════════════════
  
  Future<ApartmentModel?> createApartment(Map<String, dynamic> apartmentData) async {
    try {
      final token = await _tokenService.getAccessToken();
      
      if (token == null) {
        print('⚠️ No token found');
        return null;
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/apartments'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(apartmentData),
      );

      print('📡 POST /apartments - Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        Map<String, dynamic> apartmentJson;
        if (data is Map && data.containsKey('data')) {
          apartmentJson = data['data'] as Map<String, dynamic>;
        } else if (data is Map && data.containsKey('apartment')) {
          apartmentJson = data['apartment'] as Map<String, dynamic>;
        } else if (data is Map) {
          apartmentJson = data as Map<String, dynamic>;
        } else {
          print('⚠️ Unexpected response format');
          return null;
        }

        final apartment = ApartmentModel.fromJson(apartmentJson);
        print('✅ Apartment created: ${apartment.title}');
        return apartment;
      } else {
        print('❌ Failed to create apartment: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error creating apartment: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // UPDATE APARTMENT
  // Update an existing apartment (owner only)
  // ═══════════════════════════════════════════════════════════
  
  Future<ApartmentModel?> updateApartment(
    int id,
    Map<String, dynamic> apartmentData,
  ) async {
    try {
      final token = await _tokenService.getAccessToken();
      
      if (token == null) {
        print('⚠️ No token found');
        return null;
      }
      
      final response = await http.put(
        Uri.parse('$_baseUrl/apartments/$id'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(apartmentData),
      );

      print('📡 PUT /apartments/$id - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        Map<String, dynamic> apartmentJson;
        if (data is Map && data.containsKey('data')) {
          apartmentJson = data['data'] as Map<String, dynamic>;
        } else if (data is Map && data.containsKey('apartment')) {
          apartmentJson = data['apartment'] as Map<String, dynamic>;
        } else if (data is Map) {
          apartmentJson = data as Map<String, dynamic>;
        } else {
          print('⚠️ Unexpected response format');
          return null;
        }

        final apartment = ApartmentModel.fromJson(apartmentJson);
        print('✅ Apartment updated: ${apartment.title}');
        return apartment;
      } else {
        print('❌ Failed to update apartment: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error updating apartment: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SEARCH APARTMENTS
  // Search apartments by query
  // ═══════════════════════════════════════════════════════════
  
  Future<List<ApartmentModel>> searchApartments(String query) async {
    try {
      final token = await _tokenService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/apartments/search?q=$query'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('📡 GET /apartments/search?q=$query - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> apartmentsJson = _parseResponse(data);

        final apartments = apartmentsJson
            .map((json) => ApartmentModel.fromJson(json))
            .toList();

        print('✅ Found ${apartments.length} apartments');
        return apartments;
      } else {
        print('❌ Failed to search apartments: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error searching apartments: $e');
      return [];
    }
  }
}