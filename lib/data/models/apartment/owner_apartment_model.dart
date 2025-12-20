class OwnerApartmentModel {
  final String id;

  String title;
  String description;
  String governorate;
  String city;
  String address;
  double pricePerDay;
  int roomsCount;
  double apartmentSize;

  // الصور
  List<String> images;   // images[]
  String? mainImage;     // mainimage

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
    this.images = const [],
    this.mainImage,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "governorate": governorate,
        "city": city,
        "address": address,
        "priceperday": pricePerDay,
        "rooms_count": roomsCount,
        "apartmentsize": apartmentSize,
        "images": images,
        "mainimage": mainImage,
      };
      static OwnerApartmentModel fromJson(Map<String, dynamic> json) => OwnerApartmentModel(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        governorate: json["governorate"],
        city: json["city"],
        address: json["address"],
        pricePerDay: (json["priceperday"] as num).toDouble(),
        roomsCount: (json["rooms_count"] as num).toInt(),
        apartmentSize: (json["apartmentsize"] as num).toDouble(),
        images: (json["images"] as List).map((e) => e.toString()).toList(),
        mainImage: json["mainimage"],
      );
}