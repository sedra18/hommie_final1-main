import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/owner_apartment_model.dart';
import '../controllers/post_ad_controller.dart';
import 'apartment_images_view.dart';


class ApartmentFormView extends StatefulWidget {
  final bool isEdit;
  final OwnerApartmentModel? editingApartment;

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
    'Deir ez-Zur ',
    'Ar Raqqah',
    'Al Hasakah',
    'Idlib',
    'Daraa',
    'As Suwayda',
    'Al Qunaitra',
    ' Qamishli',
  ];
  final c = Get.find<PostAdController>();
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
      descC.text = a.description;
      selectedGovernorate = a.governorate;
      cityC.text = a.city;
      addressC.text = a.address;
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
        title: Text(
          widget.isEdit ? " Edit the apartment" : "Add info of the flat",
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _field("Title", titleC),
          _field("Description", descC, maxLines: 3),
          _field("Title", titleC),
          _field("Description", descC, maxLines: 3),

          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DropdownButtonFormField<String>(
              initialValue: selectedGovernorate,
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
          _field("Apartment Size", sizeC, keyboardType: TextInputType.number),
          const SizedBox(height: 16),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              child: Text(
                widget.isEdit ? "Next Edit photo " : "Next add photo",
              ),
              onPressed: () async {
                final price = double.tryParse(priceC.text.trim()) ?? 0;
                final rooms = int.tryParse(roomsC.text.trim()) ?? 1;
                final size = double.tryParse(sizeC.text.trim()) ?? 0;
                final gov = selectedGovernorate ?? "";

                if (widget.isEdit && widget.editingApartment != null) {
                  final a = widget.editingApartment!;
                  a.title = titleC.text.trim();
                  a.description = descC.text.trim();
                  a.governorate = gov; //
                  a.city = cityC.text.trim();
                  a.address = addressC.text.trim();
                  a.pricePerDay = price;
                  a.roomsCount = rooms;
                  a.apartmentSize = size;

                  Get.to(
                    () =>
                        ApartmentImagesView(isEdit: true, editingApartment: a),
                  );
                  return;
                }

                await c.saveDraftBasicInfo(
                  title: titleC.text.trim(),
                  description: descC.text.trim(),
                  governorate: gov,
                  city: cityC.text.trim(),
                  address: addressC.text.trim(),
                  pricePerDay: price,
                  roomsCount: rooms,
                  apartmentSize: size,
                );
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
