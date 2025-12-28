import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/repositories/apartment_repository.dart';
import 'package:hommie/modules/auth/views/loginscreen.dart';
import 'package:hommie/widgets/apartment_card.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _HomeViewState();
}

class _HomeViewState extends State<OwnerHomeScreen>
    with AutomaticKeepAliveClientMixin {
  final repo = Get.find<ApartmentRepository>();
  final box = GetStorage();

  bool hasToken = false;
  bool _initialized = false;

  @override
  bool get wantKeepAlive => true; // Keep state alive

  @override
  void initState() {
    super.initState();
    _initializeOnce();
  }

  void _initializeOnce() {
    if (_initialized) return;
    _initialized = true;

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🏠 OWNER HOME SCREEN - INITIALIZING (ONCE)');
    print('──────────────────────────────────────────────────────────');

    final token = box.read('access_token');
    final isApproved = box.read('is_approved') ?? false;

    hasToken = token != null;

    print('   Token: ${hasToken ? "Present" : "Missing"}');
    print('   Is Approved: $isApproved');

    if (hasToken) {
      print(' Loading apartments...');
      Future.microtask(() {
        if (mounted) repo.load();
      });
    } else {
      print('  No token - Showing login prompt');
    }

    print('═══════════════════════════════════════════════════════════');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home "),
        backgroundColor: AppColors.primary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!hasToken) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "يرجى تسجيل الدخول لعرض الشقق",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "قم بتسجيل الدخول للوصول إلى شققك",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Get.offAll(LoginScreen()),
                icon: const Icon(Icons.login),
                label: const Text('تسجيل الدخول'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Obx(() {
      final apartmentsList = repo.apartments;

      if (apartmentsList.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "لا توجد شقق بعد",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "أضف شقتك الأولى للبدء",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: apartmentsList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => ApartmentCard(
          apartment: apartmentsList[i],
          showOwnerActions: false,
        ),
      );
    });
  }
}
