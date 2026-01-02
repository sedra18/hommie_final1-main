import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;

// ═══════════════════════════════════════════════════════════
// APARTMENTS SERVICE - COMPLETE
// ✅ Correct URL: /api/apartments/:id
// ✅ getCleanImageUrl() method for fixing image paths
// ✅ Proper error handling
// ═══════════════════════════════════════════════════════════

class ApartmentsService {
  static String baseUrl = BaseUrl.pubBaseUrl;
  static String imageBaseUrl = BaseUrl.pubBaseUrl;
  static final box = GetStorage();

  // ═══════════════════════════════════════════════════════════
  // CLEAN IMAGE URL - FIXES WINDOWS PATHS
  // ✅ Removes C:/Users/... paths
  // ✅ Returns proper storage URL
  // ═══════════════════════════════════════════════════════════
  
  static String getCleanImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return ''; // Return empty for null/empty
    }

    print('🖼️  Cleaning image URL: $imageUrl');

    String cleanUrl = imageUrl;
    
    // ✅ STEP 1: If already a full URL, return as-is
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      print('   ✅ Already full URL');
      return cleanUrl;
    }

  
    if (cleanUrl.contains(':\\') || cleanUrl.contains(':/')) {
      final parts = cleanUrl.split(RegExp(r'[/\\]'));
      cleanUrl = parts.last; // Get just the filename
      print('   🔧 Extracted filename from Windows path: $cleanUrl');
    }
    
    // Remove Unix absolute paths (/var/www/...)
    else if (cleanUrl.startsWith('/')) {
      final parts = cleanUrl.split('/');
      cleanUrl = parts.last;
      print('   🔧 Extracted filename from Unix path: $cleanUrl');
    }
    
    // Remove 'storage/' prefix if present
    if (cleanUrl.startsWith('storage/')) {
      cleanUrl = cleanUrl.replaceFirst('storage/', '');
      print('   🔧 Removed storage/ prefix: $cleanUrl');
    }
    
    // Remove 'apartments/' prefix if present (we'll add it back)
    if (cleanUrl.startsWith('apartments/')) {
      cleanUrl = cleanUrl.replaceFirst('apartments/', '');
      print('   🔧 Removed apartments/ prefix: $cleanUrl');
    }

    // ✅ STEP 3: Build final URL
    final fullUrl = '$baseUrl/storage/apartments/$cleanUrl';
    print('   ✅ Final URL: $fullUrl');
    return fullUrl;
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH APARTMENT DETAILS
  // ✅ Uses /api/apartments/:id
  // ═══════════════════════════════════════════════════════════
  
  static Future<Map<String, dynamic>> fetchApartmentDetails(
    int apartmentId,
  ) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🔍 [SERVICE] Fetching apartment details: $apartmentId');
    
    try {
      // ✅ FIXED: Add /api to the URL
      final url = Uri.parse("$baseUrl/api/apartments/$apartmentId");
      print('   URL: $url');
      
      final token = box.read('access_token');
      
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      print('   Status: ${response.statusCode}');
      print('──────────────────────────────────────────────────────────');

      if (response.statusCode != 200) {
        print('❌ Failed with status: ${response.statusCode}');
        print('   Response: ${response.body}');
        print('═══════════════════════════════════════════════════════════');
        throw Exception("Failed to load apartment details: ${response.statusCode}");
      }

      final decoded = jsonDecode(response.body);
      
      // Handle different response formats
      Map<String, dynamic>? detailsData;
      
      if (decoded is Map) {
        if (decoded.containsKey('data')) {
          detailsData = decoded['data'] as Map<String, dynamic>;
        } else if (decoded.containsKey('apartment')) {
          detailsData = decoded['apartment'] as Map<String, dynamic>;
        } else {
          // Assume the whole response is the apartment data
          detailsData = decoded as Map<String, dynamic>;
        }
      }
      
      if (detailsData == null || detailsData.isEmpty) {
        print('❌ Empty response data');
        print('═══════════════════════════════════════════════════════════');
        throw Exception("Apartment details data is empty");
      }
      
      print('✅ Details loaded for apartment $apartmentId');
      print('   Title: ${detailsData['title']}');
      print('═══════════════════════════════════════════════════════════');
      
      return detailsData;
      
    } catch (e, stackTrace) {
      print('❌ Error fetching details: $e');
      print('   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      print('═══════════════════════════════════════════════════════════');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GET STORAGE URL (alias for getCleanImageUrl)
  // ═══════════════════════════════════════════════════════════
  
  static String getStorageUrl(String? path) {
    return getCleanImageUrl(path);
  }

  // ═══════════════════════════════════════════════════════════
  // GET PLACEHOLDER IMAGE
  // ═══════════════════════════════════════════════════════════
  
  static String getPlaceholderUrl() {
    return 'https://via.placeholder.com/400x300.png?text=No+Image';
  }
}