import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../models/shopping_list_item_model.dart';
import 'shopping_list_item_widget.dart';

class CategorySectionWidget extends StatelessWidget {
  final String category;
  final List<ShoppingListItem> items;
  final String userId;

  const CategorySectionWidget({
    super.key,
    required this.category,
    required this.items,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(0.02),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isDesktop ? 20 : 15),
            boxShadow: [
              // Outer shadow for depth
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: isDesktop ? 25 : 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              // Mid shadow for definition
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: isDesktop ? 15 : 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
              // Inner shadow for depth
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: isDesktop ? 8 : 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
              // Highlight shadow for 3D effect
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                blurRadius: isDesktop ? 6 : 4,
                offset: const Offset(-2, -2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isDesktop ? 20 : 15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(isDesktop ? 20 : 15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isDesktop ? 20 : 16),
                      decoration: BoxDecoration(
                        gradient: _getCategoryGradient(category),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isDesktop ? 20 : 15),
                          topRight: Radius.circular(isDesktop ? 20 : 15),
                        ),
                        boxShadow: [
                          // Inner shadow for depth
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                          // Highlight for 3D effect
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, -1),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  blurRadius: 2,
                                  offset: const Offset(0, -1),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getCategoryIcon(category),
                              color: Colors.white,
                              size: isDesktop ? 24 : 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            category,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isDesktop ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  blurRadius: 1,
                                  offset: const Offset(0, -1),
                                ),
                              ],
                            ),
                            child: Text(
                              '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 15 : 14,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    offset: const Offset(0, 1),
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Items List
                    ...items.map((item) => ShoppingListItemWidget(
                          item: item,
                          userId: userId,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'produce':
      case 'vegetables':
      case 'fruits':
        return const LinearGradient(colors: [Colors.green, Colors.lightGreen]);
      case 'dairy':
        return const LinearGradient(colors: [Colors.blue, Colors.lightBlue]);
      case 'meat':
        return const LinearGradient(colors: [Colors.red, Colors.deepOrange]);
      case 'pantry':
      case 'grains':
        return const LinearGradient(colors: [Colors.brown, Colors.amber]);
      default:
        return const LinearGradient(colors: [Colors.grey, Colors.blueGrey]);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'produce':
      case 'vegetables':
      case 'fruits':
        return Icons.eco;
      case 'dairy':
        return Icons.local_drink;
      case 'meat':
        return Icons.restaurant;
      case 'pantry':
      case 'grains':
        return Icons.kitchen;
      default:
        return Icons.shopping_bag;
    }
  }
}
