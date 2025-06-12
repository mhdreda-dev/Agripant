import '../models/expert.dart';

// Notez que vous devrez ajouter ces images dans votre dossier assets/images/
// et les déclarer dans pubspec.yaml sous la section assets

final List<Expert> experts = [
  Expert(
    name: 'Dr. Ahmed Benali',
    speciality: 'Agriculture de précision',
    status: 'Disponible',
    rating: 4.9,
    reviews: 124,
    hourlyRate: 450,
    isVerified: true,
    yearsExperience: 15,
    bio:
        'Spécialiste en technologies d\'agriculture de précision avec plus de 15 ans d\'expérience. Expert en télédétection, drones agricoles et systèmes d\'information géographique.',
    color: '0xFF4CAF50', // Vert
    profileImageUrl: 'assets/profile/profile1.jpeg',
  ),
  Expert(
    name: 'Youssef El Mansouri',
    speciality: 'Viticulture',
    status: 'Occupé',
    rating: 4.8,
    reviews: 94,
    hourlyRate: 420,
    isVerified: true,
    yearsExperience: 14,
    bio:
        'Viticulteur expérimenté spécialisé dans les cépages adaptés au climat marocain et les techniques de vinification modernes.',
    color: '0xFF673AB7', // Indigo
    profileImageUrl: 'assets/images/profile7.jpg',
  ),
  Expert(
    name: 'Samira Alaoui',
    speciality: 'Plantes aromatiques et médicinales',
    status: 'Disponible',
    rating: 4.6,
    reviews: 79,
    hourlyRate: 340,
    isVerified: false,
    yearsExperience: 9,
    bio:
        'Spécialiste en culture et transformation de plantes aromatiques et médicinales. Expertise en extraction d\'huiles essentielles.',
    color: '0xFFCDDC39', // Lime
    profileImageUrl: 'assets/profile/profile14.jpeg',
  ),
  Expert(
    name: 'Omar Laarbi',
    speciality: 'Élevage durable',
    status: 'Disponible',
    rating: 4.8,
    reviews: 103,
    hourlyRate: 400,
    isVerified: true,
    yearsExperience: 18,
    bio:
        'Expert en techniques d\'élevage durable avec une approche holistique. Spécialiste en gestion des pâturages et bien-être animal.',
    color: '0xFFFF9800', // Orange
    profileImageUrl: 'assets/profile/profile3.jpg',
  ),
  Expert(
    name: 'Amina Berrada',
    speciality: 'Permaculture',
    status: 'Indisponible',
    rating: 4.6,
    reviews: 76,
    hourlyRate: 350,
    isVerified: false,
    yearsExperience: 8,
    bio:
        'Passionnée de permaculture et d\'agriculture régénérative. Formatrice en conception de systèmes agricoles durables.',
    color: '0xFF8BC34A', // Vert clair
    profileImageUrl: 'assets/images/profile4.jpg',
  ),
  Expert(
    name: 'Karim Tazi',
    speciality: 'Semences et Génétique',
    status: 'Disponible',
    rating: 4.9,
    reviews: 112,
    hourlyRate: 480,
    isVerified: true,
    yearsExperience: 20,
    bio:
        'Généticien spécialisé dans l\'amélioration des cultures. Expert en sélection variétale adaptée aux conditions climatiques marocaines.',
    color: '0xFF9C27B0', // Violet
    profileImageUrl: 'assets/images/profile5.jpeg',
  ),
  Expert(
    name: 'Leila Mahmoud',
    speciality: 'Agriculture urbaine',
    status: 'Disponible',
    rating: 4.5,
    reviews: 65,
    hourlyRate: 320,
    isVerified: false,
    yearsExperience: 6,
    bio:
        'Spécialiste de l\'agriculture en milieu urbain, hydroponie et jardins verticaux. Conseillère en agriculture urbaine productive.',
    color: '0xFFFF5722', // Orange foncé
    profileImageUrl: 'assets/images/profile6.jpeg',
  ),
  Expert(
    name: 'Youssef El Mansouri',
    speciality: 'Viticulture',
    status: 'Occupé',
    rating: 4.8,
    reviews: 94,
    hourlyRate: 420,
    isVerified: true,
    yearsExperience: 14,
    bio:
        'Viticulteur expérimenté spécialisé dans les cépages adaptés au climat marocain et les techniques de vinification modernes.',
    color: '0xFF673AB7', // Indigo
    profileImageUrl: 'assets/images/profile7.jpg',
  ),
  Expert(
    name: 'Nadia Chakir',
    speciality: 'Agroécologie',
    status: 'Disponible',
    rating: 4.7,
    reviews: 82,
    hourlyRate: 380,
    isVerified: true,
    yearsExperience: 10,
    bio:
        'Experte en pratiques agroécologiques combinant productivité agricole et respect des écosystèmes naturels.',
    color: '0xFF009688', // Vert sarcelle
    profileImageUrl: 'assets/images/profile8.png',
  ),
  Expert(
    name: 'Sami El Khatib',
    speciality: 'Gestion des ressources en eau',
    status: 'Disponible',
    rating: 4.6,
    reviews: 55,
    hourlyRate: 400,
    isVerified: true,
    yearsExperience: 13,
    bio:
        'Expert en gestion des ressources en eau pour l\'agriculture durable, spécialisé dans les techniques d\'irrigation et la conservation de l\'eau.',
    color: '0xFF03A9F4', // Bleu clair
    profileImageUrl: 'assets/images/profile9.png',
  ),
  Expert(
    name: 'Rania El Khoury',
    speciality: 'Agriculture biologique',
    status: 'Indisponible',
    rating: 4.9,
    reviews: 132,
    hourlyRate: 450,
    isVerified: true,
    yearsExperience: 18,
    bio:
        'Agricultrice et conseillère en agriculture biologique. Spécialiste en certification bio et en pratiques agricoles respectueuses de l\'environnement.',
    color: '0xFFE91E63', // Rose
    profileImageUrl: 'assets/images/profile10.png',
  ),
  Expert(
    name: 'Hassan Ouazzani',
    speciality: 'Arboriculture fruitière',
    status: 'Disponible',
    rating: 4.8,
    reviews: 107,
    hourlyRate: 410,
    isVerified: true,
    yearsExperience: 16,
    bio:
        'Spécialiste en arboriculture fruitière adaptée aux climats méditerranéens et semi-arides. Expert en techniques de taille et de greffage.',
    color: '0xFF795548', // Marron
    profileImageUrl: 'assets/images/profile11.png',
  ),
  Expert(
    name: 'Salma Bennani',
    speciality: 'Cultures biologiques',
    status: 'Disponible',
    rating: 4.7,
    reviews: 91,
    hourlyRate: 370,
    isVerified: true,
    yearsExperience: 11,
    bio:
        'Experte en conversion à l\'agriculture biologique et certification. Spécialiste des techniques culturales sans produits chimiques.',
    color: '0xFF8D6E63', // Marron clair
    profileImageUrl: 'assets/images/profile12.png',
  ),
  Expert(
    name: 'Mehdi El Fassi',
    speciality: 'Apiculture',
    status: 'Occupé',
    rating: 4.9,
    reviews: 118,
    hourlyRate: 390,
    isVerified: true,
    yearsExperience: 14,
    bio:
        'Apiculteur professionnel spécialisé dans la production de miel de qualité et la protection des abeilles. Expert en pollinisation des cultures.',
    color: '0xFFFFEB3B', // Jaune
    profileImageUrl: 'assets/images/profile13.png',
  ),
  Expert(
    name: 'Fatima Zahra',
    speciality: 'Irrigation',
    status: 'Occupé',
    rating: 4.7,
    reviews: 89,
    hourlyRate: 380,
    isVerified: true,
    yearsExperience: 12,
    bio:
        'Ingénieure spécialisée dans les systèmes d\'irrigation économes en eau et les technologies de conservation hydrique pour l\'agriculture.',
    color: '0xFF2196F3', // Bleu
    profileImageUrl: 'assets/images/profile2.jpg',
  ),
  Expert(
    name: 'Rachid El Amrani',
    speciality: 'Oléiculture',
    status: 'Disponible',
    rating: 4.8,
    reviews: 105,
    hourlyRate: 430,
    isVerified: true,
    yearsExperience: 19,
    bio:
        'Expert en culture d\'oliviers et production d\'huile d\'olive. Spécialiste des techniques modernes de récolte et d\'extraction.',
    color: '0xFF3F51B5', // Indigo
    profileImageUrl: 'assets/images/profile15.png',
  ),
];

final List<String> expertSpecialities = [
  'Agriculture de précision',
  'Irrigation',
  'Élevage durable',
  'Permaculture',
  'Semences et Génétique',
  'Agriculture urbaine',
  'Viticulture',
  'Agroécologie',
  'Gestion des ressources en eau',
  'Agriculture biologique',
  'Arboriculture fruitière',
  'Cultures biologiques',
  'Apiculture',
  'Plantes aromatiques et médicinales',
  'Oléiculture',
];
