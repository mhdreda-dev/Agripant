// lib/models/user_model.dart
class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String city;
  final String phoneNumber;
  final String? accountType;
  final String? role;
  final String? region;
  final String? createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.phoneNumber,
    this.accountType = 'Agriculteur', // Default user type
    this.role = 'Agriculteur', // Default role
    this.region,
    this.createdAt,
    required String userType,
    required String name,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'] ?? '',
      password: map['password'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      city: map['city'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      accountType: map['accountType'] ?? 'Agriculteur',
      role: map['role'] ?? 'Agriculteur',
      region: map['region'],
      createdAt: map['createdAt'],
      userType: '',
      name: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'city': city,
      'phoneNumber': phoneNumber,
      'accountType': accountType,
      'role': role,
      'region': region,
      'createdAt': createdAt,
    };
  }

  String get fullName => '$firstName $lastName';

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? city,
    String? phoneNumber,
    String? accountType,
    String? role,
    String? region,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      city: city ?? this.city,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      accountType: accountType ?? this.accountType,
      role: role ?? this.role,
      region: region ?? this.region,
      createdAt: createdAt ?? this.createdAt,
      userType: '',
      name: '',
    );
  }
}
