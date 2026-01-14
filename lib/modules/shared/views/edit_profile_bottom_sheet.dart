import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/modules/shared/controllers/profile_controller.dart';
import 'package:hommie/widgets/profile_dialogs.dart';

class EditProfileBottomSheet extends StatefulWidget {
  const EditProfileBottomSheet({super.key});

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _profileController = Get.find<ProfileController>();
  int _selectedSection = 0; // 0=معلوماتي, 1=الأمان, 2=الحساب

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Text(
            '⚙️ إعدادات الحساب',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'إدارة معلوماتك وأمان حسابك',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 30),

          // Row 1: معلوماتي + الأمان
          Row(
            children: [
              // معلوماتي Card
              Expanded(
                child: _buildSectionCard(
                  icon: Icons.person,
                  title: 'معلوماتي',
                  subtitle: 'الاسم، الهاتف، الصورة',
                  isSelected: _selectedSection == 0,
                  onTap: () => setState(() => _selectedSection = 0),
                ),
              ),
              const SizedBox(width: 15),

              // الأمان Card
              Expanded(
                child: _buildSectionCard(
                  icon: Icons.lock,
                  title: 'الأمان',
                  subtitle: 'البريد، كلمة المرور',
                  isSelected: _selectedSection == 1,
                  onTap: () => setState(() => _selectedSection = 1),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // الحساب Card (كبير)
          _buildSectionCard(
            icon: Icons.settings,
            title: 'الحساب',
            subtitle: 'حذف الحساب والإعدادات',
            isSelected: _selectedSection == 2,
            onTap: () => setState(() => _selectedSection = 2),
            isLarge: true,
          ),

          const SizedBox(height: 30),

          // Content Area (ديناميكي)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildContentForSection(_selectedSection),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Get.isDarkMode
              ? Colors.grey[900]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[700],
                size: isLarge ? 28 : 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isLarge ? 18 : 16,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              const SizedBox(height: 10),
              Container(
                width: 30,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContentForSection(int section) {
    switch (section) {
      case 0: // معلوماتي
        return _buildPersonalInfoContent();
      case 1: // الأمان
        return _buildSecurityContent();
      case 2: // الحساب
        return _buildAccountContent();
      default:
        return Container();
    }
  }

  // ============================================
  // 🧑 محتوى "معلوماتي" - كامل ومعدل
  // ============================================
  Widget _buildPersonalInfoContent() {
    final _nameController = TextEditingController(
      text: _profileController.fullName,
    );
    var _isSaving = false.obs;

    return Obx(
      () => Column(
        children: [
          const SizedBox(height: 20),
          // 🔥 صورة البروفايل مع زر التعديل
          GestureDetector(
            onTap: () {
              print('🖼 زر الصورة مضغوط');
              ProfileDialogs.showAvatarUpdateDialog(context);
            },
            child:
                _profileController.avatarUrl != null &&
                    _profileController.avatarUrl!.isNotEmpty
                ? ClipOval(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(55),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: _profileController.avatarUrl!,
                        httpHeaders: () {
                          final token = _profileController.box.read(
                            'access_token',
                          );
                          if (token != null) {
                            return {'Authorization': 'Bearer $token'};
                          }
                          return <String, String>{};
                        }(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          print('❌ خطأ في تحميل الصورة: $error');
                          return _buildDefaultIcon();
                        },
                      ),
                    ),
                  )
                : _buildDefaultIcon(),
          ),
          const SizedBox(height: 12),
          Text(
            'انقر على الصورة لتغييرها',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 25),

          // العنوان
          Text(
            'معلوماتك الشخصية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // الاسم
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'الاسم الكامل',
              prefixIcon: Icon(Icons.person, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),
          // 📱 الهاتف مع زر التغيير
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.phone, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رقم الهاتف',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _profileController.phone,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ProfileDialogs.showPhoneUpdateDialog(context);
                  },
                  child: Text(
                    'تغيير',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🆔 صورة الهوية
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.badge, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'صورة الهوية',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _profileController.userData['data']?['id_image'] != null
                            ? 'مرفوعة ✅'
                            : 'غير مرفوعة ❌',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              _profileController
                                      .userData['data']?['id_image'] !=
                                  null
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ProfileDialogs.showIdImageUpdateDialog(
                      context,
                    ); // ✅ أضيفي هذا السطر
                  },
                  child: Text(
                    'تغيير',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // زر الحفظ
          Obx(
            () => ElevatedButton(
              onPressed: _isSaving.value
                  ? null
                  : () async {
                      if (_nameController.text.isEmpty) {
                        Get.snackbar('خطأ', 'الاسم مطلوب');
                        return;
                      }

                      _isSaving.value = true;
                      final names = _nameController.text.split(' ');
                      final success = await _profileController.updateName(
                        names.isNotEmpty ? names[0] : '',
                        names.length > 1 ? names[1] : '',
                      );

                      _isSaving.value = false;

                      if (success) {
                        Get.snackbar(
                          'تم ✅',
                          'تم تحديث المعلومات',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } else {
                        Get.snackbar(
                          'خطأ ❌',
                          'فشل تحديث المعلومات',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'حفظ التغييرات',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 🔐 محتوى "الأمان"
  // ============================================
  Widget _buildSecurityContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'أمان حسابك',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),

        // تغيير البريد
        Card(
          child: ListTile(
            leading: Icon(Icons.email, color: AppColors.primary),
            title: Text('تغيير البريد الإلكتروني'),
            subtitle: Obx(
              () => Text(
                _profileController.email,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ProfileDialogs.showEmailUpdateDialog(context);
            },
          ),
        ),

        const SizedBox(height: 10),

        // تغيير كلمة المرور
        Card(
          child: ListTile(
            leading: Icon(Icons.lock, color: AppColors.primary),
            title: Text('تغيير كلمة المرور'),
            subtitle: Text('تعيين كلمة مرور جديدة'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ProfileDialogs.showPasswordUpdateDialog(context);
            },
          ),
        ),

        const SizedBox(height: 30),
        Text(
          'تأكد من استخدام كلمة مرور قوية',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  // ============================================
  // ⚙️ محتوى "الحساب"
  // ============================================
  Widget _buildAccountContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'إدارة حسابك',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        // معلومات الحساب
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.person, color: Colors.grey),
                title: Text('الاسم'),
                trailing: Obx(() => Text(_profileController.fullName)),
              ),
              ListTile(
                leading: Icon(Icons.email, color: Colors.grey),
                title: Text('البريد'),
                trailing: Obx(() => Text(_profileController.email)),
              ),
              ListTile(
                leading: Icon(Icons.phone, color: Colors.grey),
                title: Text('الهاتف'),
                trailing: Obx(() => Text(_profileController.phone)),
              ),
              ListTile(
                leading: Icon(Icons.category, color: Colors.grey),
                title: Text('نوع الحساب'),
                trailing: Obx(
                  () => Text(
                    _profileController.isOwner ? 'مالك' : 'مستأجر',
                    style: TextStyle(
                      color: _profileController.isOwner
                          ? Colors.green
                          : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // زر حذف الحساب
        OutlinedButton(
          onPressed: () {
            ProfileDialogs.showDeleteAccountDialog(context);
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: Text('حذف الحساب', style: TextStyle(color: Colors.red)),
        ),

        const SizedBox(height: 10),
        Text(
          'تحذير: لا يمكن التراجع عن هذا الإجراء',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إعدادات الحساب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Content
          Expanded(child: _buildDashboard()),
        ],
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Icon(Icons.person, size: 60, color: AppColors.primary),
    );
  }
}