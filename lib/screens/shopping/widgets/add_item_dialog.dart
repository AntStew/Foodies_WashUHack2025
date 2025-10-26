import 'package:flutter/material.dart';
import '../../../models/shopping_list_item_model.dart';
import '../../../services/firestore_service.dart';

class AddItemDialog extends StatefulWidget {
  final String userId;

  const AddItemDialog({
    super.key,
    required this.userId,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedCategory = 'Other';

  final _categories = [
    'Produce',
    'Dairy',
    'Meat',
    'Seafood',
    'Frozen',
    'Beverages',
    'Condiments',
    'Pantry',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.add_shopping_cart,
              color: Color(0xFF667eea),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add Item'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                hintText: 'e.g., Milk, Apples',
                prefixIcon: const Icon(Icons.label_outline, color: Color(0xFF667eea)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFF667eea)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                ),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(category), size: 18, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Quantity
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                hintText: 'e.g., 2 lbs, 1 gallon',
                prefixIcon: const Icon(Icons.shopping_basket_outlined, color: Color(0xFF667eea)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = _nameController.text.trim();
            final quantity = _quantityController.text.trim();

            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter an item name'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            final newItem = ShoppingListItem(
              id: '',
              name: name,
              category: _selectedCategory,
              quantity: quantity.isEmpty ? '1' : quantity,
              isChecked: false,
              createdAt: DateTime.now(),
            );

            Navigator.pop(context);

            // Add item without waiting (fire and forget)
            firestoreService.addShoppingListItem(widget.userId, newItem).then((_) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$name added to shopping list'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }).catchError((e) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Add Item'),
        ),
      ],
    );
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
