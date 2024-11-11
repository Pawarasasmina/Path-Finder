// db_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'booking_database.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE bookings(id INTEGER PRIMARY KEY, startingLocation TEXT, endingLocation TEXT, seats INTEGER, scheduleType TEXT, date TEXT, time TEXT)",
        );
      },
      version: 1,
    );
  }

  // Method to insert a booking
  Future<int> insertBooking(Map<String, dynamic> booking) async {
    final db = await database;
    return await db.insert('bookings', booking);
  }

  // Method to fetch all bookings
  Future<List<Map<String, dynamic>>> fetchBookings() async {
    final db = await database;
    return await db.query('bookings');
  }
}
