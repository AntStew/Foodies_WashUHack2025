import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final bool questionnaireCompleted;
  final List<String> dietaryRestrictions;
  final List<String> cuisinePreferences;
  final List<String> allergies;
  final int servingSize;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.questionnaireCompleted = false,
    this.dietaryRestrictions = const [],
    this.cuisinePreferences = const [],
    this.allergies = const [],
    this.servingSize = 2,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'questionnaireCompleted': questionnaireCompleted,
      'preferences': {
        'dietaryRestrictions': dietaryRestrictions,
        'cuisinePreferences': cuisinePreferences,
        'allergies': allergies,
        'servingSize': servingSize,
      },
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final prefs = map['preferences'] ?? {};
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      questionnaireCompleted: map['questionnaireCompleted'] ?? false,
      dietaryRestrictions: List<String>.from(prefs['dietaryRestrictions'] ?? []),
      cuisinePreferences: List<String>.from(prefs['cuisinePreferences'] ?? []),
      allergies: List<String>.from(prefs['allergies'] ?? []),
      servingSize: prefs['servingSize'] ?? 2,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? questionnaireCompleted,
    List<String>? dietaryRestrictions,
    List<String>? cuisinePreferences,
    List<String>? allergies,
    int? servingSize,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      questionnaireCompleted: questionnaireCompleted ?? this.questionnaireCompleted,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      cuisinePreferences: cuisinePreferences ?? this.cuisinePreferences,
      allergies: allergies ?? this.allergies,
      servingSize: servingSize ?? this.servingSize,
    );
  }
}
