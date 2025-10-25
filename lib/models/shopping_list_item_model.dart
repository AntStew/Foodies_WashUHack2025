import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListItem {
  final String id;
  final String name;
  final String category;
  final String quantity;
  final bool isChecked;
  final DateTime createdAt;

  ShoppingListItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    this.isChecked = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'isChecked': isChecked,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ShoppingListItem.fromMap(String id, Map<String, dynamic> map) {
    return ShoppingListItem(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? 'other',
      quantity: map['quantity'] ?? '',
      isChecked: map['isChecked'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  ShoppingListItem copyWith({
    String? id,
    String? name,
    String? category,
    String? quantity,
    bool? isChecked,
    DateTime? createdAt,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
