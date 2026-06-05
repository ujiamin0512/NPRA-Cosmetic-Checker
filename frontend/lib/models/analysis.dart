class AnalysisResponse {
  final ReportSummary summary;
  final List<IngredientDetail> ingredientsReport;

  AnalysisResponse({
    required this.summary,
    required this.ingredientsReport,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      summary: ReportSummary.fromJson(json['summary'] ?? {}),
      ingredientsReport: (json['ingredients_report'] as List<dynamic>?)
              ?.map((e) => IngredientDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'ingredients_report': ingredientsReport.map((e) => e.toJson()).toList(),
    };
  }
}

class ReportSummary {
  final bool isNatural;
  final bool isVegan;
  final bool isFragranceFree;
  final bool isParabenFree;
  final bool isSiliconeFree;
  final bool isSulphateFree;
  final bool isGlutenFree;

  ReportSummary({
    required this.isNatural,
    required this.isVegan,
    required this.isFragranceFree,
    required this.isParabenFree,
    required this.isSiliconeFree,
    required this.isSulphateFree,
    required this.isGlutenFree,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      isNatural: json['is_natural'] ?? false,
      isVegan: json['is_vegan'] ?? false,
      isFragranceFree: json['is_fragrance_free'] ?? false,
      isParabenFree: json['is_paraben_free'] ?? false,
      isSiliconeFree: json['is_silicone_free'] ?? false,
      isSulphateFree: json['is_sulphate_free'] ?? false,
      isGlutenFree: json['is_gluten_free'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_natural': isNatural,
      'is_vegan': isVegan,
      'is_fragrance_free': isFragranceFree,
      'is_paraben_free': isParabenFree,
      'is_silicone_free': isSiliconeFree,
      'is_sulphate_free': isSulphateFree,
      'is_gluten_free': isGlutenFree,
    };
  }
}

class IngredientDetail {
  final String inciName;
  final String matchedType;
  final String ingFunction;
  final String ingOrigin;
  final bool isNatural;
  final bool isVegan;
  final bool isFragrance;
  final bool isParaben;
  final bool isSilicone;
  final bool isSulphate;
  final bool isGluten;

  IngredientDetail({
    required this.inciName,
    required this.matchedType,
    required this.ingFunction,
    required this.ingOrigin,
    required this.isNatural,
    required this.isVegan,
    required this.isFragrance,
    required this.isParaben,
    required this.isSilicone,
    required this.isSulphate,
    required this.isGluten,
  });

  factory IngredientDetail.fromJson(Map<String, dynamic> json) {
    return IngredientDetail(
      inciName: json['inci_name']?.toString() ?? 'Unknown',
      matchedType: json['matched_type']?.toString() ?? 'Unknown',
      ingFunction: json['ing_function']?.toString() ?? 'N/A',
      ingOrigin: json['ing_origin']?.toString() ?? 'N/A',
      isNatural: json['is_natural'] ?? false,
      isVegan: json['is_vegan'] ?? false,
      isFragrance: json['is_fragrance'] ?? false,
      isParaben: json['is_paraben'] ?? false,
      isSilicone: json['is_silicone'] ?? false,
      isSulphate: json['is_sulphate'] ?? false,
      isGluten: json['is_gluten'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inci_name': inciName,
      'matched_type': matchedType,
      'ing_function': ingFunction,
      'ing_origin': ingOrigin,
      'is_natural': isNatural,
      'is_vegan': isVegan,
      'is_fragrance': isFragrance,
      'is_paraben': isParaben,
      'is_silicone': isSilicone,
      'is_sulphate': isSulphate,
      'is_gluten': isGluten,
    };
  }
}
