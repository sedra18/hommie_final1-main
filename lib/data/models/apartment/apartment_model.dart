import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hommie/data/services/apartments_service.dart';

// ═══════════════════════════════════════════════════════════
// APARTMENT MODEL - FIXED
// ✅ Proper type casting for image lists
// ✅ Uses ApartmentsService.getCleanImageUrl()
// ✅ No type errors
// ═══════════════════════════════════════════════════════════

class ApartmentModel {
  final int id;
  final int? userId;  
  final String title;
  final String governorate;
  final String? address;
  final String city;
  final String mainImage; 
  final int pricePerDay;
  final int roomsCount;
  final double apartmentSize;
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

  factory ApartmentModel.fromJson(Map<String, dynamic> json) {
    final rawMainImage = json["main_image"] ?? "";
    
    final fullImageUrl = rawMainImage.isNotEmpty
        ? ApartmentsService.getCleanImageUrl(rawMainImage)
        : "";

    return ApartmentModel(
      id: json["id"] ?? 0,
      userId: json["user_id"] as int?,  
      title: json["title"] ?? "",
      governorate: json["governorate"] ?? "",
      city: json["city"] ?? "",
      address: json["address"] ?? "",
      mainImage: fullImageUrl,
      pricePerDay: int.tryParse(json["price_per_day"].toString()) ?? 0,
      roomsCount: int.tryParse(json["rooms_count"].toString()) ?? 0,
      apartmentSize: double.tryParse(json["apartment_size"].toString()) ?? 0,
      avgRating: double.tryParse(json["avg_rating"].toString()) ?? 0,
    );
  }

  void updateFromDetailsJson(Map<String, dynamic> json) {
    description = json["description"] ?? description;
    ownerName = json["owner"]?["name"] ?? ownerName;
    isFavorite = json["is_favorite"] ?? isFavorite;
    
    final rawImages = json["images"]; 
    List<String> fetchedImageUrls = [];
    
    if (rawImages != null) {
      if (rawImages is List) {
        // ✅ FIXED: Proper type casting
        fetchedImageUrls = rawImages
            .map((e) => ApartmentsService.getCleanImageUrl(e.toString()))
            .cast<String>()  // ✅ Add cast<String>()
            .toList();
      } else if (rawImages is String && rawImages.isNotEmpty) {
        try {
          final List<dynamic> decodedImages = jsonDecode(rawImages);
          // ✅ FIXED: Proper type casting
          fetchedImageUrls = decodedImages
              .map((e) => ApartmentsService.getCleanImageUrl(e.toString()))
              .cast<String>()  // ✅ Add cast<String>()
              .toList();
        } catch (e) {
          // Silent catch - invalid JSON
          if (kDebugMode) {
            print('⚠️  Failed to decode images JSON: $e');
          }
        }
      }
    }
    
    // Insert main image at the beginning
    if (mainImage.isNotEmpty && !fetchedImageUrls.contains(mainImage)) {
      fetchedImageUrls.insert(0, mainImage);
    }
    
    imageUrls = fetchedImageUrls; 
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER METHOD - Check if this apartment belongs to user
  // ═══════════════════════════════════════════════════════════
  
  bool belongsToUser(int? currentUserId) {
    if (currentUserId == null || userId == null) {
      return false;
    }
    return userId == currentUserId;
  }

  // ═══════════════════════════════════════════════════════════
  // TO JSON (if needed for API calls)
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
  // COPY WITH (for creating modified copies)
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
    double? apartmentSize,
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
    return 'ApartmentModel(id: $id, userId: $userId, title: $title, city: $city, price: \$$pricePerDay/day)';
  }
}