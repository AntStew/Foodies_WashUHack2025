import 'package:cloud_firestore/cloud_firestore.dart';

class FridgeItem {
  final String id;
  final String name;
  final String category;
  final String quantity;
  final DateTime? expiryDate;
  final DateTime addedDate;
  final DateTime lastScanned;
  final String? imageUrl;
  final String freshness;

  FridgeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    this.expiryDate,
    required this.addedDate,
    required this.lastScanned,
    this.imageUrl,
    this.freshness = 'fresh',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'addedDate': Timestamp.fromDate(addedDate),
      'lastScanned': Timestamp.fromDate(lastScanned),
      'imageUrl': imageUrl,
      'freshness': freshness,
    };
  }

  factory FridgeItem.fromMap(String id, Map<String, dynamic> map) {
    return FridgeItem(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? 'other',
      quantity: map['quantity'] ?? '',
      expiryDate: map['expiryDate'] != null
          ? (map['expiryDate'] as Timestamp).toDate()
          : null,
      addedDate: (map['addedDate'] as Timestamp).toDate(),
      lastScanned: (map['lastScanned'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'],
      freshness: map['freshness'] ?? 'fresh',
    );
  }
}
