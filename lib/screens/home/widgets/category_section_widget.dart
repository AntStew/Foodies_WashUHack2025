import 'package:flutter/material.dart';
import '../../../models/fridge_item_model.dart';

class CategorySectionWidget extends StatefulWidget {
  final List<FridgeItem> items;
  final Function(FridgeItem) onDeleteItem;
  final Function(FridgeItem) onEditItem;

  const CategorySectionWidget({
    super.key,
    required this.items,
    required this.onDeleteItem,
    required this.onEditItem,
  });

  @override
  State<CategorySectionWidget> createState() => _CategorySectionWidgetState();
}

class _CategorySectionWidgetState extends State<CategorySectionWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = [
    'all',
    'vegetables',
    'fruits',
    'dairy',
    'meat',
    'grains',
    'beverages',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 209, 38, 38),
                  Color.fromARGB(255, 255, 124, 30),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              tabs: _categories.map((category) {
                final categoryItems = _getItemsForCategory(category);
                return Tab(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_getCategoryDisplayName(category)),
                        if (categoryItems.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${categoryItems.length}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                final categoryItems = _getItemsForCategory(category);
                return _buildCategoryContent(categoryItems, category);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryContent(List<FridgeItem> items, String category) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_getCategoryDisplayName(category).toLowerCase()} items',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items to your fridge to see them here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildListItem(item);
        },
      ),
    );
  }

  Widget _buildListItem(FridgeItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Category Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: _getCategoryGradient(item.category),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                item.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Quantity: ${item.quantity}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (item.expiryDate != null) ...[
                      const SizedBox(width: 16),
                      Text(
                        'Expires: ${_formatDate(item.expiryDate!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _getExpiryColor(item.expiryDate!),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Added: ${_formatDate(item.addedDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Row(
            children: [
              // Edit Button
              GestureDetector(
                onTap: () => widget.onEditItem(item),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delete Button
              GestureDetector(
                onTap: () => widget.onDeleteItem(item),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<FridgeItem> _getItemsForCategory(String category) {
    if (category == 'all') {
      return widget.items;
    }
    return widget.items.where((item) => 
      item.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return 'All';
      case 'vegetables':
        return 'Vegetables';
      case 'fruits':
        return 'Fruits';
      case 'dairy':
        return 'Dairy';
      case 'meat':
        return 'Meat';
      case 'grains':
        return 'Grains';
      case 'beverages':
        return 'Beverages';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.inventory_2_outlined;
      case 'vegetables':
        return Icons.eco_outlined;
      case 'fruits':
        return Icons.apple_outlined;
      case 'dairy':
        return Icons.local_drink_outlined;
      case 'meat':
        return Icons.restaurant_outlined;
      case 'grains':
        return Icons.grain_outlined;
      case 'beverages':
        return Icons.local_bar_outlined;
      case 'other':
        return Icons.category_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${difference.abs()} days ago';
    }
  }

  Color _getExpiryColor(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;
    
    if (difference < 0) {
      return Colors.red;
    } else if (difference <= 2) {
      return Colors.orange;
    } else if (difference <= 7) {
      return Colors.yellow[700]!;
    } else {
      return Colors.green;
    }
  }

  LinearGradient _getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return const LinearGradient(colors: [Colors.green, Colors.lightGreen]);
      case 'fruits':
        return const LinearGradient(colors: [Colors.orange, Colors.deepOrange]);
      case 'dairy':
        return const LinearGradient(colors: [Colors.blue, Colors.lightBlue]);
      case 'meat':
        return const LinearGradient(colors: [Colors.red, Colors.deepOrange]);
      case 'grains':
        return const LinearGradient(colors: [Colors.brown, Colors.amber]);
      case 'beverages':
        return const LinearGradient(colors: [Colors.purple, Colors.indigo]);
      default:
        return const LinearGradient(colors: [Colors.grey, Colors.blueGrey]);
    }
  }
}
