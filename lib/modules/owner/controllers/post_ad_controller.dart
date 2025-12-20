import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hommie/data/models/apartment/owner_apartment_model.dart';
import 'package:hommie/data/repositories/apartment_repository.dart';
import 'package:image_picker/image_picker.dart';

class PostAdController extends GetxController {
  final ApartmentRepository repo;
  PostAdController(this.repo);

  List<OwnerApartmentModel> get myApartments => repo.apartments;

  OwnerApartmentModel? draft;

  Future<void> load() async => repo.load();

  void startNewDraft() {
    draft = OwnerApartmentModel(
      id: UniqueKey().toString(),
      title: "",
      description: "",
      governorate: "",
      city: "",
      address: "",
      pricePerDay: 0,
      roomsCount: 1,
      apartmentSize: 0,
      images: [],
      mainImage: null,
    );
  }

  Future<void> saveDraftBasicInfo({
    required String title,
    required String description,
    required String governorate,
    required String city,
    required String address,
    required double pricePerDay,
    required int roomsCount,
    required double apartmentSize,
  }) async {
    if (draft == null) startNewDraft();
    draft!
      ..title = title
      ..description = description
      ..governorate = governorate
      ..city = city
      ..address = address
      ..pricePerDay = pricePerDay
      ..roomsCount = roomsCount
      ..apartmentSize = apartmentSize;
  }

  Future<void> saveDraftImages({
    required List<String> images,
    required String mainImage,
  }) async {
    if (draft == null) return;
    draft!
      ..images = images
      ..mainImage = mainImage;
  }

  Future<void> saveDraftImagesFromFiles({
    required List<XFile> imageFiles,
    XFile? mainImageFile,
  }) async {

  }
  Future<void> publishDraft() async {
    if (draft == null) return;

    await repo.add(draft!);
    draft = null;
  }

  Future<void> deleteApartment(String id) async {
    await repo.remove(id);
  }

  Future<void> updateApartment(OwnerApartmentModel apt) async {
    await repo.edit(apt);
  }
}
