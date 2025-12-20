enum UserRole {
  owner,
  renter
}

class SignupStep2Model {
  final String email;
  final String password;
  final UserRole role;

  SignupStep2Model({
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'role': role.name, 
    };
  }
}