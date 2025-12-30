import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'profile': 'Profile',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'language': 'Language',
      'logout': 'Logout',
      'edit_profile': 'Edit Profile',
      'notifications': 'Notifications',
    },
    'ar_SA': {
      'profile': 'الملف الشخصي',
      'dark_mode': 'الوضع الداكن',
      'light_mode': 'الوضع الفاتح',
      'language': 'اللغة',
      'logout': 'تسجيل الخروج',
      'edit_profile': 'تعديل الملف الشخصي',
      'notifications': 'الإشعارات',
    },
  };
}
