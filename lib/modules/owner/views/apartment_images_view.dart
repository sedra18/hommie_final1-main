import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/owner_apartment_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../controllers/post_ad_controller.dart';


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

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.editingApartment != null) {
      final a = widget.editingApartment!;

    }

    _selectedImages = [];
    _selectedMainImage = null;
  }

Future<void> _pickImages() async {
  final List<XFile> images = await _picker.pickMultiImage();
  if (images != null && images.isNotEmpty) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add images")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text("Choose from gallery"),
          const SizedBox(height: 10),

          // Selected Images Preview
          if (_selectedImages.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Chosen images", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
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
            onPressed: _pickImages,
            icon: const Icon(Icons.photo_library),
            label: const Text("adding pictures"),
          ),

          const SizedBox(height: 24),

          const Text("choose the main image"),
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
                TextButton.icon(
                  onPressed: _clearMainImage,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(" remove the main picture", style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 16),
              ],
            ),

          ElevatedButton.icon(
            onPressed: _pickMainImage,
            icon: const Icon(Icons.add_a_photo),
            label: const Text(" choose the main picture "),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              child: Text(widget.isEdit ? "Save Edit and back" : "Publish apartment and back"),
              onPressed: () async {
                if (_selectedImages.isEmpty) {
                  Get.snackbar("warning", "Please choose images for the flat");
                  return;
                }


                await c.saveDraftImagesFromFiles(
                  imageFiles: _selectedImages,
                  mainImageFile: _selectedMainImage,
                );

                await c.publishDraft();
                Get.back();
                Get.back();
              },
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