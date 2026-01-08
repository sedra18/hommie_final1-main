
import 'dart:convert';
import 'package:get/get.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:hommie/data/services/token_storage_service.dart';

class BookingService extends GetxService {
  static String baseUrl = '${BaseUrl.pubBaseUrl}/api';

  final TokenStorageService _tokenService = Get.put(TokenStorageService());



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
        Uri.parse('$baseUrl/bookings'),
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }


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
        final bookingsData = _extractBookingsArray(data);
        
        print('Total bookings received: ${bookingsData.length}');

        final bookings = bookingsData.map((json) {
          return BookingRequestModel.fromJson(_mapStatus(json));
        }).toList();

        print('✅ Found ${bookings.length} bookings');
        _printStatusBreakdown(bookings);
        print('═══════════════════════════════════════════════════════════');

        return bookings;
      } else {
        print('❌ Failed to fetch bookings: ${response.statusCode}');
        print('═══════════════════════════════════════════════════════════');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching bookings: $e');
      print('Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      print('═══════════════════════════════════════════════════════════');
      return [];
    }
  }

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
        final bookingsData = _extractBookingsArray(data);
        
        print('Total bookings received: ${bookingsData.length}');

        final bookings = bookingsData.map((json) {
          return BookingRequestModel.fromJson(_mapStatus(json));
        }).toList();

        print('✅ Found ${bookings.length} owner bookings');
        _printStatusBreakdown(bookings);
        print('═══════════════════════════════════════════════════════════');

        return bookings;
      } else {
        print('❌ Failed to fetch owner bookings: ${response.statusCode}');
        print('═══════════════════════════════════════════════════════════');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching owner bookings: $e');
      print('Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      print('═══════════════════════════════════════════════════════════');
      return [];
    }
  }



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



  /// Extract bookings array from various response structures
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

  /// Map backend status to frontend status
  Map<String, dynamic> _mapStatus(Map<String, dynamic> json) {
    if (json.containsKey('status')) {
      final backendStatus = json['status'] as String?;
      final mappedStatus = _mapBackendStatus(backendStatus);
      
      if (backendStatus != mappedStatus) {
        print('📦 Booking #${json['id']}: "$backendStatus" → "$mappedStatus"');
        json = Map<String, dynamic>.from(json);
        json['status'] = mappedStatus;
      }
    }
    return json;
  }

  /// Map backend status names to frontend status names
  String? _mapBackendStatus(String? backendStatus) {
    if (backendStatus == null) return null;
    
    final status = backendStatus.toLowerCase().trim();
    
    switch (status) {
      case 'pending':
      case 'pending_owner_approval':
      case 'pending_approval':
      case 'awaiting_approval':
        return 'pending';
        
      case 'approved':
      case 'confirmed':
      case 'accepted':
        return 'approved';
        
      case 'rejected':
      case 'declined':
      case 'cancelled':
      case 'canceled':
        return 'rejected';
        
      case 'completed':
      case 'finished':
      case 'done':
        return 'completed';
        
      default:
        return backendStatus;
    }
  }

  /// Print status breakdown for debugging
  void _printStatusBreakdown(List<BookingRequestModel> bookings) {
    print('   Status breakdown:');
    final statusCounts = <String, int>{};
    for (var booking in bookings) {
      final status = booking.status ?? 'unknown';
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }
    statusCounts.forEach((status, count) {
      print('     - $status: $count');
    });
  }



  /// Alias for getMyBookings (for renter)
  Future<List<BookingRequestModel>> getUserBookings() async {
    return getMyBookings();
  }
}