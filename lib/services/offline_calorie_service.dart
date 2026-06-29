import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class OfflineCalorieService {
  static final OfflineCalorieService instance = OfflineCalorieService._init();
  static Database? _database;

  OfflineCalorieService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('local_wellness.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Creating the offline calorie table mirroring your app's structure
    await db.execute('''
      CREATE TABLE offline_calories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_makanan TEXT NOT NULL,
        jumlah_kalori INTEGER NOT NULL,
        log_date TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // 📥 1. Insert a Calorie Log Locally
  Future<int> insertLocalCalorie({
    required String namaMakanan,
    required int jumlahKalori,
    required String logDate,
    int isSynced = 0, // 0 = Saved offline only, 1 = Already pushed to Laravel
  }) async {
    final db = await instance.database;
    return await db.insert('offline_calories', {
      'nama_makanan': namaMakanan,
      'jumlah_kalori': jumlahKalori,
      'log_date': logDate,
      'is_synced': isSynced,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 📤 2. Fetch All Calorie Logs for a Specific Date
  Future<List<Map<String, dynamic>>> getLocalCaloriesByDate(String date) async {
    final db = await instance.database;
    return await db.query(
      'offline_calories',
      where: 'log_date = ?',
      whereArgs: [date],
      orderBy: 'id DESC',
    );
  }

  // 🧠 3. Fetch Pending Logs (Used later for background syncing)
  Future<List<Map<String, dynamic>>> getUnsyncedCalories() async {
    final db = await instance.database;
    return await db.query('offline_calories', where: 'is_synced = 0');
  }

  // 🔄 4. Mark local logs as successfully sent to Laravel
  Future<int> markAsSynced(int id) async {
    final db = await instance.database;
    return await db.update(
      'offline_calories',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 🧹 5. Wipe out cache (Call this inside your Provider's clearState() on logout)
  Future<void> clearLocalTable() async {
    final db = await instance.database;
    await db.delete('offline_calories');
  }
}
