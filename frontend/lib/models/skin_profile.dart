import 'dart:convert';

class SkinProfile {
  static const String colProfileCompleted = 'profile_completed';
  static const String colWizardSkipCount = 'wizard_skip_count';
  static const String colSkinTypes = 'skin_types';
  static const String colSkinConcerns = 'skin_concerns';
  static const String colAllergies = 'allergies';

  final bool profileCompleted;
  final int wizardSkipCount;
  final List<String> skinTypes;
  final List<String> skinConcerns;
  final List<String> allergies;

  const SkinProfile({
    this.profileCompleted = false,
    this.wizardSkipCount = 0,
    this.skinTypes = const [],
    this.skinConcerns = const [],
    this.allergies = const [],
  });

  factory SkinProfile.fromMap(Map<String, Object?> map) {
    List<String> decodeList(Object? value) {
      if (value == null) return [];
      if (value is String) {
        try {
          return List<String>.from(jsonDecode(value));
        } catch (e) {
          return [];
        }
      }
      if (value is List) {
        return List<String>.from(value);
      }
      return [];
    }

    return SkinProfile(
      profileCompleted: (map[colProfileCompleted] as int?) == 1 || map[colProfileCompleted] == true,
      wizardSkipCount: map[colWizardSkipCount] as int? ?? 0,
      skinTypes: decodeList(map[colSkinTypes]),
      skinConcerns: decodeList(map[colSkinConcerns]),
      allergies: decodeList(map[colAllergies]),
    );
  }

  // skin_profile.dart
  Map<String, dynamic> toMap() {
    return {
      colProfileCompleted: profileCompleted ? 1 : 0,
      colWizardSkipCount: wizardSkipCount,
      colSkinTypes: jsonEncode(skinTypes), 
      colSkinConcerns: jsonEncode(skinConcerns),
      colAllergies: jsonEncode(allergies),
    };
  }

  String get summary {
    if (!profileCompleted) return 'Skin profile not yet completed.';
    
    final types = skinTypes.isEmpty ? 'None' : skinTypes.join(', ');
    final concerns = skinConcerns.isEmpty ? 'None' : skinConcerns.join(', ');
    final allergyList = allergies.isEmpty ? 'None' : allergies.join(', ');
    
    return 'Skin Type: $types. Skin Concerns: $concerns. Allergies: $allergyList.';
  }
}
