
import 'package:hommie/data/models/apartment/owner_apartment_model.dart';

import 'package:get/get.dart';
import 'package:hommie/data/services/owner_aparment_service.dart';
class ApartmentRepository {
  final ApartmentApi api;
  ApartmentRepository(this.api);

  
  final apartments = <OwnerApartmentModel>[].obs;

  Future<void> load() async {
    apartments.value = await api.fetchAll();
  }

  Future<void> add(OwnerApartmentModel apt) async {
    await api.create(apt);
    await load();
  }

  Future<void> edit(OwnerApartmentModel apt) async {
    await api.update(apt);
    await load();
  }

  Future<void> remove(String id) async {
    await api.delete(id);
    await load();
  }
}

