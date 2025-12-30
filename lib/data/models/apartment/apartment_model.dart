import 'dart:convert';
import 'package:hommie/data/services/apartments_service.dart';

// ═══════════════════════════════════════════════════════════
// APARTMENT MODEL - WITH USER ID
// ✅ Added userId field to identify apartment owner
// ✅ Parses user_id from backend JSON
// ═══════════════════════════════════════════════════════════

class ApartmentModel {
  final int id;
  final int? userId;  // ✅ ADDED - Owner's user ID
  final String title;
  final String governorate;
   final String? address;
  final String city;
  final String mainImage; 
  final double pricePerDay;
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
    this.address,  // ✅ ADDED
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
      userId: json["user_id"] as int?,  // ✅ ADDED - Parse user_id from backend
      title: json["title"] ?? "",
      governorate: json["governorate"] ?? "",
      city: json["city"] ?? "",
      address: json["address"] ?? "",
      mainImage: fullImageUrl,
      pricePerDay: double.tryParse(json["price_per_day"].toString()) ?? 0,
      roomsCount: int.tryParse(json["rooms_count"].toString()) ?? 0,
      apartmentSize: int.tryParse(json["apartment_size"].toString()) ?? 0,
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
        fetchedImageUrls = rawImages
            .map((e) => ApartmentsService.getCleanImageUrl(e.toString()))
            .toList();
      } else if (rawImages is String && rawImages.isNotEmpty) {
        try {
          final List<dynamic> decodedImages = jsonDecode(rawImages);
          fetchedImageUrls = decodedImages
              .map((e) => ApartmentsService.getCleanImageUrl(e.toString()))
              .toList();
        } catch (e) {
          // Silent catch - invalid JSON
        }
      }
    }
    
    fetchedImageUrls.insert(0, mainImage);
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
      'user_id': userId,  // ✅ ADDED
      'title': title,
      'governorate': governorate,
      'city': city,
      'address':address,
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
    int? userId,  // ✅ ADDED
    String? title,
    String? governorate,
    String? city,
      final String? address,
    String? mainImage,
    double? pricePerDay,
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
      userId: userId ?? this.userId,  // ✅ ADDED
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