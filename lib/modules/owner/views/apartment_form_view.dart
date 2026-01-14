import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';  // ✅ Changed
import '../controllers/post_ad_controller.dart';
import 'apartment_images_view.dart';

// ═══════════════════════════════════════════════════════════
// APARTMENT FORM VIEW - FIXED
// Uses ApartmentModel (not OwnerApartmentModel)
// ═══════════════════════════════════════════════════════════

class ApartmentFormView extends StatefulWidget {
  final bool isEdit;
  final ApartmentModel? editingApartment;  // ✅ Changed type

  const ApartmentFormView({
    super.key,
    required this.isEdit,
    this.editingApartment,
  });

  @override
  State<ApartmentFormView> createState() => _ApartmentFormViewState();
}

class _ApartmentFormViewState extends State<ApartmentFormView> {
  List<String> governorates = [
    'Damascus',
    'Aleppo',
    'Homs',
    'Hama',
    'Lattakia',
    'Tartus',
    'Deir ez-Zur',
    'Ar Raqqah',
    'Al Hasakah',
    'Idlib',
    'Daraa',
    'As Suwayda',
    'Al Qunaitra',
    'Qamishli',
  ];
  
  final c = Get.put(PostAdController());
  final titleC = TextEditingController();
  final descC = TextEditingController();
  String? selectedGovernorate;
  final cityC = TextEditingController();
  final addressC = TextEditingController();
  final priceC = TextEditingController();
  final roomsC = TextEditingController();
  final sizeC = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.editingApartment != null) {
      final a = widget.editingApartment!;
      titleC.text = a.title;
      descC.text = a.description ?? '';  // ✅ Handle nullable
      selectedGovernorate = a.governorate;  // Already nullable
      cityC.text = a.city;
      addressC.text = a.address ?? '';  // ✅ Handle nullable
      priceC.text = a.pricePerDay.toString();
      roomsC.text = a.roomsCount.toString();
      sizeC.text = a.apartmentSize.toString();
    }
  }

  @override
  void dispose() {
    titleC.dispose();
    descC.dispose();
    cityC.dispose();
    addressC.dispose();
    priceC.dispose();
    roomsC.dispose();
    sizeC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
        title: Text(
          widget.isEdit ? "Edit the apartment" : "Add info of the flat",
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _field("Title", titleC),
          _field("Description", descC, maxLines: 3),

          // Governorate Dropdown
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DropdownButtonFormField<String>(
              value: selectedGovernorate,
              hint: const Text("Choose the governorate"),
              decoration: const InputDecoration(
                labelText: "Governorate",
                border: OutlineInputBorder(),
              ),
              items: governorates.map((governorate) {
                return DropdownMenuItem(
                  value: governorate,
                  child: Text(governorate),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedGovernorate = value;
                });
              },
            ),
          ),

          _field("City", cityC),
          _field("Address", addressC),
          _field("Price Per Day", priceC, keyboardType: TextInputType.number),
          _field("Rooms Count", roomsC, keyboardType: TextInputType.number),
          _field("Apartment Size (m²)", sizeC, keyboardType: TextInputType.number),
          
          const SizedBox(height: 24),

          // Next Button
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                widget.isEdit ? "Next: Edit photos" : "Next: Add photos",
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Validate
                if (titleC.text.trim().isEmpty) {
                  Get.snackbar(
                    'خطأ',
                    'الرجاء إدخال عنوان الشقة',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                final price = int.tryParse(priceC.text.trim()) ?? 0;
                final rooms = int.tryParse(roomsC.text.trim()) ?? 1;
                final size = int.tryParse(sizeC.text.trim()) ?? 0;
                final gov = selectedGovernorate ?? "";

                if (price <= 0) {
                  Get.snackbar(
                    'خطأ',
                    'الرجاء إدخال سعر صحيح',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                // Edit mode (not currently used in this flow)
                if (widget.isEdit && widget.editingApartment != null) {
                  // TODO: Implement edit functionality
                  Get.snackbar(
                    'قريباً',
                    'ميزة التعديل قيد التطوير',
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                  );
                  return;
                }

                // Save draft and navigate to images
                c.saveDraftBasicInfo(
                  title: titleC.text.trim(),
                  description: descC.text.trim(),
                  governorate: gov,
                  city: cityC.text.trim(),
                  address: addressC.text.trim(),
                  pricePerDay: price,
                  roomsCount: rooms,
                  apartmentSize: size,
                );

                // Navigate to images view
                Get.to(() => const ApartmentImagesView(isEdit: false));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}