import 'dart:convert';
import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/owner_apartment_model.dart';
import 'package:hommie/data/services/token_storage_service.dart';
import 'package:hommie/helpers/base_url.dart';


import 'package:http/http.dart' as http;

class ApartmentApi {
  final List<OwnerApartmentModel> _db = [];
  final baseUrl = '${BaseUrl.pubBaseUrl}/api/owner';
  final apartmentEndpoint = '/apartments';
  final TokenStorageService _storage = Get.find<TokenStorageService>();

  Future<List<OwnerApartmentModel>> fetchAll() async {
    final token = _storage.getAccessToken();
    
    if (token == null) {
      print('Warning: No authentication token found');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apartmentEndpoint'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => OwnerApartmentModel.fromJson(json)).toList();
      } else {
        print('Failed to fetch apartments: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching apartments: $e');
      return [];
    }
  }

  Future<void> create(OwnerApartmentModel apt) async {
    final token = _storage.getAccessToken();
    
    if (token == null) {
      throw Exception('Authorization token not found. Please login first.');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apartmentEndpoint'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(apt.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Apartment created successfully!");
      } else {
        print("Failed to create apartment: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception('Failed to create apartment: ${response.body}');
      }
    } catch (e) {
      print('Error creating apartment: $e');
      rethrow;
    }
  }

  Future<void> update(OwnerApartmentModel apt) async {
    final token = _storage.getAccessToken();
    
    if (token == null) {
      throw Exception('Authorization token not found. Please login first.');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl$apartmentEndpoint/${apt.id}'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(apt.toJson()),
      );

      if (response.statusCode == 200) {
        print("Apartment updated successfully!");
      } else {
        print("Failed to update apartment: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception('Failed to update apartment: ${response.body}');
      }
    } catch (e) {
      print('Error updating apartment: $e');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    final token = _storage.getAccessToken();
    
    if (token == null) {
      throw Exception('Authorization token not found. Please login first.');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$apartmentEndpoint/$id'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("Apartment deleted successfully!");
      } else {
        print("Failed to delete apartment: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception('Failed to delete apartment: ${response.body}');
      }
    } catch (e) {
      print('Error deleting apartment: $e');
      rethrow;
    }
  }

  bool get isAuthenticated => _storage.getAccessToken() != null;
}