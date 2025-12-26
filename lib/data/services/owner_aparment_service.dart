import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/data/models/apartment/owner_apartment_model.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ═══════════════════════════════════════════════════════════
// APARTMENT API - DEBUG VERSION
// Prints FULL response to understand structure
// ═══════════════════════════════════════════════════════════

class ApartmentApi {
  final box = GetStorage();
  final String baseUrl = '${BaseUrl.pubBaseUrl}/api';

  // ═══════════════════════════════════════════════════════════
  // FETCH ALL - WITH FULL DEBUG LOGGING
  // ═══════════════════════════════════════════════════════════
  Future<List<OwnerApartmentModel>> fetchAll() async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📥 FETCHING OWNER APARTMENTS (DEBUG MODE)');
    
    try {
      final token = box.read('access_token');
      if (token == null) {
        print('⚠️  No token');
        return [];
      }

      final url = Uri.parse('$baseUrl/owner/apartments');
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
        // ✅ PRINT FULL RESPONSE BODY
        print('');
        print('📄 FULL RESPONSE BODY:');
        print('─────────────────────────────────────────────────────────');
        print(response.body);
        print('─────────────────────────────────────────────────────────');
        
        final dynamic responseBody = jsonDecode(response.body);
        
        print('');
        print('🔍 RESPONSE ANALYSIS:');
        print('   Type: ${responseBody.runtimeType}');
        print('   Is List: ${responseBody is List}');
        print('   Is Map: ${responseBody is Map}');
        
        if (responseBody is Map) {
          print('   Keys: ${(responseBody as Map).keys.join(', ')}');
          
          // Check each key
          (responseBody as Map).forEach((key, value) {
            print('   [$key] type: ${value.runtimeType}');
            if (value is List) {
              print('      └─ Array with ${value.length} items');
            } else if (value is Map) {
              print('      └─ Object with keys: ${(value as Map).keys.join(', ')}');
            }
          });
        }
        
        print('');
        print('💡 ATTEMPTING TO PARSE...');
        print('─────────────────────────────────────────────────────────');
        
        List<dynamic> apartmentsData = [];
        
        if (responseBody is List) {
          print('✅ Direct array format');
          apartmentsData = responseBody;
        } else if (responseBody is Map) {
          print('✅ Wrapped object format');
          
          // Try different possible keys
          if (responseBody.containsKey('data')) {
            final dataValue = responseBody['data'];
            print('   Found "data" key');
            print('   data type: ${dataValue.runtimeType}');
            
            if (dataValue is List) {
              print('   ✅ data is Array!');
              apartmentsData = dataValue;
            } else if (dataValue is Map) {
              print('   ⚠️  data is Object, checking nested keys...');
              
              // Maybe data contains apartments array?
              if ((dataValue as Map).containsKey('apartments')) {
                print('   Found nested "apartments" key');
                apartmentsData = dataValue['apartments'] as List;
              } else if (dataValue.containsKey('data')) {
                print('   Found nested "data" key');
                apartmentsData = dataValue['data'] as List;
              } else {
                print('   ❌ No apartments array found in nested object');
                print('   Nested keys: ${dataValue.keys.join(', ')}');
              }
            }
          } else if (responseBody.containsKey('apartments')) {
            print('   Found "apartments" key');
            apartmentsData = responseBody['apartments'] as List;
          } else {
            print('   ❌ No known key found');
            print('   Available keys: ${responseBody.keys.join(', ')}');
          }
        }
        
        print('');
        print('📊 PARSING RESULTS:');
        print('   Items to parse: ${apartmentsData.length}');
        print('─────────────────────────────────────────────────────────');
        
        if (apartmentsData.isEmpty) {
          print('⚠️  WARNING: No apartments data found!');
          print('═══════════════════════════════════════════════════════════');
          return [];
        }
        
        // Parse apartments
        final apartments = apartmentsData
            .map((json) {
              try {
                final apt = OwnerApartmentModel.fromJson(json as Map<String, dynamic>);
                print('   ✅ Parsed: ${apt.title} (\$${apt.pricePerDay}/day)');
                return apt;
              } catch (e) {
                print('   ❌ Failed to parse item: $e');
                print('      Item: $json');
                return null;
              }
            })
            .whereType<OwnerApartmentModel>()
            .toList();
        
        print('');
        print('✅ FETCH COMPLETE');
        print('   Successfully parsed: ${apartments.length} apartments');
        print('═══════════════════════════════════════════════════════════');
        
        return apartments;
        
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('   Body: ${response.body}');
        print('═══════════════════════════════════════════════════════════');
        return [];
      }
    } catch (e, stackTrace) {
      print('');
      print('❌ EXCEPTION:');
      print('   Error: $e');
      print('   Stack:');
      stackTrace.toString().split('\n').take(5).forEach((line) {
        print('      $line');
      });
      print('═══════════════════════════════════════════════════════════');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CREATE (keep existing)
  // ═══════════════════════════════════════════════════════════
  Future<void> create(OwnerApartmentModel apartment) async {
    print('📤 Creating apartment: ${apartment.title}');
    
    try {
      final token = box.read('access_token');
      if (token == null) throw Exception('No token');

      final url = Uri.parse('$baseUrl/owner/apartments');
      var request = http.MultipartRequest('POST', url);
      
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['title'] = apartment.title;
      request.fields['description'] = apartment.description;
      request.fields['governorate'] = apartment.governorate;
      request.fields['city'] = apartment.city;
      request.fields['address'] = apartment.address;
      request.fields['price_per_day'] = apartment.pricePerDay.toInt().toString();
      request.fields['rooms_count'] = apartment.roomsCount.toString();
      request.fields['apartment_size'] = apartment.apartmentSize.toInt().toString();

      for (int i = 0; i < apartment.images.length; i++) {
        final file = File(apartment.images[i]);
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath('images[]', file.path));
        }
      }

      if (apartment.mainImage != null) {
        final mainFile = File(apartment.mainImage!);
        if (await mainFile.exists()) {
          request.files.add(await http.MultipartFile.fromPath('main_image', mainFile.path));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Created successfully');
      } else {
        throw Exception('Create failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Create error: $e');
      rethrow;
    }
  }

  Future<void> update(OwnerApartmentModel apartment) async {
    // Keep existing implementation
    throw UnimplementedError();
  }

  Future<void> delete(String id) async {
    // Keep existing implementation
    throw UnimplementedError();
  }
}