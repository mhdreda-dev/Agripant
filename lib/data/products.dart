import '../models/product.dart';

List<Product> products = [
  // MACHINES
  const Product(
    name: "Tracteur agricole",
    description:
        "Découvrez la puissance de l'agriculture moderne avec notre tracteur robuste. Idéal pour tous vos travaux agricoles, ce tracteur combine puissance, fiabilité et confort pour une productivité maximale.",
    image: 'assets/tractor.jpg',
    price: 377.00,
    unit: 'jour(s)',
    rating: 4.35,
    category: 'Machines',
    isFeatured: true,
    id: '',
  ),
  const Product(
    name: "Moissonneuse-batteuse",
    description:
        "Optimisez votre récolte avec notre moissonneuse-batteuse de haute performance. Conçue pour les agriculteurs professionnels, elle garantit une récolte rapide et efficace.",
    image: 'assets/harvester.jpg',
    price: 450.00,
    unit: 'jour(s)',
    rating: 4.7,
    category: 'Machines',
    isFeatured: false,
    id: '',
  ),
  const Product(
    name: "Motoculteur",
    description:
        "Facilitez le travail du sol avec notre motoculteur puissant. Parfait pour les petites et moyennes exploitations, il vous aide à préparer votre terrain rapidement.",
    image: 'assets/cultivator.jpg',
    price: 89.50,
    unit: 'jour(s)',
    rating: 4.2,
    category: 'Machines',
    isFeatured: false,
    id: '',
  ),

  // FRUITS
  const Product(
    name: "Fruits frais assortis",
    description:
        "Savourez la douceur naturelle de nos fruits soigneusement sélectionnés. Cueillis à parfaite maturité, nos fruits sont riches en saveurs et en nutriments essentiels.",
    image: 'assets/fruit.jpg',
    price: 9.99,
    unit: 'kg',
    rating: 3.86,
    category: 'Fruits',
    isFeatured: true,
    id: '',
  ),
  const Product(
    name: "Pommes Bio",
    description:
        "Nos pommes biologiques sont cultivées sans pesticides pour vous offrir un fruit sain et délicieux. Parfaites pour une collation ou pour vos desserts maison.",
    image: 'assets/apples.jpg',
    price: 4.50,
    unit: 'kg',
    rating: 4.6,
    category: 'Fruits',
    isFeatured: true,
    id: '',
  ),
  const Product(
    name: "Fraises de saison",
    description:
        "Profitez de la douceur de nos fraises fraîches de saison. Cultivées localement, elles sont cueillies à maturité pour préserver leur saveur unique.",
    image: 'assets/strawberries.jpg',
    price: 7.25,
    unit: 'kg',
    rating: 4.8,
    category: 'Fruits',
    isFeatured: false,
    id: '',
  ),

  // OUTILS
  const Product(
    name: "Râteau de jardinier",
    description:
        "Maintenez un jardin impeccable avec notre râteau de qualité supérieure. Conçu pour durer, il vous accompagnera dans tous vos travaux de jardinage.",
    image: 'assets/rake.jpg',
    price: 8.44,
    unit: 'pièce',
    rating: 4.18,
    category: 'Outils',
    isFeatured: true,
    id: '',
  ),
  const Product(
    name: "Pelle robuste",
    description:
        "Réalisez vos travaux de paysagisme et de jardinage avec notre pelle durable. Sa conception ergonomique réduit la fatigue et améliore l'efficacité.",
    image: 'assets/shovel.jpg',
    price: 14.77,
    unit: 'pièce',
    rating: 5.0,
    category: 'Outils',
    isFeatured: true,
    id: '',
  ),
  const Product(
    name: "Sécateur professionnel",
    description:
        "Taillez vos plantes avec précision grâce à notre sécateur professionnel. Sa lame en acier trempé assure une coupe nette et précise à chaque utilisation.",
    image: 'assets/pruner.jpg',
    price: 12.95,
    unit: 'pièce',
    rating: 4.3,
    category: 'Outils',
    isFeatured: false,
    id: '',
  ),
  const Product(
    name: "Kit d'outils de jardinage",
    description:
        "Équipez-vous pour tous vos projets de jardinage avec notre kit complet d'outils. Comprend une truelle, un transplantoir, un cultivateur et des gants de qualité.",
    image: 'assets/garden_tools.jpg',
    price: 29.99,
    unit: 'kit',
    rating: 4.5,
    category: 'Outils',
    isFeatured: true,
    id: '',
  ),

  // SEMENCES
  const Product(
    name: "Semences premium",
    description:
        "Lancez-vous dans la culture avec notre collection de semences premium. Sélectionnées pour leur qualité exceptionnelle, elles garantissent une germination optimale.",
    image: 'assets/seeds.jpg',
    price: 14.52,
    unit: 'kg',
    rating: 5.0,
    category: 'Semences',
    isFeatured: true,
    id: '',
  ),
  const Product(
    name: "Semences de légumes Bio",
    description:
        "Cultivez votre propre potager bio avec nos semences de légumes certifiées biologiques. Un assortiment varié pour une récolte abondante toute l'année.",
    image: 'assets/veggie_seeds.jpg',
    price: 6.75,
    unit: 'paquet',
    rating: 4.4,
    category: 'Semences',
    isFeatured: false,
    id: '',
  ),
  const Product(
    name: "Semences de fleurs sauvages",
    description:
        "Créez un paradis pour les pollinisateurs avec nos semences de fleurs sauvages. Idéales pour les jardins naturels et la biodiversité.",
    image: 'assets/wildflower_seeds.jpg',
    price: 5.99,
    unit: 'paquet',
    rating: 4.2,
    category: 'Semences',
    isFeatured: true,
    id: '',
  ),

  // LÉGUMES
  const Product(
    name: "Tomates juteuses",
    description:
        "Ajoutez une touche de couleur et de saveur à vos plats avec nos tomates juteuses. Cultivées avec soin, elles sont parfaites pour vos salades et sauces maison.",
    image: 'assets/tomato.jpg',
    price: 6.84,
    unit: 'kg',
    rating: 3.22,
    category: 'Légumes',
    isFeatured: true,
    id: '',
  ),
  const Product(
    name: "Carottes fraîches",
    description:
        "Nos carottes fraîches sont riches en nutriments et en saveur. Idéales pour vos salades, soupes ou en accompagnement de vos plats principaux.",
    image: 'assets/carrots.jpg',
    price: 3.49,
    unit: 'kg',
    rating: 4.1,
    category: 'Légumes',
    isFeatured: false,
    id: '',
  ),
  const Product(
    name: "Pommes de terre",
    description:
        "Découvrez la polyvalence de nos pommes de terre de qualité. Cultivées dans des sols riches, elles sont parfaites pour tous vos plats, des frites aux purées.",
    image: 'assets/potatoes.jpg',
    price: 2.99,
    unit: 'kg',
    rating: 4.0,
    category: 'Légumes',
    isFeatured: true,
    id: '',
  ),

  // ENGRAIS
  const Product(
    name: "Engrais organique",
    description:
        "Nourrissez vos plantes naturellement avec notre engrais 100% organique. Formulé pour améliorer la fertilité du sol et favoriser une croissance saine.",
    image: 'assets/organic_fertilizer.png',
    price: 19.99,
    unit: 'sac',
    rating: 4.7,
    category: 'Engrais',
    isFeatured: true,
    id: '',
  ),
  const Product(
    name: "Compost premium",
    description:
        "Enrichissez votre sol avec notre compost de qualité supérieure. Riche en matière organique, il améliore la structure du sol et nourrit vos plantes.",
    image: 'assets/compost.jpg',
    price: 12.50,
    unit: 'sac',
    rating: 4.5,
    category: 'Engrais',
    isFeatured: false,
    id: '',
  ),
  const Product(
    name: "Engrais liquide universel",
    description:
        "Solution nutritive complète pour tous types de plantes. Facile à appliquer, cet engrais liquide assure une absorption rapide des nutriments.",
    image: 'assets/liquid_fertilizer.jpg',
    price: 8.75,
    unit: 'litre',
    rating: 4.3,
    category: 'Engrais',
    isFeatured: true,
    id: '',
  ),

  // PROTECTION
  const Product(
    name: "Insecticide naturel",
    description:
        "Protégez vos cultures contre les insectes nuisibles avec notre solution naturelle. Sans danger pour l'environnement et les organismes bénéfiques.",
    image: 'assets/natural_insecticide.jpg',
    price: 14.99,
    unit: 'litre',
    rating: 4.2,
    category: 'Protection',
    isFeatured: true,
    id: '',
  ),
  const Product(
    name: "Filet anti-oiseaux",
    description:
        "Préservez vos fruits et légumes des oiseaux avec notre filet de protection. Léger mais résistant, il s'installe facilement sur vos arbres et cultures.",
    image: 'assets/bird_net.jpg',
    price: 9.95,
    unit: 'pièce',
    rating: 4.0,
    category: 'Protection',
    isFeatured: false,
    id: '',
  ),
  const Product(
    name: "Barrière anti-limaces",
    description:
        "Solution écologique pour protéger vos plantations contre les limaces et escargots. Créez une barrière infranchissable sans produits chimiques nocifs.",
    image: 'assets/slug_barrier.jpg',
    price: 7.50,
    unit: 'paquet',
    rating: 3.9,
    category: 'Protection',
    isFeatured: true,
    id: '',
  ),
];
