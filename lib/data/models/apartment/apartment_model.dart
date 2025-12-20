import 'dart:convert';
import 'package:hommie/data/services/apartments_service.dart';
class ApartmentModel {
  final int id;
  final String title;
  final String governorate;
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
      title: json["title"] ?? "",
      governorate: json["governorate"] ?? "",
      city: json["city"] ?? "",
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
        }
      }
    }
    
    fetchedImageUrls.insert(0, mainImage);
    imageUrls = fetchedImageUrls; 
  }
}