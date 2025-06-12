class Expert {
  final String name;
  final String speciality; // Correct spelling from 'speciality' to 'speciality'
  final String status;
  final double rating;
  final int reviews;
  final double hourlyRate;
  final bool isVerified;
  final int yearsExperience;
  final String bio;
  final String color; // Added color field
  final String profileImageUrl; // Added profileImageUrl field

  Expert({
    required this.name,
    required this.speciality,
    required this.status,
    required this.rating,
    required this.reviews,
    required this.hourlyRate,
    required this.isVerified,
    required this.yearsExperience,
    required this.bio,
    required this.color,
    required this.profileImageUrl,
  });

  // Factory constructor to create an Expert from a Map<String, dynamic>
  factory Expert.fromMap(Map<String, dynamic> map) {
    return Expert(
      name: map['name'] ?? '',
      speciality: map['speciality'] ?? '',
      status: map['status'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviews: map['reviews'] ?? 0,
      hourlyRate: (map['hourlyRate'] ?? 0).toDouble(),
      isVerified: map['isVerified'] ?? false,
      yearsExperience: map['yearsExperience'] ?? 0,
      bio: map['bio'] ?? '',
      color: map['color'] ?? '', // Default value for color
      profileImageUrl:
          map['profileImageUrl'] ?? '', // Default value for profileImageUrl
    );
  }
}
