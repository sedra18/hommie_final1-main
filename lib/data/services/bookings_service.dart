import 'dart:convert';
import 'package:get/get.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:hommie/data/services/token_storage_service.dart';
import 'package:http/http.dart' as http;

class BookingService extends GetxService {
  final String baseUrl = '${BaseUrl.pubBaseUrl}/api';
  final TokenStorageService _tokenService = Get.find<TokenStorageService>();

  // ═══════════════════════════════════════════════════════════
  // GET MY BOOKINGS - UNIFIED FOR BOTH OWNER AND RENTER
  // ✅ Backend determines if you're owner or renter based on token
  // ✅ API: GET /api/bookings?status=past (optional)
  // 
  // How it works:
  // - For OWNER (token belongs to owner user):
  //   Backend returns: All bookings for apartments owned by this user
  //   
  // - For RENTER (token belongs to renter user):
  //   Backend returns: All bookings made by this user
  // 
  // Status values from backend (same for both):
  //   - "pending_owner_approval" - waiting for owner to approve
  //   - "approved" - owner approved the booking
  //   - "rejected" - owner rejected the booking
  //   - "completed" - booking is finished
  //   - "cancelled" - booking was cancelled
  // ═══════════════════════════════════════════════════════════

  Future<List<BookingRequestModel>> getMyBookings({String? status}) async {
    try {
      final token = await _tokenService.getAccessToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      String url = '$baseUrl/bookings';
      if (status != null && status.isNotEmpty) {
        url += '?status=$status';
      }

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📥 FETCHING MY BOOKINGS (Owner or Renter based on token)');
      print('   Endpoint: $url');
      print('──────────────────────────────────────────────────────────');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        final bookingsArray = _extractBookingsArray(decodedBody);

        print('✅ Found ${bookingsArray.length} bookings');

        // ✅ DO NOT map status - preserve original from backend
        // Backend sends correct status for both owner and renter
        final bookings = bookingsArray
            .map((json) => BookingRequestModel.fromJson(json as Map<String, dynamic>))
            .toList();

        _printStatusBreakdown(bookings);
        print('═══════════════════════════════════════════════════════════');

        return bookings;
      } else {
        print('❌ Failed to fetch bookings: ${response.statusCode}');
        print('Response: ${response.body}');
        print('═══════════════════════════════════════════════════════════');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching bookings: $e');
      print('Stack trace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      print('═══════════════════════════════════════════════════════════');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ALIASES FOR COMPATIBILITY
  // ═══════════════════════════════════════════════════════════
  
  /// Alias for getMyBookings() - kept for backward compatibility
  Future<List<BookingRequestModel>> getUserBookings({String? status}) async {
    return getMyBookings(status: status);
  }

  /// Deprecated: Use getMyBookings() instead
  /// Backend now handles owner/renter logic based on token
  @Deprecated('Use getMyBookings() instead - it works for both owner and renter')
  Future<List<BookingRequestModel>> getOwnerBookings() async {
    print('⚠️  getOwnerBookings() is deprecated. Using getMyBookings() instead.');
    return getMyBookings();
  }

  // ═══════════════════════════════════════════════════════════
  // CREATE BOOKING
  // ✅ API: POST /api/bookings/create
  // ✅ Returns Map<String, dynamic> with success/error
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
        return {'success': false, 'error': 'No authentication token found'};
      }

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📝 CREATING BOOKING');
      print('   Endpoint: $baseUrl/bookings/create');
      print('   Apartment ID: $apartmentId');
      print('   Dates: $startDate → $endDate');
      print('   Payment: $paymentMethod');
      print('──────────────────────────────────────────────────────────');

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/create'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'apartment_id': apartmentId,
          'start_date': startDate,
          'end_date': endDate,
          'payment_method': paymentMethod,
        }),
      );

      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Booking created successfully');
        print('═══════════════════════════════════════════════════════════');

        return {'success': true, 'data': json.decode(response.body)};
      } else {
        print('❌ Failed to create booking');
        print('Response: ${response.body}');
        print('═══════════════════════════════════════════════════════════');

        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['message'] ?? 'Failed to create booking',
          };
        } catch (_) {
          return {'success': false, 'error': 'Failed to create booking'};
        }
      }
    } catch (e) {
      print('❌ Error creating booking: $e');
      print('═══════════════════════════════════════════════════════════');

      return {'success': false, 'error': 'An error occurred: ${e.toString()}'};
    }
  }

  // ═══════════════════════════════════════════════════════════
  // APPROVE BOOKING
  // ✅ API: POST /api/bookings/{id}/approve
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
      print('   Endpoint: $baseUrl/bookings/$bookingId/approve');
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
      final success = response.statusCode == 200;

      if (success) {
        print('✅ Booking approved successfully');
      } else {
        print('❌ Failed to approve booking');
        print('Response: ${response.body}');
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
  // ✅ API: POST /api/bookings/{id}/reject
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
      print('   Endpoint: $baseUrl/bookings/$bookingId/reject');
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
      final success = response.statusCode == 200;

      if (success) {
        print('✅ Booking rejected successfully');
      } else {
        print('❌ Failed to reject booking');
        print('Response: ${response.body}');
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
  // CANCEL BOOKING
  // ✅ API: POST /api/bookings/{id}/cancel
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
      print('   Endpoint: $baseUrl/bookings/$bookingId/cancel');
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
      final success = response.statusCode == 200;

      if (success) {
        print('✅ Booking cancelled successfully');
      } else {
        print('❌ Failed to cancel booking');
        print('Response: ${response.body}');
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
  // GET PENDING REVIEWS
  // ✅ API: GET /api/bookings/pending-review
  // ✅ Returns bookings that are completed and haven't been reviewed yet
  // ═══════════════════════════════════════════════════════════

  Future<List<BookingRequestModel>> getPendingReviews() async {
    try {
      final token = await _tokenService.getAccessToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl/bookings/pending-review';

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📋 FETCHING PENDING REVIEWS');
      print('   Endpoint: $url');
      print('──────────────────────────────────────────────────────────');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        final bookingsArray = _extractBookingsArray(decodedBody);

        print('✅ Found ${bookingsArray.length} bookings pending review');

        final bookings = bookingsArray
            .map((json) => BookingRequestModel.fromJson(json as Map<String, dynamic>))
            .toList();

        print('═══════════════════════════════════════════════════════════');

        return bookings;
      } else {
        print('❌ Failed to fetch pending reviews: ${response.statusCode}');
        print('Response: ${response.body}');
        print('═══════════════════════════════════════════════════════════');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching pending reviews: $e');
      print('Stack trace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      print('═══════════════════════════════════════════════════════════');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ADD REVIEW
  // ✅ API: POST /api/bookings/{id}/review
  // ✅ Adds a review/rating for a completed booking
  // ═══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> addReview({
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      final token = await _tokenService.getAccessToken();

      if (token == null) {
        return {'success': false, 'error': 'No authentication token found'};
      }

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('⭐ ADDING REVIEW');
      print('   Endpoint: $baseUrl/bookings/$bookingId/review');
      print('   Booking ID: $bookingId');
      print('   Rating: $rating');
      print('   Comment: ${comment ?? 'None'}');
      print('──────────────────────────────────────────────────────────');

      final body = {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$bookingId/review'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Review added successfully');
        print('═══════════════════════════════════════════════════════════');

        return {'success': true, 'data': json.decode(response.body)};
      } else {
        print('❌ Failed to add review');
        print('Response: ${response.body}');
        print('═══════════════════════════════════════════════════════════');

        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['message'] ?? 'Failed to add review',
          };
        } catch (_) {
          return {'success': false, 'error': 'Failed to add review'};
        }
      }
    } catch (e) {
      print('❌ Error adding review: $e');
      print('═══════════════════════════════════════════════════════════');

      return {'success': false, 'error': 'An error occurred: ${e.toString()}'};
    }
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  List<dynamic> _extractBookingsArray(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Paginated: { "data": { "data": [...] } }
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        final paginatedData = data['data'] as Map<String, dynamic>;
        if (paginatedData.containsKey('data') && paginatedData['data'] is List) {
          print('✅ Found PAGINATED structure (data.data)');
          print('   Current Page: ${paginatedData['current_page']}');
          print('   Total: ${paginatedData['total']}');
          return paginatedData['data'] as List;
        }
      }
      // Flat: { "data": [...] }
      else if (data.containsKey('data') && data['data'] is List) {
        print('✅ Found FLAT structure (data[])');
        return data['data'] as List;
      }
      // Bookings: { "bookings": [...] }
      else if (data.containsKey('bookings') && data['bookings'] is List) {
        print('✅ Found BOOKINGS structure (bookings[])');
        return data['bookings'] as List;
      }
    }
    // Array at root: [...]
    else if (data is List) {
      print('✅ Response is array at root');
      return data;
    }

    return [];
  }

  void _printStatusBreakdown(List<BookingRequestModel> bookings) {
    print('');
    print('   📊 STATUS BREAKDOWN:');
    final statusCounts = <String, int>{};
    for (var booking in bookings) {
      final status = booking.status ?? 'unknown';
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }
    
    if (statusCounts.isEmpty) {
      print('      (No bookings)');
    } else {
      statusCounts.forEach((status, count) {
        print('      • $status: $count');
      });
    }
  }
}