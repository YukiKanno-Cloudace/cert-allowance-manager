import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/acquired_cert.dart';

/// ローカルストレージサービス（SQLite）
class StorageService {
  static final StorageService _instance = StorageService._internal();
  static Database? _database;

  factory StorageService() => _instance;

  StorageService._internal();

  /// データベースの取得
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// データベースの初期化
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'qualification_allowance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// テーブル作成
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE acquired_certs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        certId TEXT NOT NULL,
        acquiredDate TEXT NOT NULL,
        expiryDate TEXT NOT NULL
      )
    ''');
  }

  /// 取得済み資格をすべて取得
  Future<List<AcquiredCert>> getAllAcquiredCerts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('acquired_certs');
    return List.generate(maps.length, (i) => AcquiredCert.fromMap(maps[i]));
  }

  /// 取得済み資格を追加
  Future<AcquiredCert> insertAcquiredCert(AcquiredCert cert) async {
    final db = await database;
    final id = await db.insert(
      'acquired_certs',
      cert.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return cert.copyWith(id: id.toString());
  }

  /// 取得済み資格を更新
  Future<void> updateAcquiredCert(AcquiredCert cert) async {
    final db = await database;
    await db.update(
      'acquired_certs',
      cert.toMap(),
      where: 'id = ?',
      whereArgs: [cert.id],
    );
  }

  /// 取得済み資格を削除
  Future<void> deleteAcquiredCert(String id) async {
    final db = await database;
    await db.delete(
      'acquired_certs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 資格IDで取得済み資格を検索
  Future<AcquiredCert?> getAcquiredCertByCertId(String certId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'acquired_certs',
      where: 'certId = ?',
      whereArgs: [certId],
    );
    if (maps.isEmpty) return null;
    return AcquiredCert.fromMap(maps.first);
  }

  /// すべてのデータを削除（リセット機能）
  Future<void> deleteAllAcquiredCerts() async {
    final db = await database;
    await db.delete('acquired_certs');
  }

  /// データベースを閉じる
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

