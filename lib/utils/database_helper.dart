// lib/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT, contactNumber TEXT, vehicleNumber TEXT, password TEXT)',
        );
      },
    );
  }

  Future<void> insertUser(Map<String, dynamic> userData) async {
    final db = await database;
    await db.insert(
      'users',
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Method to get user by email and password
  Future<Map<String, dynamic>?> getUserByEmailAndPassword(
      String email, String password) async {
    final db = await database;

    // Query the database for the user with the given email
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    // Return the first user found, or null if no user matches
    return users.isNotEmpty ? users.first : null;
  }

  // Method to get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return users.isNotEmpty ? users.first : null;
  }

  // Method to insert or update email
  Future<void> insertEmail(String email) async {
    final db = await database;
    // Check if the email already exists
    final existingEmail = await getUserByEmail(email);
    if (existingEmail != null) {
      // Update the existing email if found
      await db.update(
        'users',
        {'email': email},
        where: 'id = ?',
        whereArgs: [existingEmail['id']],
      );
    } else {
      // If not, insert a new email entry
      await db.insert(
        'users',
        {'email': email},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Method to retrieve stored email
  Future<String?> getStoredEmail() async {
    final db = await database;
    final List<Map<String, dynamic>> emails = await db.query(
      'users',
      columns: ['email'],
      limit: 1,
    );

    return emails.isNotEmpty ? emails.first['email'] as String : null;
  }

  // Method to delete user data (for cleanup if needed)
  Future<void> deleteUser() async {
    final db = await database;
    await db.delete('users');
  }
}
