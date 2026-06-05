class Report {
  static const String tableName = 'reports';
  static const String colId = 'id';
  static const String colUserId = 'user_id';
  static const String colProductName = 'product_name';
  static const String colNotificationNumber = 'notification_number';
  static const String colProblem = 'problem_description';
  static const String colPurchaseDate = 'purchase_date';
  static const String colPurchasePlace = 'purchase_place';
  static const String colLatitude = 'latitude';
  static const String colLongitude = 'longitude';

  final int? id;
  final String userId;
  final String productName;
  final String notificationNumber;
  final String problem;
  final String purchaseDate;
  final String purchasePlace;
  final double? latitude;
  final double? longitude;

  Report({
    this.id,
    required this.userId,
    required this.productName,
    required this.notificationNumber,
    required this.problem,
    required this.purchaseDate,
    required this.purchasePlace,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      colId: id,
      colUserId: userId,
      colProductName: productName,
      colNotificationNumber: notificationNumber,
      colProblem: problem,
      colPurchaseDate: purchaseDate,
      colPurchasePlace: purchasePlace,
      colLatitude: latitude,
      colLongitude: longitude,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map[colId] as int?,
      userId: map[colUserId] as String,
      productName: map[colProductName] as String,
      notificationNumber: map[colNotificationNumber] as String,
      problem: map[colProblem] as String,
      purchaseDate: map[colPurchaseDate] as String,
      purchasePlace: map[colPurchasePlace] as String,
      latitude: (map[colLatitude] as num?)?.toDouble(),
      longitude: (map[colLongitude] as num?)?.toDouble(),
    );
  }

}