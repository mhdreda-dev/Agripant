class Expert {
  final String name;
  final String specialty;
  final double rating;
  final String experience;
  final String bio;
  final String consultationPrice;
  final bool isAvailable;
  final bool isVerified;
  final String
      color; // Can store color as a String (Hex) or Color depending on your needs
  final String profileImageUrl;

  // Constructor
  Expert({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.experience,
    required this.bio,
    required this.consultationPrice,
    required this.isAvailable,
    required this.isVerified,
    required this.color,
    required this.profileImageUrl,
  });

  // Factory constructor to create Expert from a Map
  factory Expert.fromMap(Map<String, dynamic> map) {
    return Expert(
      name: map['name'],
      specialty: map['specialty'],
      rating: map['rating'],
      experience: map['experience'],
      bio: map['bio'],
      consultationPrice: map['consultationPrice'],
      isAvailable: map['isAvailable'],
      isVerified: map['isVerified'],
      color: map['color'],
      profileImageUrl: map['profileImageUrl'],
    );
  }
}
