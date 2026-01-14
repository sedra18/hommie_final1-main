import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/modules/owner/views/post_ad_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/post_ad_controller.dart';

// ═══════════════════════════════════════════════════════════
// APARTMENT IMAGES VIEW - FIXED NAVIGATION
// ✅ Navigates directly to PostAdScreen after publishing
// ✅ Handles both create and edit modes
// ✅ Proper success/error handling
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
    print('📸 ApartmentImagesView initialized');
    print('   Mode: ${widget.isEdit ? "EDIT" : "CREATE"}');
    if (widget.editingApartment != null) {
      print('   Editing apartment ID: ${widget.editingApartment!.id}');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PICK INSIDE IMAGES
  // ═══════════════════════════════════════════════════════════

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
        print('📸 Added ${images.length} inside images');
      }
    } catch (e) {
      print('❌ Error picking images: $e');
      if (mounted) {
        Get.snackbar('خطأ', 'فشل اختيار الصور',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    print('🗑️ Removed inside image at index $index');
  }

  // ═══════════════════════════════════════════════════════════
  // PICK MAIN IMAGE
  // ═══════════════════════════════════════════════════════════

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

  void _clearMainImage() {
    setState(() {
      _selectedMainImage = null;
    });
    print('🗑️ Cleared main image');
  }

  // ═══════════════════════════════════════════════════════════
  // PUBLISH / UPDATE APARTMENT - FIXED NAVIGATION
  // ✅ Now navigates directly to PostAdScreen
  // ✅ Clears navigation stack properly
  // ✅ Shows success message after navigation
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
      
      final c = Get.find<PostAdController>();
      
      // Prepare image paths
      final imagePaths = _selectedImages.map((file) => file.path).toList();
      
      // Determine main image index
      int mainIndex = 0;
      if (_selectedMainImage != null) {
        // If user selected a specific main image, add it to the front
        imagePaths.insert(0, _selectedMainImage!.path);
        mainIndex = 0;
        print('   Main image (user selected): ${_selectedMainImage!.path}');
      } else {
        print('   Main image (auto - first image): ${imagePaths[0]}');
      }
      
      print('   Total images: ${imagePaths.length}');
      for (var i = 0; i < imagePaths.length; i++) {
        print('      ${i + 1}. ${imagePaths[i]}${i == mainIndex ? " ⭐ MAIN" : ""}');
      }
      
      print('──────────────────────────────────────────────────────────');
      
      // Save images to draft
      print('💾 Saving images to draft...');
      await c.saveDraftImages(imagePaths, mainIndex: mainIndex);
      print('✅ Images saved to draft');
      
      // Publish the draft
      print('📤 Publishing to backend...');
      await c.publishDraft();
      
      print('');
      print('✅ PUBLISH COMPLETE');
      print('═══════════════════════════════════════════════════════════');

      // ✅ FIXED NAVIGATION - Navigate to PostAdScreen directly
      if (mounted) {
        print('🏠 Navigating to PostAdScreen...');
        
        // Use Get.offAll to clear the navigation stack and go to PostAdScreen
        Get.offAll(
          () => const PostAdScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300),
        );
        
        // Small delay to ensure screen is loaded
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Show success message AFTER navigation
        Get.snackbar(
          '✅ نجح',
          'تم نشر الشقة بنجاح! يمكنك رؤيتها في قائمة شققك.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white, size: 28),
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        
        print('✅ Navigation complete');
      }
      
    } catch (e) {
      print('');
      print('❌ PUBLISH FAILED');
      print('   Error: $e');
      print('═══════════════════════════════════════════════════════════');
      
      // Show error message
      if (mounted) {
        Get.snackbar(
          '❌ خطأ',
          'فشل نشر الشقة: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white, size: 28),
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
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
            // ═══════════════════════════════════════════════════════════
            // EDIT MODE NOTICE
            // ═══════════════════════════════════════════════════════════
            
            if (widget.isEdit)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
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
                        'إضافة صور جديدة اختياري. إذا لم تختر صوراً، سيتم الاحتفاظ بالصور الحالية.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ═══════════════════════════════════════════════════════════
            // MAIN IMAGE SECTION
            // ═══════════════════════════════════════════════════════════
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'الصورة الرئيسية (اختياري - إذا لم تختر، سيتم استخدام أول صورة)',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Main image preview
            if (_selectedMainImage != null)
              Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_selectedMainImage!.path),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      
                      // Main badge
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'الصورة الرئيسية',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Remove button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _clearMainImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              )
            else
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('لا توجد صورة رئيسية', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Select main image button
            ElevatedButton.icon(
              onPressed: _isPublishing ? null : _pickMainImage,
              icon: const Icon(Icons.add_a_photo),
              label: Text(_selectedMainImage == null 
                  ? 'اختيار الصورة الرئيسية'
                  : 'تغيير الصورة الرئيسية'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 32),
            const Divider(thickness: 2),
            const SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════
            // INSIDE IMAGES SECTION
            // ═══════════════════════════════════════════════════════════

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.photo_library, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.isEdit 
                          ? 'صور الشقة من الداخل (اختياري للتحديث)'
                          : 'صور الشقة من الداخل (مطلوبة - صورة واحدة على الأقل)',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pick images button
            ElevatedButton.icon(
              onPressed: _isPublishing ? null : _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('اختيار صور الشقة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 16),

            // Images grid
            if (_selectedImages.isNotEmpty) ...[
              Text(
                'الصور المحددة (${_selectedImages.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(_selectedImages[index].path), fit: BoxFit.cover),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Warning if no images (only in create mode)
            if (!widget.isEdit && _selectedImages.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'الرجاء اختيار صور الشقة للمتابعة',
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // ═══════════════════════════════════════════════════════════
            // PUBLISH/UPDATE BUTTON
            // ═══════════════════════════════════════════════════════════

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isPublishing ? null : _publishApartment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isPublishing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('جاري المعالجة...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(widget.isEdit ? Icons.save : Icons.publish, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            widget.isEdit ? 'حفظ التعديلات' : 'نشر الشقة',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel button
            TextButton(
              onPressed: _isPublishing
                  ? null
                  : () {
                      final controller = Get.find<PostAdController>();
                      controller.cancelDraft();
                      Get.back();
                    },
              child: const Text(
                'إلغاء',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}