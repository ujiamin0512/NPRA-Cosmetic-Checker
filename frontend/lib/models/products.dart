/// Data model representing a cosmetic product row from the Firestore database.
class Product {
  // Collection & field names
  static const String tableName = 'products'; // still used occasionally for references
  static const String colNotifNo = 'notif_no';
  static const String colBrand = 'brand';
  static const String colProduct = 'product';
  static const String colType = 'type';
  static const String colStatus = 'status';
  static const String colCompany = 'company';
  static const String colCountry = 'country';
  static const String colSubstanceDetected = 'substance_detected';
  static const String colIngredients = 'ingredients';
  static const String colAfterUseTargets = 'after_use_targets';

  final String notifNo;
  final String? brand;
  final String product;
  final String? type;
  final String status;
  final String company;
  final String? country;
  final String substanceDetected;
  final String? ingredients;
  final String? afterUseTargets;

  const Product({
    required this.notifNo,
    this.brand,
    required this.product,
    this.type,
    required this.status,
    required this.company,
    this.country,
    required this.substanceDetected,
    this.ingredients,
    this.afterUseTargets,
  });

  /// Create a Product from a database row (Map)
  factory Product.fromMap(Map<String, Object?> map) {
    // Handle substanceDetected carefully since it might be a double (NaN) or String
    String parsedSubstance = map[colSubstanceDetected]?.toString() ?? '';
    if (parsedSubstance.toLowerCase() == 'nan') {
      parsedSubstance = '';
    }

    return Product(
      notifNo: map[colNotifNo]?.toString() ?? '',
      brand: map[colBrand]?.toString(),
      product: map[colProduct]?.toString() ?? '',
      type: map[colType]?.toString(),
      status: map[colStatus]?.toString() ?? '',
      company: map[colCompany]?.toString() ?? '',
      country: map[colCountry]?.toString(),
      substanceDetected: parsedSubstance,
      ingredients: map[colIngredients]?.toString(),
      afterUseTargets: map[colAfterUseTargets]?.toString(),
    );
  }

  @override
  String toString() {
    return 'Product('
        'notifNo: $notifNo, '
        'brand: $brand, '
        'product: $product, '
        'type: $type, '
        'status: $status, '
        'company: $company, '
        'country: $country, '
        'substanceDetected: $substanceDetected, '
        'ingredients: $ingredients, '
        'afterUseTargets: $afterUseTargets'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.notifNo == notifNo;
  }

  @override
  int get hashCode => notifNo.hashCode;
}
