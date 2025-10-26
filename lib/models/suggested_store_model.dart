class SuggestedStore {
  final String id;
  final String name;
  final String reason;
  final List<String> categories;
  final DateTime createdAt;

  SuggestedStore({
    required this.id,
    required this.name,
    required this.reason,
    required this.categories,
    required this.createdAt,
  });

  // Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'reason': reason,
      'categories': categories,
      'createdAt': createdAt,
    };
  }

  // Create from Firestore Map
  factory SuggestedStore.fromMap(String id, Map<String, dynamic> map) {
    return SuggestedStore(
      id: id,
      name: map['name'] ?? '',
      reason: map['reason'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }
}
