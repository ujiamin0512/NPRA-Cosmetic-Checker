class ChatAiResponse {
  final bool isRelevant;
  final String reply;
  final ProductSummary? productSummary;
  final List<String> flaggedIngredients;
  final SkinProfileMatch? skinProfileMatch;
  final String? tips;
  final List<String> followUpSuggestions;

  ChatAiResponse({
    required this.isRelevant,
    required this.reply,
    this.productSummary,
    required this.flaggedIngredients,
    this.skinProfileMatch,
    this.tips,
    required this.followUpSuggestions,
  });

  factory ChatAiResponse.fromJson(Map<String, dynamic> json) {
    return ChatAiResponse(
      isRelevant: json['is_relevant'] as bool? ?? true,
      reply: json['reply'] as String? ?? '',
      productSummary: json['product_summary'] != null
          ? ProductSummary.fromJson(json['product_summary'] as Map<String, dynamic>)
          : null,
      flaggedIngredients: List<String>.from(json['flagged_ingredients'] ?? []),
      skinProfileMatch: json['skin_profile_match'] != null
          ? SkinProfileMatch.fromJson(json['skin_profile_match'] as Map<String, dynamic>)
          : null,
      tips: json['tips'] as String?,
      followUpSuggestions: List<String>.from(json['follow_up_suggestions'] ?? []),
    );
  }
}

class ProductSummary {
  final String productName;
  final bool overallSuitable;
  final String safetyRating;

  ProductSummary({
    required this.productName,
    required this.overallSuitable,
    required this.safetyRating,
  });

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    return ProductSummary(
      productName: json['product_name'] as String? ?? '',
      overallSuitable: json['overall_suitable'] as bool? ?? false,
      safetyRating: json['safety_rating'] as String? ?? 'unknown',
    );
  }
}

class SkinProfileMatch {
  final List<String> suitableForSkinTypes;
  final List<String> addressesConcerns;
  final List<String> conflictsWithAllergies;

  SkinProfileMatch({
    required this.suitableForSkinTypes,
    required this.addressesConcerns,
    required this.conflictsWithAllergies,
  });

  factory SkinProfileMatch.fromJson(Map<String, dynamic> json) {
    return SkinProfileMatch(
      suitableForSkinTypes: List<String>.from(json['suitable_for_skin_types'] ?? []),
      addressesConcerns: List<String>.from(json['addresses_concerns'] ?? []),
      conflictsWithAllergies: List<String>.from(json['conflicts_with_allergies'] ?? []),
    );
  }
}
