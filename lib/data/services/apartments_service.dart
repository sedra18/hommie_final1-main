import 'dart:convert';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;

class ApartmentsService {
  static  String baseUrl = "${BaseUrl.pubBaseUrl}/api/";
  static  String imageBaseUrl = "${BaseUrl.pubBaseUrl}";

  static String getCleanImageUrl(String serverImagePath) {
    if (serverImagePath.isEmpty) {
      return "";
    }
    String pathWithForwardSlashes = serverImagePath.replaceAll('\\', '/');
    String fileName = pathWithForwardSlashes.split('/').last;
    String cleanPath = 'storage/apartments/$fileName';
    if (serverImagePath.startsWith('http') ||
        serverImagePath.startsWith('https')) {
      return imageBaseUrl + cleanPath;
    }

    return imageBaseUrl + cleanPath;
  }

  static Future<List<ApartmentModel>> fetchApartments() async {
    final url = Uri.parse("${baseUrl}apartments");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception("Failed to load apartments");
    }
    final decoded = jsonDecode(response.body);
    final paginatedData = decoded["data"];
    final List apartmentsList = paginatedData?["data"] ?? [];
    return apartmentsList.map((e) => ApartmentModel.fromJson(e)).toList();
  }

  static Future<Map<String, dynamic>> fetchApartmentDetails(
    int apartmentId,
  ) async {
    final url = Uri.parse("${baseUrl}apartments/$apartmentId");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to load apartment details for ID $apartmentId");
    }

    final decoded = jsonDecode(response.body);
    final detailsData = decoded["data"];
    if (detailsData == null) {
      throw Exception("Apartment details data is empty");
    }
    return detailsData;
  }
}
