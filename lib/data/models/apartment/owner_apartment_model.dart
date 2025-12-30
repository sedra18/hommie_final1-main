import 'dart:convert';

class OwnerApartmentModel {
  String id;
  String title;
  String description;
  String governorate;
  String city;
  String address;
  double pricePerDay;
  int roomsCount;
  double apartmentSize;
  List<String> images;
  String? mainImage;

  OwnerApartmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.governorate,
    required this.city,
    required this.address,
    required this.pricePerDay,
    required this.roomsCount,
    required this.apartmentSize,
    required this.images,
    this.mainImage,
  });

  // ═══════════════════════════════════════════════════════════
  // FROM JSON - HANDLES BOTH STRING AND INT
  // ═══════════════════════════════════════════════════════════
  factory OwnerApartmentModel.fromJson(Map<String, dynamic> json) {
    try {
      // ✅ Helper to convert to double (handles both String and num)
      double toDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }

      // ✅ Helper to convert to int (handles both String and num)
      int toInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

      // ✅ Helper to convert to String
      String toString(dynamic value) {
        if (value == null) return '';
        return value.toString();
      }

      // ✅ Parse images array
      List<String> parseImages(dynamic imagesValue) {
        if (imagesValue == null) return [];
        
        if (imagesValue is List) {
          return imagesValue
              .map((e) => e.toString())
              .where((s) => s.isNotEmpty)
              .toList();
        }
        
        if (imagesValue is String) {
          // Try to parse as JSON array
          try {
            final decoded = jsonDecode(imagesValue);
            if (decoded is List) {
              return decoded.map((e) => e.toString()).toList();
            }
          } catch (e) {
            // Not JSON, return as single item
            return [imagesValue];
          }
        }
        
        return [];
      }

      return OwnerApartmentModel(
        id: toString(json['id']),
        title: toString(json['title']),
        description: toString(json['description']),
        governorate: toString(json['governorate']),
        city: toString(json['city']),
        address: toString(json['address']),
        pricePerDay: toDouble(json['price_per_day']),      // ✅ Flexible
        roomsCount: toInt(json['rooms_count']),            // ✅ Flexible
        apartmentSize: toDouble(json['apartment_size']),   // ✅ Flexible
        images: parseImages(json['images']),
        mainImage: json['main_image']?.toString(),
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing OwnerApartmentModel:');
      print('   Error: $e');
      print('   JSON: $json');
      print('   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // TO JSON
  // ═══════════════════════════════════════════════════════════
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'governorate': governorate,
      'city': city,
      'address': address,
      'price_per_day': pricePerDay,
      'rooms_count': roomsCount,
      'apartment_size': apartmentSize,
      'images': images,
      'main_image': mainImage,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // COPY WITH
  // ═══════════════════════════════════════════════════════════
  OwnerApartmentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? governorate,
    String? city,
    String? address,
    double? pricePerDay,
    int? roomsCount,
    double? apartmentSize,
    List<String>? images,
    String? mainImage,
  }) {
    return OwnerApartmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      address: address ?? this.address,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      roomsCount: roomsCount ?? this.roomsCount,
      apartmentSize: apartmentSize ?? this.apartmentSize,
      images: images ?? this.images,
      mainImage: mainImage ?? this.mainImage,
    );
  }

  @override
  String toString() {
    return 'OwnerApartmentModel(id: $id, title: $title, price: \$$pricePerDay/day, rooms: $roomsCount, size: ${apartmentSize}m²)';
  }
}