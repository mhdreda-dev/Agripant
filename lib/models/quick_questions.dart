// Fichier: lib/models/quick_questions.dart

class QuickQuestion {
  final String question;
  final String category;

  const QuickQuestion({
    required this.question,
    required this.category,
  });
}

// Liste des questions prédéfinies pour l'assistant IA agricole
final List<QuickQuestion> quickQuestions = [
  // Questions sur les cultures
  const QuickQuestion(
    category: 'culture',
    question: 'Quels légumes puis-je planter ce mois-ci ?',
  ),
  const QuickQuestion(
    category: 'culture',
    question: 'Comment traiter les pucerons naturellement ?',
  ),
  const QuickQuestion(
    category: 'culture',
    question: 'Quelle est la meilleure façon d\'arroser mes tomates ?',
  ),
  const QuickQuestion(
    category: 'culture',
    question: 'Quand et comment tailler mes arbres fruitiers ?',
  ),

  // Questions sur les produits
  const QuickQuestion(
    category: 'produits',
    question: 'Quelle semence est recommandée pour un sol argileux ?',
  ),
  const QuickQuestion(
    category: 'produits',
    question: 'Quels engrais naturels pour mon potager bio ?',
  ),
  const QuickQuestion(
    category: 'produits',
    question: 'Quel matériel d\'irrigation économise le plus d\'eau ?',
  ),

  // Questions sur les services
  const QuickQuestion(
    category: 'services',
    question: 'Comment prendre rendez-vous avec un agronome ?',
  ),
  const QuickQuestion(
    category: 'services',
    question: 'Quand aura lieu le prochain atelier de jardinage ?',
  ),
  const QuickQuestion(
    category: 'services',
    question: 'Comment obtenir une analyse de sol personnalisée ?',
  ),

  // Questions sur la commande
  const QuickQuestion(
    category: 'commande',
    question: 'Comment suivre ma commande en cours ?',
  ),
  const QuickQuestion(
    category: 'commande',
    question: 'Comment annuler ou modifier ma commande ?',
  ),
  const QuickQuestion(
    category: 'commande',
    question: 'Quels sont les délais de livraison pour les semences ?',
  ),

  // Questions générales
  const QuickQuestion(
    category: 'general',
    question: 'Quels sont les avantages d\'être membre Premium ?',
  ),
  const QuickQuestion(
    category: 'general',
    question: 'Comment créer un calendrier de jardinage personnalisé ?',
  ),
  const QuickQuestion(
    category: 'general',
    question:
        'Quelles plantes conviennent à un jardin avec peu d\'ensoleillement ?',
  ),
];
