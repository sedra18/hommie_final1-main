import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/owner_apartment_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../controllers/post_ad_controller.dart';

// ═══════════════════════════════════════════════════════════
// APARTMENT IMAGES VIEW - COMPLETE FIX
// ✅ Proper list refresh after publish
// ✅ Fixed snackbar disposal error
// ═══════════════════════════════════════════════════════════

class ApartmentImagesView extends StatefulWidget {
  final bool isEdit;
  final OwnerApartmentModel? editingApartment;

  const ApartmentImagesView({
    super.key,
    required this.isEdit,
    this.editingApartment,
  });

  @override
  State<ApartmentImagesView> createState() => _ApartmentImagesViewState();
}

class _ApartmentImagesViewState extends State<ApartmentImagesView> {
  final c = Get.find<PostAdController>();
  final ImagePicker _picker = ImagePicker();

  late List<XFile> _selectedImages;
  late XFile? _selectedMainImage;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.editingApartment != null) {
      final a = widget.editingApartment!;
      // Load existing images if editing
    }

    _selectedImages = [];
    _selectedMainImage = null;
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _pickMainImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedMainImage = image;
      });
    }
  }

  void _removeImage(XFile image) {
    setState(() {
      _selectedImages.remove(image);
    });
  }

  void _clearMainImage() {
    setState(() {
      _selectedMainImage = null;
    });
  }

  // ═══════════════════════════════════════════════════════════
  // PUBLISH WITH PROPER LIST REFRESH AND SNACKBAR FIX
  // ═══════════════════════════════════════════════════════════
  Future<void> _publishApartment() async {
    if (_selectedImages.isEmpty) {
      Get.snackbar(
        "تحذير",
        "الرجاء اختيار صور للشقة",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📸 SAVING IMAGES AND PUBLISHING');
      print('═══════════════════════════════════════════════════════════');

      // Save images to draft
      await c.saveDraftImagesFromFiles(
        imageFiles: _selectedImages,
        mainImageFile: _selectedMainImage,
      );

      // Publish the draft
      await c.publishDraft();

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('✅ PUBLISH COMPLETE - NAVIGATING');
      print('═══════════════════════════════════════════════════════════');

      // ✅ Navigate first (avoiding snackbar disposal)
      Get.back(); // Back to form
      Get.back(); // Back to post ad screen

      // ✅ Wait before showing snackbar
      await Future.delayed(const Duration(milliseconds: 500));

      // ✅ Show success snackbar AFTER navigation
      if (mounted) {
        Get.snackbar(
          '✅ نجح النشر',
          'تم نشر الشقة بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
        );
      }

    } catch (e) {
      setState(() {
        _isPublishing = false;
      });

      print('');
      print('❌ Error publishing: $e');
      print('═══════════════════════════════════════════════════════════');

      Get.snackbar(
        '❌ خطأ',
        'فشل نشر الشقة: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة صور")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text(
            "اختر من المعرض",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Selected Images Preview
          if (_selectedImages.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "الصور المختارة (${_selectedImages.length})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      final image = _selectedImages[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(image.path),
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(image),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),

          ElevatedButton.icon(
            onPressed: _isPublishing ? null : _pickImages,
            icon: const Icon(Icons.photo_library),
            label: const Text("إضافة صور"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          const Text(
            "اختر الصورة الرئيسية",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          if (_selectedMainImage != null)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_selectedMainImage!.path),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _clearMainImage,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    "إزالة الصورة الرئيسية",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 64, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'لا توجد صورة رئيسية',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: _isPublishing ? null : _pickMainImage,
            icon: const Icon(Icons.add_a_photo),
            label: const Text("اختيار الصورة الرئيسية"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          const SizedBox(height: 32),

          // ✅ PUBLISH BUTTON WITH LOADING STATE
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isPublishing ? null : _publishApartment,
              icon: _isPublishing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.publish),
              label: Text(
                _isPublishing
                    ? 'جاري النشر...'
                    : (widget.isEdit
                        ? "حفظ التعديل والعودة"
                        : "نشر الشقة والعودة"),
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPublishing ? Colors.grey : Colors.green,
                disabledBackgroundColor: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info text
          if (_selectedImages.isEmpty)
            const Text(
              'الرجاء اختيار صورة واحدة على الأقل',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Future<Uint8List?> _loadImageBytes(XFile imageFile) async {
    try {
      return await imageFile.readAsBytes();
    } catch (e) {
      print("Error reading image bytes: $e");
      return null;
    }
  }
}