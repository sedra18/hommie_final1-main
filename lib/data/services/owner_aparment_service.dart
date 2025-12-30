import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/data/models/apartment/owner_apartment_model.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;

// ═══════════════════════════════════════════════════════════
// OWNER APARTMENT SERVICE - HANDLES ALL RESPONSE STRUCTURES
// ✅ Supports: Array, {data: []}, {apartments: []}, paginated responses
// ═══════════════════════════════════════════════════════════

class ApartmentApi {
  final box = GetStorage();
  final String baseUrl = '${BaseUrl.pubBaseUrl}/api'; // Uses: http://IP:8000/api

  // ═══════════════════════════════════════════════════════════
  // FETCH ALL APARTMENTS - FIXED FOR ALL STRUCTURES
  // ═══════════════════════════════════════════════════════════

  Future<List<OwnerApartmentModel>> fetchAll() async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📥 FETCHING OWNER APARTMENTS');

    try {
      final token = box.read('access_token');
      if (token == null) {
        print('❌ No token found');
        throw Exception('No authentication token');
      }

      final url = Uri.parse('$baseUrl/owner/apartments');
      print('   URL: $url');
      print('   Token: Present');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('   Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // ✅ HANDLE ALL POSSIBLE RESPONSE STRUCTURES
        List<dynamic> apartmentsJson = [];

        // Case 1: Direct array
        if (responseData is List) {
          print('   Structure: Direct Array');
          apartmentsJson = responseData;
        }
        // Case 2: Object with data
        else if (responseData is Map) {
          print('   Structure: Object');
          print('   Keys: ${responseData.keys.toList()}');

          // Try 'data' key (most common in Laravel)
          if (responseData.containsKey('data')) {
            final dataValue = responseData['data'];

            if (dataValue is List) {
              print('   ✅ Found apartments in "data" key (List)');
              apartmentsJson = dataValue;
            } else if (dataValue is Map && dataValue.containsKey('data')) {
              // Nested pagination: {data: {data: [], links: {}, meta: {}}}
              print('   ✅ Found paginated structure');
              apartmentsJson = dataValue['data'] as List;
            } else if (dataValue == null ||
                (dataValue is Map && dataValue.isEmpty)) {
              print('   ✅ "data" is empty');
              apartmentsJson = [];
            } else {
              print('   ⚠️  "data" is ${dataValue.runtimeType}: $dataValue');
            }
          }
          // Try 'apartments' key
          else if (responseData.containsKey('apartments')) {
            print('   ✅ Found apartments in "apartments" key');
            apartmentsJson = responseData['apartments'] as List;
          }
          // Try 'results' key
          else if (responseData.containsKey('results')) {
            print('   ✅ Found apartments in "results" key');
            apartmentsJson = responseData['results'] as List;
          }
          // Laravel API Resource Collection
          else if (responseData.containsKey('data') == false &&
              responseData.containsKey('current_page')) {
            // Might be pagination at root level
            print('   ⚠️  Root level pagination (no data key)');
          } else {
            print('   ⚠️  Unknown structure');
            print('   Available keys: ${responseData.keys.toList()}');
            print('   Full response: ${jsonEncode(responseData)}');
          }
        }

        print('──────────────────────────────────────────────────────────');
        print('   Found ${apartmentsJson.length} apartments to parse');

        if (apartmentsJson.isEmpty) {
          print('   ℹ️  Empty list returned from backend');
          print('   This means:');
          print('      - Owner has no apartments yet, OR');
          print('      - Backend didn return apartments in expected format');
          print('──────────────────────────────────────────────────────────');
          print('   FULL RESPONSE BODY:');
          print(response.body);
          print('──────────────────────────────────────────────────────────');
        } else {
          print('   First apartment sample:');
          print('   ${jsonEncode(apartmentsJson[0])}');
        }

        // Parse apartments
        final apartments = apartmentsJson
            .map((json) {
              try {
                return OwnerApartmentModel.fromJson(json);
              } catch (e) {
                print('   ⚠️  Failed to parse apartment: $e');
                print('   JSON: ${jsonEncode(json)}');
                return null;
              }
            })
            .whereType<OwnerApartmentModel>()
            .toList();

        print('✅ Successfully parsed ${apartments.length} apartments');
        print('═══════════════════════════════════════════════════════════');

        return apartments;
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed (401)');
        print('   Response: ${response.body}');
        throw Exception('Authentication failed');
      } else {
        print('❌ Failed with status ${response.statusCode}');
        print('   Response: ${response.body}');
        throw Exception('Failed to load apartments: ${response.statusCode}');
      }
    } catch (e, stack) {
      print('❌ Error fetching apartments: $e');
      print('   Stack: $stack');
      print('═══════════════════════════════════════════════════════════');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CREATE APARTMENT
  // ═══════════════════════════════════════════════════════════

  Future<OwnerApartmentModel> create(OwnerApartmentModel apartment) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📤 CREATING APARTMENT');
    print('   Title: ${apartment.title}');

    try {
      final token = box.read('access_token');
      if (token == null) throw Exception('No token');

      final url = Uri.parse('$baseUrl/owner/apartments');

      // Prepare multipart request
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add text fields
      request.fields['title'] = apartment.title;
      request.fields['description'] = apartment.description;
      request.fields['governorate'] = apartment.governorate;
      request.fields['city'] = apartment.city;
      request.fields['address'] = apartment.address;
      request.fields['price_per_day'] = apartment.pricePerDay.toString();
      request.fields['rooms_count'] = apartment.roomsCount.toString();
      request.fields['apartment_size'] = apartment.apartmentSize.toString();

      // Add images
      for (var i = 0; i < apartment.images.length; i++) {
        final imagePath = apartment.images[i];
        request.files.add(
          await http.MultipartFile.fromPath('images[$i]', imagePath),
        );
      }

      // Add main image index
      if (apartment.mainImage != null) {
        final mainIndex = apartment.images.indexOf(apartment.mainImage!);
        if (mainIndex != -1) {
          request.fields['main_image_index'] = mainIndex.toString();
        }
      }

      print('   Sending request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('   Status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle different response structures
        final apartmentData = data is Map && data.containsKey('data')
            ? data['data']
            : data;

        print('✅ Apartment created successfully');
        print('═══════════════════════════════════════════════════════════');

        return OwnerApartmentModel.fromJson(apartmentData);
      } else {
        print('❌ Failed: ${response.statusCode}');
        print('   Response: ${response.body}');
        throw Exception('Failed to create apartment: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
      print('═══════════════════════════════════════════════════════════');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // UPDATE APARTMENT
  // ═══════════════════════════════════════════════════════════

  Future<OwnerApartmentModel> update(OwnerApartmentModel apartment) async {
    print('📤 Updating apartment: ${apartment.id}');

    try {
      final token = box.read('access_token');
      if (token == null) throw Exception('No token');

      final url = Uri.parse('$baseUrl/owner/apartments/${apartment.id}');

      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(apartment.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final apartmentData = data is Map && data.containsKey('data')
            ? data['data']
            : data;
        return OwnerApartmentModel.fromJson(apartmentData);
      } else {
        throw Exception('Failed to update: ${response.body}');
      }
    } catch (e) {
      print('❌ Error updating: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // DELETE APARTMENT
  // ═══════════════════════════════════════════════════════════

  Future<void> delete(String id) async {
    print('🗑️  Deleting apartment: $id');

    try {
      final token = box.read('access_token');
      if (token == null) throw Exception('No token');

      final url = Uri.parse('$baseUrl/owner/apartments/$id');

      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Deleted successfully');
      } else {
        throw Exception('Failed to delete: ${response.body}');
      }
    } catch (e) {
      print('❌ Error deleting: $e');
      rethrow;
    }
  }
}
