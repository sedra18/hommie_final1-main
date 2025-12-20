class UserLoginModel {
  final String phone;
  final String password;

  UserLoginModel({required this.phone, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'password': password,
    };
  }
}