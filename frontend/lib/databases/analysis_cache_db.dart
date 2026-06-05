import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/analysis.dart';

class AnalysisCacheDb {
  AnalysisCacheDb._init();
  static final AnalysisCacheDb instance = AnalysisCacheDb._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('analysis_cache.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE analysis_cache (
  product_id $idType,
  product_name $textType,
  analysis_data $textType,
  created_at $integerType,
  last_viewed_at $integerType
)
''');
  }

  /// Insert or update a cache record
  Future<void> upsertCache(String productId, String productName, AnalysisResponse response) async {
    final db = await instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final map = {
      'product_id': productId,
      'product_name': productName,
      'analysis_data': jsonEncode(response.toJson()),
      'created_at': now,
      'last_viewed_at': now,
    };

    await db.insert(
      'analysis_cache',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await cleanupCache();
  }

  /// Retrieve a cached record by product ID, updating its last_viewed_at if found
  Future<AnalysisResponse?> getCache(String productId) async {
    final db = await instance.database;

    final maps = await db.query(
      'analysis_cache',
      columns: ['analysis_data'],
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    if (maps.isNotEmpty) {
      // Update last_viewed_at
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.update(
        'analysis_cache',
        {'last_viewed_at': now},
        where: 'product_id = ?',
        whereArgs: [productId],
      );

      final analysisDataStr = maps.first['analysis_data'] as String;
      final jsonData = jsonDecode(analysisDataStr);
      return AnalysisResponse.fromJson(jsonData);
    } else {
      return null;
    }
  }

  /// Retrieve all cached records ordered by most recently viewed
  Future<List<Map<String, dynamic>>> getAllCache() async {
    final db = await instance.database;

    return await db.query(
      'analysis_cache',
      orderBy: 'last_viewed_at DESC',
    );
  }

  /// Keep only the [keepCount] most recent records, delete the rest
  Future<void> cleanupCache({int keepCount = 50}) async {
    final db = await instance.database;
    
    final records = await db.query(
      'analysis_cache',
      columns: ['product_id'],
      orderBy: 'last_viewed_at DESC',
      limit: 1000, // Large number to get everything except first few if necessary, though offset is enough
      offset: keepCount,
    );

    if (records.isNotEmpty) {
      final idsToDelete = records.map((e) => e['product_id'] as String).toList();
      final placeholders = List.filled(idsToDelete.length, '?').join(',');
      
      await db.delete(
        'analysis_cache',
        where: 'product_id IN ($placeholders)',
        whereArgs: idsToDelete,
      );
    }
  }

  /// Delete a specific cache record manually
  Future<void> deleteCache(String productId) async {
    final db = await instance.database;
    await db.delete(
      'analysis_cache',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  /// Clear all cached analysis reports
  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('analysis_cache');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
