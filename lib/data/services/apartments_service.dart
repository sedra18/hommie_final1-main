import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;

// ═══════════════════════════════════════════════════════════
// APARTMENTS SERVICE - FIXED
// Removed isMyApartment and fetchCategorizedApartments
// These should be in controller, not service
// ═══════════════════════════════════════════════════════════

class ApartmentsService {
  static String baseUrl = BaseUrl.pubBaseUrl;  // ✅ Use BaseUrl.baseUrl (includes /api)
  static String imageBaseUrl = BaseUrl.pubBaseUrl;
  static final box = GetStorage();

  // ═══════════════════════════════════════════════════════════
  // GET CLEAN IMAGE URL
  // ═══════════════════════════════════════════════════════════
  
  static String getCleanImageUrl(String serverImagePath) {
    if (serverImagePath.isEmpty) {
      return "";
    }
    
    String pathWithForwardSlashes = serverImagePath.replaceAll('\\', '/');
    String fileName = pathWithForwardSlashes.split('/').last;
    String cleanPath = 'storage/apartments/$fileName';
    
    if (serverImagePath.startsWith('http') ||
        serverImagePath.startsWith('https')) {
      return serverImagePath;
    }

    return '$imageBaseUrl/$cleanPath';
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH ALL APARTMENTS (Public endpoint)
  // ═══════════════════════════════════════════════════════════
  
  static Future<List<ApartmentModel>> fetchApartments() async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🏠 FETCHING ALL APARTMENTS');
    
    try {
      final url = Uri.parse("$baseUrl/apartments");  // ✅ Fixed: added /
      print('   URL: $url');
      
      final response = await http.get(url);
      print('   Status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception("Failed to load apartments: ${response.statusCode}");
      }
      
      final decoded = jsonDecode(response.body);
      final paginatedData = decoded["data"];
      final List apartmentsList = paginatedData?["data"] ?? [];
      
      print('   Found ${apartmentsList.length} apartments');
      
      final apartments = apartmentsList
          .map((e) {
            try {
              return ApartmentModel.fromJson(e);
            } catch (err) {
              print('   ⚠️  Failed to parse apartment: $err');
              return null;
            }
          })
          .whereType<ApartmentModel>()
          .toList();
      
      print('✅ Successfully parsed ${apartments.length} apartments');
      print('═══════════════════════════════════════════════════════════');
      
      return apartments;
      
    } catch (e) {
      print('❌ Error fetching apartments: $e');
      print('═══════════════════════════════════════════════════════════');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH APARTMENT DETAILS
  // ═══════════════════════════════════════════════════════════
  
  static Future<Map<String, dynamic>> fetchApartmentDetails(
    int apartmentId,
  ) async {
    print('🔍 Fetching apartment details: $apartmentId');
    
    try {
      final url = Uri.parse("$baseUrl/apartments/$apartmentId");
      print('   URL: $url');
      
      final response = await http.get(url);
      print('   Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception("Failed to load apartment details: ${response.statusCode}");
      }

      final decoded = jsonDecode(response.body);
      final detailsData = decoded["data"];
      
      if (detailsData == null) {
        throw Exception("Apartment details data is empty");
      }
      
      print('✅ Details loaded for apartment $apartmentId');
      return detailsData;
      
    } catch (e) {
      print('❌ Error fetching details: $e');
      rethrow;
    }
  }
}