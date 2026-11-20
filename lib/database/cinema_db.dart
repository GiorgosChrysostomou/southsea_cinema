import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:southsea_cinema/models/booking.dart';

class CinemaDatabase {
  static const String _fileName = 'cinema.db';
  static const String bookingTable = 'bookings';
  static const String _numberPrefix = 'SC-';

  // Pass inMemoryDatabasePath in tests so nothing is written to disk.
  final String? _path;
  Database? _database;

  CinemaDatabase({String? path}) : _path = path;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final String path = _path ?? join(await getDatabasesPath(), _fileName);

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $bookingTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookingNumber TEXT NOT NULL UNIQUE,
        summary TEXT NOT NULL,
        total REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    for (final Booking booking in sampleBookings) {
      await db.insert(bookingTable, booking.toMap());
    }
  }

  static final List<Booking> sampleBookings = [
    Booking(
      bookingNumber: 'SC-0001',
      summary: '2 x Dracula (1931)',
      total: 15.0,
      date: DateTime(2026, 10, 22, 18, 0),
    ),
    Booking(
      bookingNumber: 'SC-0002',
      summary: '1 x Halloween (1978)',
      total: 7.5,
      date: DateTime(2026, 10, 31, 21, 0),
    ),
    Booking(
      bookingNumber: 'SC-0003',
      summary: '3 x Dracula (1931)',
      total: 22.5,
      date: DateTime(2026, 10, 22, 18, 0),
    ),
  ];

  // Turns 4 into 'SC-0004'.
  static String formatBookingNumber(int number) {
    return '$_numberPrefix${number.toString().padLeft(4, '0')}';
  }

  // The number part of a booking number, used for sorting and counting.
  static const String _numberPart = 'CAST(SUBSTR(bookingNumber, 4) AS INTEGER)';

  Future<int> saveBooking(Booking booking) async {
    final Database db = await database;
    return db.insert(bookingTable, booking.toMap());
  }

  Future<List<Booking>> getAllBookings() async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query(
      bookingTable,
      orderBy: '$_numberPart DESC',
    );

    return rows.map((row) => Booking.fromMap(row)).toList();
  }

  Future<String> getNextBookingNumber() async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT MAX($_numberPart) AS highest FROM $bookingTable',
    );

    final int highest = (rows.first['highest'] as int?) ?? 0;
    return formatBookingNumber(highest + 1);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
