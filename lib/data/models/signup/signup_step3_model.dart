class SignupStep3Model {
  final int pendingUserId;
  final String firstName;
  final String lastName;
  final String dateOfBirth;

  SignupStep3Model({
    required this.pendingUserId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'pending_user_id': pendingUserId,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': dateOfBirth,
    };
  }
}
