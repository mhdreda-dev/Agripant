import 'package:agriplant/data/experts.dart';
import 'package:agriplant/data/home_data.dart';
import 'package:agriplant/widgets/expert_profiles_row.dart';
import 'package:agriplant/widgets/hero_banner.dart';
import 'package:agriplant/widgets/popular_products_slider.dart';
import 'package:agriplant/widgets/promotions_slider.dart';
import 'package:flutter/material.dart';

import '../data/products.dart';
import '../screens/experts_list_screen.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final featuredProducts = products.where((p) => p.isFeatured).toList();
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 1500));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildHeroBanner(context),
          const SizedBox(height: 24),

          // Experts section with improved section header
          buildSectionHeader(
            context,
            'Nos Experts',
            'Voir tous',
            onViewAllPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ExpertsListScreen()),
              );
            },
            leading: Icon(Icons.people, color: Theme.of(context).primaryColor),
            showDivider: true,
          ),
          const SizedBox(height: 12),
          buildExpertProfilesRow(experts),
          const SizedBox(height: 24),

          // Popular products section
          buildSectionHeader(
            context,
            'Popular Products',
            'View all',
            leading: Icon(Icons.star, color: Theme.of(context).primaryColor),
            showDivider: true,
          ),
          const SizedBox(height: 12),
          buildPopularProductsSlider(featuredProducts, context),
          const SizedBox(height: 24),

          // Promotions section
          buildSectionHeader(
            context,
            'Current Promotions',
            'View all',
            leading:
                Icon(Icons.local_offer, color: Theme.of(context).primaryColor),
            showDivider: true,
          ),
          const SizedBox(height: 12),
          buildPromotionsSlider(dailyPromotions),
          const SizedBox(height: 24),

          // Blog posts section with images
          buildSectionHeader(
            context,
            'Farming Tips & News',
            'View all',
            leading: Icon(Icons.article, color: Theme.of(context).primaryColor),
            showDivider: true,
          ),
          const SizedBox(height: 12),
          buildBlogPostsSlider(),
        ],
      ),
    );
  }
}

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
  final defaultTitleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      );

  final defaultActionStyle = TextStyle(
    color: Theme.of(context).primaryColor,
    fontWeight: FontWeight.bold,
  );

  Widget header = Padding(
    padding: padding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              if (leading != null) ...[
                leading,
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  title,
                  style: titleStyle ?? defaultTitleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onViewAllPressed ?? () {},
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionText,
            style: actionTextStyle ?? defaultActionStyle,
          ),
        ),
      ],
    ),
  );

  if (showDivider) {
    header = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        Divider(
          color: dividerColor ?? Theme.of(context).dividerColor,
          thickness: 1.0,
        ),
      ],
    );
  }

  if (animate) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: header,
    );
  }

  return header;
}

// Blog Posts Widget
class BlogPost {
  final String title;
  final String imageUrl;
  final String category;
  final String date;
  final VoidCallback? onTap;

  BlogPost({
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.date,
    this.onTap,
  });
}

final List<BlogPost> blogPosts = [
  BlogPost(
    title: "Techniques agricoles durables pour améliorer vos rendements",
    imageUrl: "assets/images/blog1.jpg",
    category: "Agriculture",
    date: "12 Mai, 2025",
  ),
  BlogPost(
    title: "Comment choisir les meilleures semences pour votre ferme",
    imageUrl: "assets/images/blog2.jpg",
    category: "Semences",
    date: "5 Mai, 2025",
  ),
  BlogPost(
    title: "La guerre des semences: enjeux et perspectives",
    imageUrl: "assets/images/guerre-des-semences.jpg",
    category: "Actualités",
    date: "28 Avril, 2025",
  ),
];

Widget buildBlogPostsSlider() {
  return SizedBox(
    height: 280,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: blogPosts.length,
      itemBuilder: (context, index) {
        final post = blogPosts[index];
        return GestureDetector(
          onTap: post.onTap ??
              () {
                // Navigate to blog post detail
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening article: ${post.title}')),
                );
              },
          child: Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with category badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.asset(
                        post.imageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          post.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.date,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Lire plus",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
