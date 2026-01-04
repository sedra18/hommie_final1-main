// ═══════════════════════════════════════════════════════════
// BOOKING SERVICE - COMPLETE VERSION
// ✅ All endpoints for renter and owner
// ✅ Uses getAccessToken()
// ✅ Proper error handling
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
  // POST /api/bookings/create
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> createBooking({
    required int apartmentId,
    required String startDate,
    required String endDate,
    required String paymentMethod,
  }) async {
    try {
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
  // GET MY BOOKINGS (FOR RENTER)
  // GET /api/bookings?status={status}
  // ✅ ADDED METHOD
  // ═══════════════════════════════════════════════════════════
  
  Future<List<BookingRequestModel>> getMyBookings({String? status}) async {
    try {
      final token = await _tokenService.getAccessToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📥 FETCHING MY BOOKINGS');
      if (status != null) print('   Status Filter: $status');
      print('──────────────────────────────────────────────────────────');

      // Build URL with optional status filter
      String url = '$baseUrl/bookings';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
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
        
        final bookings = bookingsData
            .map((json) => BookingRequestModel.fromJson(json))
            .toList();
        
        print('✅ Found ${bookings.length} bookings');
        print('═══════════════════════════════════════════════════════════');
        
        return bookings;
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
  // GET OWNER BOOKINGS (FOR OWNER)
  // GET /api/bookings/ownerBookings
  // ✅ ADDED METHOD
  // ═══════════════════════════════════════════════════════════
  
  Future<List<BookingRequestModel>> getOwnerBookings() async {
    try {
      final token = await _tokenService.getAccessToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📥 FETCHING OWNER BOOKINGS');
      print('──────────────────────────────────────────────────────────');

      final response = await http.get(
        Uri.parse('$baseUrl/bookings/ownerBookings'),
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
        
        final bookings = bookingsData
            .map((json) => BookingRequestModel.fromJson(json))
            .toList();
        
        print('✅ Found ${bookings.length} owner bookings');
        print('═══════════════════════════════════════════════════════════');
        
        return bookings;
      } else {
        print('❌ Failed to fetch owner bookings: ${response.statusCode}');
        print('Response: ${response.body}');
        print('═══════════════════════════════════════════════════════════');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching owner bookings: $e');
      print('═══════════════════════════════════════════════════════════');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GET PENDING BOOKINGS (FOR OWNER - LEGACY METHOD)
  // Uses getOwnerBookings and filters by pending
  // ═══════════════════════════════════════════════════════════
  
  Future<List<BookingRequestModel>> getPendingBookings() async {
    try {
      final allBookings = await getOwnerBookings();
      
      final pendingBookings = allBookings
          .where((booking) => booking.status?.toLowerCase() == 'pending')
          .toList();
      
      print('✅ Filtered ${pendingBookings.length} pending bookings');
      
      return pendingBookings;
    } catch (e) {
      print('❌ Error getting pending bookings: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // APPROVE BOOKING
  // POST /api/bookings/{id}/approve
  // ═══════════════════════════════════════════════════════════
  
  Future<bool> approveBooking(int bookingId) async {
    try {
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
  // POST /api/bookings/{id}/reject
  // ═══════════════════════════════════════════════════════════
  
  Future<bool> rejectBooking(int bookingId) async {
    try {
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
  // CANCEL BOOKING (FOR RENTER)
  // POST /api/bookings/{id}/cancel
  // ═══════════════════════════════════════════════════════════
  
  Future<bool> cancelBooking(int bookingId) async {
    try {
      final token = await _tokenService.getAccessToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🚫 CANCELLING BOOKING');
      print('   Booking ID: $bookingId');
      print('──────────────────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$bookingId/cancel'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final success = response.statusCode == 200;
      
      if (success) {
        print('✅ Booking cancelled successfully');
      } else {
        print('❌ Failed to cancel booking');
      }
      print('═══════════════════════════════════════════════════════════');
      
      return success;
    } catch (e) {
      print('❌ Error cancelling booking: $e');
      print('═══════════════════════════════════════════════════════════');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // LEGACY METHODS (For backward compatibility)
  // ═══════════════════════════════════════════════════════════
  
  /// Alias for getMyBookings (for renter)
  Future<List<BookingRequestModel>> getUserBookings() async {
    return getMyBookings();
  }
}