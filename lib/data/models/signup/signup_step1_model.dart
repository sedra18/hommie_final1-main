class SignupStep1Model {
  final String phoneNumber;

  SignupStep1Model({
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
    };
  }
}
