import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/animal_models.dart';

class DBHelper {

  static Database? _database;


  // ============================================
  // CONEXIÓN SINGLETON
  // ============================================

  Future<Database> get database async {

    if (_database != null) return _database!;

    _database = await _initDB('agroscan.db');

    return _database!;
  }


  // ============================================
  // CREAR DB
  // ============================================

  Future<Database> _initDB(String filePath) async {

    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }


  // ============================================
  // CREAR TABLA
  // ============================================

  Future _createDB(Database db, int version) async {

    await db.execute('''
      CREATE TABLE ganado (

        id INTEGER PRIMARY KEY AUTOINCREMENT,

        codigoQR TEXT UNIQUE,

        raza TEXT,

        peso REAL,

        edad INTEGER,

        estadoSalud TEXT,

        sincronizado INTEGER DEFAULT 0

      )
    ''');
  }


  // ============================================
  // INSERTAR / ACTUALIZAR
  // ============================================

  Future<int> insertarAnimal(Animal animal) async {

    final db = await database;

    // ✅ IMPORTANTE:
    // animal.toMap() debe incluir sincronizado

    return await db.insert(

      'ganado',

      animal.toMap(),

      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }


  // ============================================
  // SOLO LOS QUE NO SE HAN SUBIDO
  // ============================================

  Future<List<Animal>> obtenerPendientes() async {

    final db = await database;

    final res = await db.query(
      'ganado',
      where: 'sincronizado = 0',
    );

    return res
        .map(
          (map) =>
              Animal.fromMap(map),
        )
        .toList();
  }


  // ============================================
  // TODOS
  // ============================================

  Future<List<Animal>> obtenerTodos() async {

    final db = await database;

    final res = await db.query('ganado');

    return res
        .map(
          (map) =>
              Animal.fromMap(map),
        )
        .toList();
  }


  // ============================================
  // MARCAR COMO SINCRONIZADO
  // ============================================

  Future<void> marcarSincronizado(
      String qr) async {

    final db = await database;

    await db.update(

      'ganado',

      {
        'sincronizado': 1,
      },

      where: 'codigoQR = ?',

      whereArgs: [qr],
    );
  }

}