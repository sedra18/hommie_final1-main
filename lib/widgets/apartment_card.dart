import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/owner_apartment_model.dart';
import 'package:hommie/modules/owner/controllers/post_ad_controller.dart';
import 'package:hommie/modules/owner/views/apartment_form_view.dart';


class ApartmentCard extends StatelessWidget {
  final OwnerApartmentModel apartment;
  final bool showOwnerActions;

  const ApartmentCard({
    super.key,
    required this.apartment,
    required this.showOwnerActions,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PostAdController>();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    apartment.title.isEmpty ? "(بدون عنوان)" : apartment.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Text("${apartment.pricePerDay.toStringAsFixed(0)} / day"),
              ],
            ),
            const SizedBox(height: 6),

            Text(
              "${apartment.governorate} - ${apartment.city}",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 6),

            Text(
              apartment.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            // تفاصيل صغيرة
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _chip("Rooms: ${apartment.roomsCount}"),
                _chip("Size: ${apartment.apartmentSize}"),
                _chip("Images: ${apartment.images.length}"),
              ],
            ),
            if (showOwnerActions) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("تعديل"),
                    onPressed: () {
                      Get.to(() => ApartmentFormView(
                            isEdit: true,
                            editingApartment: apartment,
                          ));
                    },
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text("حذف"),
                    onPressed: () async {
                      await c.deleteApartment(apartment.id);
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}