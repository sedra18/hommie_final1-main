import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/models/apartment/owner_apartment_model.dart';
import 'package:hommie/data/models/user/user_permission_controller.dart';
import 'package:hommie/data/repositories/apartment_repository.dart';
import 'package:hommie/modules/owner/views/apartment_form_view.dart';
import 'package:image_picker/image_picker.dart';

// ═══════════════════════════════════════════════════════════
// POST AD CONTROLLER - WITH LOAD AFTER PUBLISH
// ✅ Calls repo.load() after successful publish
// ═══════════════════════════════════════════════════════════

class PostAdController extends GetxController {
  final ApartmentRepository repo;
  PostAdController(this.repo);

  final permissions = Get.find<UserPermissionsController>();

  List<OwnerApartmentModel> get myApartments => repo.apartments;

  OwnerApartmentModel? draft;

  // ✅ Load apartments on init
  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🔄 POST AD CONTROLLER - LOADING APARTMENTS');
    await repo.load();
    print('   Apartments loaded: ${myApartments.length}');
    print('═══════════════════════════════════════════════════════════');
  }

  void startNewDraft() {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📝 STARTING NEW DRAFT');
    print('═══════════════════════════════════════════════════════════');
    
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
    
    print('✅ New draft created with ID: ${draft!.id}');
  }

  // ═══════════════════════════════════════════════════════════
  // SAVE BASIC INFO
  // ═══════════════════════════════════════════════════════════
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
    
    print('');
    print('📋 Saving basic info to draft:');
    print('   Title: $title');
    print('   Governorate: $governorate');
    print('   City: $city');
    print('   Address: $address');
    print('   Price: \$$pricePerDay/day');
    print('   Rooms: $roomsCount');
    print('   Size: ${apartmentSize}m²');
    
    draft!
      ..title = title
      ..description = description
      ..governorate = governorate
      ..city = city
      ..address = address
      ..pricePerDay = pricePerDay
      ..roomsCount = roomsCount
      ..apartmentSize = apartmentSize;
      
    print('✅ Basic info saved to draft');
  }

  // ═══════════════════════════════════════════════════════════
  // SAVE IMAGES FROM FILES
  // ═══════════════════════════════════════════════════════════
  Future<void> saveDraftImagesFromFiles({
    required List<XFile> imageFiles,
    XFile? mainImageFile,
  }) async {
    if (draft == null) {
      print('⚠️  No draft found, creating new one');
      startNewDraft();
    }

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📸 SAVING IMAGES FROM FILES');
    print('═══════════════════════════════════════════════════════════');
    print('   Total images: ${imageFiles.length}');
    print('   Has main image: ${mainImageFile != null}');

    // Convert XFile paths to image URLs/paths for storage
    List<String> imagePaths = imageFiles.map((file) => file.path).toList();
    String? mainImagePath = mainImageFile?.path;

    draft!
      ..images = imagePaths
      ..mainImage = mainImagePath ?? (imagePaths.isNotEmpty ? imagePaths.first : null);

    print('✅ Images saved:');
    print('   Image paths: $imagePaths');
    print('   Main image path: ${draft!.mainImage}');
    print('═══════════════════════════════════════════════════════════');
  }

  // ═══════════════════════════════════════════════════════════
  // PUBLISH DRAFT (WITH PERMISSION CHECK + RELOAD)
  // ═══════════════════════════════════════════════════════════
  Future<void> publishDraft() async {
    if (draft == null) {
      print('⚠️  No draft to publish');
      Get.snackbar(
        'خطأ',
        'لا يوجد مسودة للنشر',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🚀 PUBLISHING DRAFT');
    print('═══════════════════════════════════════════════════════════');
    print('   Title: ${draft!.title}');
    print('   Price: \$${draft!.pricePerDay}/day');
    print('   Location: ${draft!.governorate}, ${draft!.city}');
    print('   Images: ${draft!.images.length}');
    print('──────────────────────────────────────────────────────────');

    // CHECK PERMISSION FIRST
    if (!permissions.checkPermission('post', showMessage: true)) {
      print('❌ Publish denied - User not approved');
      print('   Is Approved: ${permissions.isApproved.value}');
      print('   Role: ${permissions.userRole.value}');
      print('═══════════════════════════════════════════════════════════');
      return;
    }

    print('✅ Permission granted - Publishing apartment');

    try {
      // ✅ Add to repository (this calls api.create() internally)
      await repo.add(draft!);
      
      print('');
      print('✅ APARTMENT PUBLISHED SUCCESSFULLY');
      print('   Apartment ID: ${draft!.id}');
      print('──────────────────────────────────────────────────────────');
      
      // ✅ The repo.add() already calls load(), so apartments should be updated
      print('   Total apartments in repo: ${myApartments.length}');
      
      // Print apartment titles for verification
      if (myApartments.isNotEmpty) {
        print('   Apartments in list:');
        for (var apt in myApartments) {
          print('      - ${apt.title} (\$${apt.pricePerDay}/day)');
        }
      } else {
        print('   ⚠️  WARNING: No apartments in list after publish!');
        print('   Attempting manual reload...');
        await repo.load();
        print('   After manual reload: ${myApartments.length} apartments');
      }
      
      print('═══════════════════════════════════════════════════════════');
      
      // Clear draft after successful publish
      final publishedTitle = draft!.title;
      draft = null;
      
      // NOTE: Don't show snackbar here - let the view handle it after navigation
      
    } catch (e) {
      print('');
      print('❌ PUBLISH FAILED');
      print('   Error: $e');
      print('═══════════════════════════════════════════════════════════');
      
      Get.snackbar(
        '❌ خطأ',
        'فشل نشر الشقة: $e',
        backgroundColor: AppColors.failure,
        colorText: AppColors.backgroundLight,
        duration: const Duration(seconds: 3),
      );
      
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // DELETE APARTMENT
  // ═══════════════════════════════════════════════════════════
  Future<void> deleteApartment(String id) async {
    print('');
    print('🗑️  Deleting apartment: $id');
    
    await repo.remove(id);
    
    print('✅ Apartment deleted');
    print('   Remaining apartments: ${myApartments.length}');
    
    Get.snackbar(
      'تم الحذف',
      'تم حذف الشقة بنجاح',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // UPDATE APARTMENT
  // ═══════════════════════════════════════════════════════════
  Future<void> updateApartment(OwnerApartmentModel apt) async {
    print('');
    print('📝 Updating apartment: ${apt.title}');
    
    await repo.edit(apt);
    
    print('✅ Apartment updated');
    
    Get.snackbar(
      'تم التحديث',
      'تم تحديث الشقة بنجاح',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // NAVIGATION HELPER WITH PERMISSION CHECK
  // ═══════════════════════════════════════════════════════════
  void onAddApartmentPressed() {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('➕ ADD APARTMENT BUTTON PRESSED');
    print('──────────────────────────────────────────────────────────');

    // CHECK PERMISSION FIRST
    if (!permissions.checkPermission('post', showMessage: true)) {
      print('❌ Add apartment denied - User not approved');
      print('   Is Approved: ${permissions.isApproved.value}');
      print('   Role: ${permissions.userRole.value}');
      print('═══════════════════════════════════════════════════════════');
      return;
    }

    print('✅ Permission granted - Opening apartment form');
    print('═══════════════════════════════════════════════════════════');
    
    // Create new draft
    startNewDraft();
    
    // Navigate to ApartmentFormView
    Get.to(() => const ApartmentFormView(
      isEdit: false,
      editingApartment: null,
    ));
  }

  // ═══════════════════════════════════════════════════════════
  // GETTER FOR UI
  // ═══════════════════════════════════════════════════════════
  bool get canAddApartment => permissions.canPostApartments;
}