import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/post_ad_controller.dart';

// ═══════════════════════════════════════════════════════════
// APARTMENT IMAGES VIEW - FIXED CONTROLLER ISSUE
// Doesn't recreate controller (preserves draft)
// ═══════════════════════════════════════════════════════════

class ApartmentImagesView extends StatefulWidget {
  final bool isEdit;
  final ApartmentModel? editingApartment;

  const ApartmentImagesView({
    super.key,
    required this.isEdit,
    this.editingApartment,
  });

  @override
  State<ApartmentImagesView> createState() => _ApartmentImagesViewState();
}

class _ApartmentImagesViewState extends State<ApartmentImagesView> {
  final ImagePicker _picker = ImagePicker();

  final List<XFile> _selectedImages = [];
  XFile? _selectedMainImage;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    print('📸 ApartmentImagesView initialized (isEdit: ${widget.isEdit})');
  }

  // ═══════════════════════════════════════════════════════════
  // IMAGE SELECTION
  // ═══════════════════════════════════════════════════════════

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });

        print('📸 Added ${images.length} images');
        print('   Total images: ${_selectedImages.length}');
      }
    } catch (e) {
      print('❌ Error picking images: $e');

      if (mounted) {
        Get.snackbar(
          'خطأ',
          'فشل اختيار الصور',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _pickMainImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedMainImage = image;
        });

        print('📸 Main image selected: ${image.path}');
      }
    } catch (e) {
      print('❌ Error picking main image: $e');

      if (mounted) {
        Get.snackbar(
          'خطأ',
          'فشل اختيار الصورة الرئيسية',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void _removeImage(XFile image) {
    setState(() {
      _selectedImages.remove(image);
    });
    print('🗑️ Removed image: ${image.path}');
    print('   Remaining: ${_selectedImages.length}');
  }

  void _clearMainImage() {
    setState(() {
      _selectedMainImage = null;
    });
    print('🗑️ Cleared main image');
  }

  // ═══════════════════════════════════════════════════════════
  // PUBLISH APARTMENT
  // ═══════════════════════════════════════════════════════════

  Future<void> _publishApartment() async {
    // Validation
    if (_selectedImages.isEmpty) {
      Get.snackbar(
        'تحذير',
        'الرجاء اختيار صورة واحدة على الأقل',
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
      print('📤 PUBLISHING APARTMENT');
      print('──────────────────────────────────────────────────────────');

      // ✅ FIX: Use Get.find() instead of Get.put()
      // This gets the existing controller instead of creating a new one
      final c = Get.find<PostAdController>();

      // Convert XFile list to path strings
      final imagePaths = _selectedImages.map((file) => file.path).toList();

      print('   Selected images: ${imagePaths.length}');
      for (var i = 0; i < imagePaths.length; i++) {
        print('      ${i + 1}. ${imagePaths[i]}');
      }

      if (_selectedMainImage != null) {
        print('   Main image: ${_selectedMainImage!.path}');
      }

      print('──────────────────────────────────────────────────────────');

      // Save images to draft
      print('💾 Saving images to draft...');
      await c.saveDraftImagesFromFiles(imagePaths);
      print('✅ Images saved to draft');

      // Publish the draft
      print('📤 Publishing to backend...');
      await c.publishDraft();

      print('');
      print('✅ PUBLISH COMPLETE');
      print('═══════════════════════════════════════════════════════════');

      // Show success message BEFORE navigation
      if (mounted) {
        Get.snackbar(
          'نجح',
          'تم نشر الشقة بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
      }

      // Wait a bit for user to see the message
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate back
      if (mounted) {
        Get.back(); // Back to form screen
        Get.back(); // Back to post ad screen
      }
    } catch (e) {
      print('');
      print('❌ PUBLISH FAILED');
      print('   Error: $e');
      print('═══════════════════════════════════════════════════════════');

      // Show error message
      if (mounted) {
        Get.snackbar(
          'خطأ',
          'فشل نشر الشقة: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD UI
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'تعديل الصور' : 'صور الشقة'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'اختر صور الشقة (يجب اختيار صورة واحدة على الأقل)',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pick Images Button
            ElevatedButton.icon(
              onPressed: _isPublishing ? null : _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('اختيار الصور'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),

            // Selected Images Grid
            if (_selectedImages.isNotEmpty) ...[
              Text(
                'الصور المحددة (${_selectedImages.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  final image = _selectedImages[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(image.path), fit: BoxFit.cover),
                      ),
                      // Remove button
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(image),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Main Image Section (Optional)
            if (_selectedMainImage != null) ...[
              const Text(
                'الصورة الرئيسية',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_selectedMainImage!.path),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _clearMainImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Publish Button
            ElevatedButton(
              onPressed: _isPublishing ? null : _publishApartment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: _isPublishing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('جاري النشر...'),
                      ],
                    )
                  : const Text('نشر الشقة'),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            TextButton(
              onPressed: _isPublishing
                  ? null
                  : () {
                      try {
                        final controller = Get.find<PostAdController>();
                        controller.cancelDraft();
                      } catch (e) {
                        print('⚠️  Controller not found: $e');
                      }
                      Get.back();
                    },
              child: const Text('إلغاء', style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('📸 ApartmentImagesView disposed');
    super.dispose();
  }
}