import 'package:agriplant/data/experts.dart';
import 'package:agriplant/widgets/expert_profiles_row.dart';
import 'package:agriplant/widgets/hero_banner.dart';
import 'package:agriplant/widgets/popular_products_slider.dart';
import 'package:flutter/material.dart';

import '../data/products.dart';
import '../models/product.dart'; // Import du modèle Product
import '../screens/experts_list_screen.dart';
import '../screens/services_list_screen.dart';
import 'explore_page.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with AutomaticKeepAliveClientMixin {
  // Configuration
  static const Duration _refreshDuration = Duration(milliseconds: 1500);
  static const EdgeInsets _defaultPadding = EdgeInsets.all(16);
  static const double _sectionSpacing = 24.0;
  static const double _itemSpacing = 12.0;

  // État
  bool _isRefreshing = false;
  late final List<Product> _featuredProducts;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _featuredProducts = products.where((p) => p.isFeatured).toList();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await Future.delayed(_refreshDuration);
      // Ici vous pouvez ajouter la logique de rafraîchissement des données
      _initializeData();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Theme.of(context).primaryColor,
      child: ListView(
        padding: _defaultPadding,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildHeroSection(),
          const SizedBox(height: _sectionSpacing),
          _buildExpertsSection(),
          const SizedBox(height: _sectionSpacing),
          buildPopularProductsSection(),
          const SizedBox(height: _sectionSpacing),
          _buildServicesSection(),
          const SizedBox(height: _sectionSpacing),
          _buildBlogSection(),
          const SizedBox(height: _sectionSpacing), // Padding bottom
        ],
      ),
    );
  }

  // Sections du contenu
  Widget _buildHeroSection() {
    return buildHeroBanner(context);
  }

  Widget _buildExpertsSection() {
    return _SectionBuilder(
      title: 'Nos Experts',
      actionText: 'Voir tous',
      icon: Icons.people_rounded,
      onActionPressed: () => _navigateToExpertsList(),
      child: buildExpertProfilesRow(experts),
    );
  }

  Widget buildPopularProductsSection() {
    return _SectionBuilder(
      title: 'Produits Populaires',
      actionText: 'Voir tous',
      icon: Icons.star_rounded,
      onActionPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExplorePage(),
          ),
        );
      },
      child: buildPopularProductsSlider(_featuredProducts, context),
    );
  }

  Widget _buildServicesSection() {
    return _SectionBuilder(
      title: 'Nos Services',
      actionText: 'Voir tous',
      icon: Icons.miscellaneous_services_rounded,
      onActionPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServicesListScreen(),
          ),
        );
      },
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Image de fond
              Positioned(
                right: -20,
                top: -10,
                bottom: -10,
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    'assets/images/agriculture_services.png', // ou votre image
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Contenu principal
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Partie gauche avec le contenu
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icône avec background coloré
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.agriculture_rounded,
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Titre
                          Flexible(
                            child: Text(
                              'Services Agricoles',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Description
                          Flexible(
                            child: Text(
                              'Découvrez notre gamme complète de services pour optimiser votre production agricole',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                    height: 1.4,
                                  ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Bouton d'action
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServicesListScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_forward_rounded,
                                size: 18),
                            label: const Text('Explorer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Partie droite avec l'image
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: double.infinity,
                        margin: const EdgeInsets.only(left: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            "assets/services/cultivation.jpg",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback si l'image n'existe pas
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.3),
                                      Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.agriculture_rounded,
                                  size: 48,
                                  color: Theme.of(context).primaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlogSection() {
    return _SectionBuilder(
      title: 'Conseils & Actualités',
      actionText: 'Voir tous',
      icon: Icons.article_rounded,
      onActionPressed: () => _showComingSoon('Blog'),
      child: const _BlogPostsSlider(),
    );
  }

  // Navigation
  void _navigateToExpertsList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExpertsListScreen(),
      ),
    );
  }

  void _navigateToServices() {
    // Navigate to services tab (index 2 in bottom navigation)
    // Cette logique devrait être gérée par le parent (HomePage)
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Bientôt disponible !'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Widget builder pour les sections
class _SectionBuilder extends StatelessWidget {
  final String title;
  final String actionText;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final Widget child;

  const _SectionBuilder({
    required this.title,
    required this.actionText,
    required this.icon,
    required this.child,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: title,
          actionText: actionText,
          icon: icon,
          onActionPressed: onActionPressed,
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

// En-tête de section amélioré
class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final IconData icon;
  final VoidCallback? onActionPressed;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.icon,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onActionPressed,
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: theme.primaryColor,
                ),
                label: Text(
                  actionText,
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            color: theme.dividerColor.withOpacity(0.5),
            thickness: 1.0,
          ),
        ],
      ),
    );
  }
}

// Modèle de données pour les articles de blog
class BlogPost {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final DateTime date;
  final String excerpt;
  final VoidCallback? onTap;

  const BlogPost({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.date,
    required this.excerpt,
    this.onTap,
  });

  String get formattedDate {
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}

// Données des articles de blog
final List<BlogPost> _blogPosts = [
  BlogPost(
    id: '1',
    title: "Techniques agricoles durables pour améliorer vos rendements",
    imageUrl: "assets/images/blog1.jpg",
    category: "Agriculture",
    date: DateTime(2025, 5, 12),
    excerpt:
        "Découvrez les meilleures pratiques pour une agriculture durable et productive.",
  ),
  BlogPost(
    id: '2',
    title: "Comment choisir les meilleures semences pour votre ferme",
    imageUrl: "assets/images/blog2.jpg",
    category: "Semences",
    date: DateTime(2025, 5, 5),
    excerpt:
        "Guide complet pour sélectionner les semences adaptées à votre région.",
  ),
  BlogPost(
    id: '3',
    title: "La guerre des semences: enjeux et perspectives",
    imageUrl: "assets/images/guerre-des-semences.jpg",
    category: "Actualités",
    date: DateTime(2025, 4, 28),
    excerpt:
        "Analyse des défis actuels dans l'industrie des semences agricoles.",
  ),
];

// Widget pour le slider des articles de blog
class _BlogPostsSlider extends StatelessWidget {
  const _BlogPostsSlider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _blogPosts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return _BlogPostCard(post: _blogPosts[index]);
        },
      ),
    );
  }
}

// Carte d'article de blog
class _BlogPostCard extends StatelessWidget {
  final BlogPost post;

  const _BlogPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 300,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(context),
                Expanded(
                  child: _buildContent(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            height: 160,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Image.asset(
              post.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    color: Colors.grey.shade600,
                    size: 48,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: _CategoryBadge(category: post.category),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            post.excerpt,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                post.formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              Text(
                "Lire plus",
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: theme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (post.onTap != null) {
      post.onTap!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ouverture de l\'article: ${post.title}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}

// Badge de catégorie
class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

// Fonction legacy pour la compatibilité (à supprimer plus tard)
@deprecated
Widget buildSectionHeader(
  BuildContext context,
  String title,
  String actionText, {
  VoidCallback? onViewAllPressed,
  TextStyle? titleStyle,
  TextStyle? actionTextStyle,
  EdgeInsets padding = const EdgeInsets.symmetric(vertical: 8.0),
  Color? dividerColor,
  bool showDivider = false,
  Widget? leading,
  bool animate = false,
}) {
  return _SectionHeader(
    title: title,
    actionText: actionText,
    icon: Icons.info_rounded,
    onActionPressed: onViewAllPressed,
  );
}
