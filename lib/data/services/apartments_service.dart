import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;

// ═══════════════════════════════════════════════════════════
// APARTMENTS SERVICE - FIXED TO FETCH FULL DETAILS
// ✅ Fetches list first, then gets full details with images
// ✅ Properly constructs image URLs
// ═══════════════════════════════════════════════════════════

class ApartmentsService {
  static String baseUrl = BaseUrl.pubBaseUrl; 
  static String imageBaseUrl = BaseUrl.pubBaseUrl;
  static final box = GetStorage();

  // ═══════════════════════════════════════════════════════════
  // CLEAN IMAGE URL
  // ═══════════════════════════════════════════════════════════
  
  static String getCleanImageUrl(String serverImagePath) {
  if (serverImagePath.isEmpty || serverImagePath == 'null') {
    return "";
  }

  try {
    // Convert to string and clean
    String path = serverImagePath.toString()
        .replaceAll('"', '')
        .replaceAll('\\', '/')
        .replaceAll('//', '/')
        .trim();

    // If already a full URL, return as-is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Remove 'storage/' prefix if present
    if (path.startsWith('storage/')) {
      path = path.substring(8);
    }

    // Ensure proper format
    if (!path.startsWith('apartments/')) {
      path = 'apartments/$path';
    }

    // Build full URL
    return '$imageBaseUrl/storage/$path';
  } catch (e) {
    print('❌ Error cleaning image URL: $e');
    return "";
  }
}

  // ═══════════════════════════════════════════════════════════
  // FETCH APARTMENTS - WITH FULL DETAILS
  // ✅ Gets list first, then fetches full details for each
  // ═══════════════════════════════════════════════════════════
  
  static Future<List<ApartmentModel>> fetchApartments() async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🏠 FETCHING ALL APARTMENTS');
    
    try {
      // Step 1: Get list of apartments
      final url = Uri.parse("$baseUrl/api/apartments");
      print('   📋 Fetching list: $url');
      
      final response = await http.get(url);
      print('   Status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception("Failed to load apartments: ${response.statusCode}");
      }
      
      final decoded = jsonDecode(response.body);
      final paginatedData = decoded["data"];
      final List apartmentsList = paginatedData?["data"] ?? [];
      
      print('   Found ${apartmentsList.length} apartments in list');
      
      // Step 2: Fetch full details for each apartment
      final apartments = <ApartmentModel>[];
      
      for (var i = 0; i < apartmentsList.length; i++) {
        try {
          final apartmentId = apartmentsList[i]['id'];
          print('');
          print('   📦 Fetching details for apartment #$apartmentId...');
          
          // ✅ Fetch full details to get images
          final details = await fetchApartmentDetails(apartmentId);
          
          if (details != null) {
            // Fix image URLs
            final fixedDetails = _fixImageUrls(details);
            
            final apartment = ApartmentModel.fromJson(fixedDetails);
            apartments.add(apartment);
            
            print('      ✅ Added: ${apartment.title}');
            print('         Main: ${apartment.mainImage.isNotEmpty ? "✅" : "❌"}');
          } else {
            print('      ⚠️  Could not fetch details, using list data');
            // Fallback to list data (no images)
            final apartment = ApartmentModel.fromJson(apartmentsList[i]);
            apartments.add(apartment);
          }
          
        } catch (err) {
          print('      ❌ Error: $err');
        }
      }
      
      print('');
      print('✅ Successfully loaded ${apartments.length} apartments');
      print('═══════════════════════════════════════════════════════════');
      
      return apartments;
      
    } catch (e) {
      print('❌ Error fetching apartments: $e');
      print('═══════════════════════════════════════════════════════════');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH APARTMENT DETAILS - Gets full data with images
  // ═══════════════════════════════════════════════════════════
  
  static Future<Map<String, dynamic>?> fetchApartmentDetails(
    int apartmentId,
  ) async {
    try {
      final url = Uri.parse("$baseUrl/api/apartments/$apartmentId");
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Handle different response formats
        if (decoded is Map) {
          if (decoded.containsKey('data')) {
            return decoded['data'] as Map<String, dynamic>;
          } else if (decoded.containsKey('apartment')) {
            return decoded['apartment'] as Map<String, dynamic>;
          } else {
            return decoded as Map<String, dynamic>;
          }
        }
      }
      
      return null;
    } catch (e) {
      print('         ❌ Details fetch error: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FIX IMAGE URLS IN JSON
  // ═══════════════════════════════════════════════════════════
  
  static Map<String, dynamic> _fixImageUrls(Map<String, dynamic> json) {
    // Fix images array
    List<String> fixedImagesList = [];
    
    if (json.containsKey('images')) {
      final images = json['images'];
      
      if (images is String && images.isNotEmpty) {
        try {
          final imagesList = jsonDecode(images) as List;
          fixedImagesList = imagesList
              .map((img) => getCleanImageUrl(img.toString()))
              .where((url) => url.isNotEmpty)
              .toList();
        } catch (e) {
          // Silent
        }
      } else if (images is List) {
        fixedImagesList = images
            .map((img) => getCleanImageUrl(img.toString()))
            .where((url) => url.isNotEmpty)
            .toList();
      }
    }
    
    // Fix main_image
    String? mainImageUrl;
    
    if (json.containsKey('main_image') && json['main_image'] != null) {
      final mainImage = json['main_image'].toString();
      
      if (mainImage.isNotEmpty && mainImage != 'null') {
        mainImageUrl = getCleanImageUrl(mainImage);
      }
    }
    
    // ✅ Use first image if main is null
    if (mainImageUrl == null || mainImageUrl.isEmpty) {
      if (fixedImagesList.isNotEmpty) {
        mainImageUrl = fixedImagesList[0];
        print('         🔧 Fixed null main_image → using first image');
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
}