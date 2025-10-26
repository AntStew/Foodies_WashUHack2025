import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/fridge_item_model.dart';

class EditItemDialog extends StatefulWidget {
  final FridgeItem item;

  const EditItemDialog({
    super.key,
    required this.item,
  });

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late String _selectedCategory;

  final _categories = [
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
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController = TextEditingController(text: widget.item.quantity);
    
    // Ensure the category is valid, fallback to 'other' if not found
    final itemCategory = widget.item.category.toLowerCase();
    _selectedCategory = _categories.contains(itemCategory) ? itemCategory : 'other';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
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
              Icons.edit_outlined,
              color: Color(0xFF667eea),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Edit Item'),
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
              value: _selectedCategory,
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
                      Text(_getCategoryDisplayName(category)),
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
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: 'Quantity',
                hintText: 'e.g., 2, 5, 10',
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
          onPressed: () {
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

            if (quantity.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a quantity'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            // Validate that quantity is a positive integer
            final quantityInt = int.tryParse(quantity);
            if (quantityInt == null || quantityInt <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid positive number for quantity'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            // Create updated item
            final updatedItem = FridgeItem(
              id: widget.item.id,
              name: name,
              category: _selectedCategory,
              quantity: quantity,
              expiryDate: widget.item.expiryDate,
              addedDate: widget.item.addedDate,
              lastScanned: widget.item.lastScanned,
              imageUrl: widget.item.imageUrl,
              freshness: widget.item.freshness,
            );

            Navigator.pop(context, updatedItem);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Save Changes'),
        ),
      ],
    );
    } catch (e) {
      // Fallback dialog if there's an error
      return AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to load edit dialog: ${e.toString()}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
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

  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
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
}
