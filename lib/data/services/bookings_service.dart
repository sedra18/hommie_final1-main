import 'package:get/get.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/data/services/token_storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class BookingService extends GetConnect {
  final TokenStorageService _tokenStorage = Get.find<TokenStorageService>();
  final String baseUrl = 'http://10.0.2.2:8000/api'; // Change to your server

  /// Get pending booking requests for owner
  Future<List<BookingRequestModel>> getPendingRequests() async {
    final token = _tokenStorage.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/owner/booking-requests/pending'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Pending requests response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BookingRequestModel.fromJson(json)).toList();
      } else {
        print('❌ Error: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Exception getting pending requests: $e');
      return [];
    }
  }

  /// Approve a booking request
  Future<bool> approveRequest(int requestId) async {
    final token = _tokenStorage.getAccessToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/owner/booking-requests/$requestId/approve'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('✅ Approve response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error approving request: $e');
      return false;
    }
  }

  /// Reject a booking request
  Future<bool> rejectRequest(int requestId) async {
    final token = _tokenStorage.getAccessToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/owner/booking-requests/$requestId/reject'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('❌ Reject response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error rejecting request: $e');
      return false;
    }
  }

  /// Get all booking requests (with status filter)
  Future<List<BookingRequestModel>> getAllRequests({String? status}) async {
    final token = _tokenStorage.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      String url = '$baseUrl/owner/booking-requests';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BookingRequestModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Exception getting all requests: $e');
      return [];
    }
  }
}