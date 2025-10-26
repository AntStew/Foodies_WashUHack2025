import 'package:flutter/material.dart';
import '../../../models/shopping_list_item_model.dart';
import '../../../services/firestore_service.dart';

class ShoppingListItemWidget extends StatelessWidget {
  final ShoppingListItem item;
  final String userId;

  const ShoppingListItemWidget({
    super.key,
    required this.item,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: const BoxDecoration(
          color: Colors.red,
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        firestoreService.deleteShoppingListItem(userId, item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} removed from list'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: CheckboxListTile(
          value: item.isChecked,
          onChanged: (bool? value) {
            if (value != null) {
              firestoreService.toggleShoppingListItem(userId, item.id, value);
            }
          },
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: item.isChecked ? TextDecoration.lineThrough : null,
              color: item.isChecked ? Colors.grey : const Color(0xFF2D3748),
              shadows: item.isChecked ? null : [
                // Main shadow for depth
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
                // Highlight shadow for 3D effect
                Shadow(
                  offset: const Offset(-0.5, -0.5),
                  blurRadius: 1,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
          subtitle: Text(
            item.quantity,
            style: TextStyle(
              fontSize: 14,
              color: item.isChecked ? Colors.grey : const Color(0xFF718096),
              decoration: item.isChecked ? TextDecoration.lineThrough : null,
              shadows: item.isChecked ? null : [
                // Subtle shadow for depth
                Shadow(
                  offset: const Offset(0.5, 0.5),
                  blurRadius: 1,
                  color: Colors.black.withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
          activeColor: const Color(0xFF667eea),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }
}
