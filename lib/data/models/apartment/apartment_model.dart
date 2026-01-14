import 'dart:convert';
import 'package:hommie/data/services/apartments_service.dart';

// ═══════════════════════════════════════════════════════════
// APARTMENT MODEL - COMBINED VERSION
// ✅ Has userId field for owner identification
// ✅ Has address field
// ✅ Properly handles main_image from both list and details
// ✅ Has all utility methods (toJson, copyWith, toString)
// ═══════════════════════════════════════════════════════════

class ApartmentModel {
  final int id;
  final int? userId;  // Owner's user ID
  final String title;
  final String governorate;
  final String? address;
  final String city;
  final String mainImage; 
  final int pricePerDay;
  final int roomsCount;
  final int apartmentSize;
  final double avgRating;

  String? description;
  String? ownerName;
  List<String> imageUrls;
  bool? isFavorite;

  ApartmentModel({
    required this.id,
    this.userId,
    this.address,
    required this.title,
    required this.governorate,
    required this.city,
    required this.mainImage,
    required this.pricePerDay,
    required this.roomsCount,
    required this.apartmentSize,
    required this.avgRating,
    this.description,
    this.ownerName,
    List<String>? imageUrls,
    this.isFavorite,
  }) : imageUrls = imageUrls ?? [];

  // ═══════════════════════════════════════════════════════════
  // FROM JSON - COMBINED VERSION
  // ✅ Handles both int and double for prices
  // ✅ Cleans image URLs properly
  // ✅ Parses userId for owner identification
  // ═══════════════════════════════════════════════════════════

  factory ApartmentModel.fromJson(Map<String, dynamic> json) {
    final rawMainImage = json["main_image"] ?? "";
    
    // ✅ Clean the main image URL
    final fullImageUrl = rawMainImage.isNotEmpty && rawMainImage != 'null'
        ? ApartmentsService.getCleanImageUrl(rawMainImage)
        : "";

    return ApartmentModel(
      id: json["id"] ?? 0,
      userId: json["user_id"] as int?,  // Parse user_id from backend
      title: json["title"] ?? "",
      governorate: json["governorate"] ?? "",
      city: json["city"] ?? "",
      address: json["address"] ?? "",
      mainImage: fullImageUrl,
      // ✅ Handle both int and double for prices
      pricePerDay: _toInt(json["price_per_day"]),
      roomsCount: _toInt(json["rooms_count"]),
      apartmentSize: _toInt(json["apartment_size"]),
      avgRating: _toDouble(json["avg_rating"]),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER CONVERTERS - Handle both String and num
  // ═══════════════════════════════════════════════════════════
  
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  
  void updateFromDetailsJson(Map<String, dynamic> json) {
    description = json["description"] ?? description;
    ownerName = json["owner"]?["name"] ?? ownerName;
    isFavorite = json["is_favorite"] ?? isFavorite;
    
    final rawImages = json["images"]; 
    List<String> fetchedImageUrls = [];
    
    if (rawImages != null) {
      if (rawImages is List) {
        // Images as array
        fetchedImageUrls = rawImages
            .map((e) => ApartmentsService.getCleanImageUrl(e.toString()))
            .where((url) => url.isNotEmpty)
            .toList();
      } else if (rawImages is String && rawImages.isNotEmpty) {
        // Images as JSON string
        try {
          final List<dynamic> decodedImages = jsonDecode(rawImages);
          fetchedImageUrls = decodedImages
              .map((e) => ApartmentsService.getCleanImageUrl(e.toString()))
              .where((url) => url.isNotEmpty)
              .toList();
        } catch (e) {
          // Silent catch - invalid JSON
        }
      }
    }
    
    // ✅ Ensure main image is first (if it's not empty)
    if (mainImage.isNotEmpty) {
      // Remove mainImage from list if it exists
      fetchedImageUrls.removeWhere((url) => url == mainImage);
      // Insert at beginning
      fetchedImageUrls.insert(0, mainImage);
    }
    
    imageUrls = fetchedImageUrls; 
  }

  
  
  bool belongsToUser(int? currentUserId) {
    if (currentUserId == null || userId == null) {
      return false;
    }
    return userId == currentUserId;
  }

  // ═══════════════════════════════════════════════════════════
  // TO JSON
  // ═══════════════════════════════════════════════════════════
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'governorate': governorate,
      'city': city,
      'address': address,
      'main_image': mainImage,
      'price_per_day': pricePerDay,
      'rooms_count': roomsCount,
      'apartment_size': apartmentSize,
      'avg_rating': avgRating,
      'description': description,
      'owner_name': ownerName,
      'images': imageUrls,
      'is_favorite': isFavorite,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // COPY WITH
  // ═══════════════════════════════════════════════════════════
  
  ApartmentModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? governorate,
    String? city,
    String? address,
    String? mainImage,
    int? pricePerDay,
    int? roomsCount,
    int? apartmentSize,
    double? avgRating,
    String? description,
    String? ownerName,
    List<String>? imageUrls,
    bool? isFavorite,
  }) {
    return ApartmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      address: address ?? this.address,
      mainImage: mainImage ?? this.mainImage,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      roomsCount: roomsCount ?? this.roomsCount,
      apartmentSize: apartmentSize ?? this.apartmentSize,
      avgRating: avgRating ?? this.avgRating,
      description: description ?? this.description,
      ownerName: ownerName ?? this.ownerName,
      imageUrls: imageUrls ?? this.imageUrls,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DEBUG STRING
  // ═══════════════════════════════════════════════════════════
  
  @override
  String toString() {
    return 'ApartmentModel(id: $id, userId: $userId, title: $title, city: $city, price: \$$pricePerDay/day, mainImage: ${mainImage.isNotEmpty ? "✅" : "❌"}, images: ${imageUrls.length})';
  }
}