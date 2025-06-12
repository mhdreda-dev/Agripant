class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role; // 'farmer' or 'buyer'
  final DateTime createdAt;
  final String? phoneNumber;
  final String? city;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.createdAt,
    this.phoneNumber,
    this.city,
  });
}
