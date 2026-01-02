// ═══════════════════════════════════════════════════════════
// CORRECTED BOOKING SERVICE
// File: lib/data/services/bookings_service.dart
// ✅ Uses getAccessToken() instead of getToken()
// ✅ Uses BookingRequestModel (correct model name)
// ✅ Handles nullable status properly
// ═══════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:get/get.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:hommie/data/services/token_storage_service.dart';

class BookingService extends GetxService {
  static String baseUrl = '${BaseUrl.pubBaseUrl}/api';
  
  final TokenStorageService _tokenService = Get.find<TokenStorageService>();

  // ═══════════════════════════════════════════════════════════
  // CREATE BOOKING REQUEST
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> createBooking({
    required int apartmentId,
    required String startDate,
    required String endDate,
    required String paymentMethod,
  }) async {
    try {
      // ✅ FIXED: Use getAccessToken() instead of getToken()
      final token = await _tokenService.getAccessToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📤 CREATING BOOKING REQUEST');
      print('   Apartment ID: $apartmentId');
      print('   Start Date: $startDate');
      print('   End Date: $endDate');
      print('   Payment: $paymentMethod');
      print('──────────────────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/create'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'apartment_id': apartmentId,
          'start_date': startDate,
          'end_date': endDate,
          'payment_method': paymentMethod,
        }),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Booking created successfully');
        print('═══════════════════════════════════════════════════════════');
        return {
          'success': true,
          'data': data,
          'message': 'Booking request sent successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        print('❌ Booking failed: ${error['message']}');
        print('═══════════════════════════════════════════════════════════');
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to create booking',
        };
      }
    } catch (e) {
      print('❌ Error creating booking: $e');
      print('═══════════════════════════════════════════════════════════');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GET ALL BOOKINGS (FOR OWNER - PENDING REQUESTS)
  // ═══════════════════════════════════════════════════════════
  
  Future<List<BookingRequestModel>> getPendingBookings() async {
    try {
      // ✅ FIXED: Use getAccessToken() instead of getToken()
      final token = await _tokenService.getAccessToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📥 FETCHING PENDING BOOKINGS');
      print('──────────────────────────────────────────────────────────');

      final response = await http.get(
        Uri.parse('$baseUrl/bookings'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle different possible response structures
        List<dynamic> bookingsData = [];
        if (data is Map) {
          bookingsData = data['data'] as List? ?? 
                        data['bookings'] as List? ?? 
                        [];
        } else if (data is List) {
          bookingsData = data;
        }
        
        print('Total bookings received: ${bookingsData.length}');
        
        // ✅ FIXED: Parse to BookingRequestModel and handle nullable status
        final allBookings = bookingsData
            .map((json) => BookingRequestModel.fromJson(json))
            .toList();
        
        // ✅ FIXED: Safely filter by status with null check
        final pendingBookings = allBookings
            .where((booking) => booking.status?.toLowerCase() == 'pending')
            .toList();
        
        print('✅ Found ${pendingBookings.length} pending bookings');
        print('═══════════════════════════════════════════════════════════');
        
        return pendingBookings;
      } else {
        print('❌ Failed to fetch bookings: ${response.statusCode}');
        print('Response: ${response.body}');
        print('═══════════════════════════════════════════════════════════');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching bookings: $e');
      print('═══════════════════════════════════════════════════════════');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // APPROVE BOOKING
  // ═══════════════════════════════════════════════════════════
  
  Future<bool> approveBooking(int bookingId) async {
    try {
      // ✅ FIXED: Use getAccessToken() instead of getToken()
      final token = await _tokenService.getAccessToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('✅ APPROVING BOOKING');
      print('   Booking ID: $bookingId');
      print('──────────────────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$bookingId/approve'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final success = response.statusCode == 200;
      
      if (success) {
        print('✅ Booking approved successfully');
      } else {
        print('❌ Failed to approve booking');
      }
      print('═══════════════════════════════════════════════════════════');
      
      return success;
    } catch (e) {
      print('❌ Error approving booking: $e');
      print('═══════════════════════════════════════════════════════════');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // REJECT BOOKING
  // ═══════════════════════════════════════════════════════════
  
  Future<bool> rejectBooking(int bookingId) async {
    try {
      // ✅ FIXED: Use getAccessToken() instead of getToken()
      final token = await _tokenService.getAccessToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('❌ REJECTING BOOKING');
      print('   Booking ID: $bookingId');
      print('──────────────────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$bookingId/reject'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final success = response.statusCode == 200;
      
      if (success) {
        print('✅ Booking rejected successfully');
      } else {
        print('❌ Failed to reject booking');
      }
      print('═══════════════════════════════════════════════════════════');
      
      return success;
    } catch (e) {
      print('❌ Error rejecting booking: $e');
      print('═══════════════════════════════════════════════════════════');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GET USER'S BOOKINGS (FOR RENTER)
  // Optional: Get bookings created by the current user
  // ═══════════════════════════════════════════════════════════
  
  Future<List<BookingRequestModel>> getUserBookings() async {
    try {
      final token = await _tokenService.getAccessToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('📥 Fetching user bookings...');

      final response = await http.get(
        Uri.parse('$baseUrl/bookings'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> bookingsData = [];
        if (data is Map) {
          bookingsData = data['data'] as List? ?? 
                        data['bookings'] as List? ?? 
                        [];
        } else if (data is List) {
          bookingsData = data;
        }
        
        final bookings = bookingsData
            .map((json) => BookingRequestModel.fromJson(json))
            .toList();
        
        print('✅ Found ${bookings.length} user bookings');
        return bookings;
      } else {
        print('❌ Failed to fetch user bookings: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching user bookings: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CANCEL BOOKING (FOR RENTER)
  // Optional: Allow users to cancel their own bookings
  // ═══════════════════════════════════════════════════════════
  
  Future<bool> cancelBooking(int bookingId) async {
    try {
      final token = await _tokenService.getAccessToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('🚫 Cancelling booking $bookingId...');

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$bookingId/cancel'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final success = response.statusCode == 200;
      
      if (success) {
        print('✅ Booking cancelled successfully');
      } else {
        print('❌ Failed to cancel booking');
      }
      
      return success;
    } catch (e) {
      print('❌ Error cancelling booking: $e');
      return false;
    }
  }
}