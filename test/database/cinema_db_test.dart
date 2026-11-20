import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late CinemaDatabase cinemaDb;

  setUp(() {
    cinemaDb = CinemaDatabase(path: inMemoryDatabasePath);
  });

  tearDown(() async {
    await cinemaDb.close();
  });

  Booking makeBooking(String number, {double total = 7.5}) {
    return Booking(
      bookingNumber: number,
      summary: '1 x Test Film',
      total: total,
      date: DateTime(2026, 11, 1, 19, 30),
    );
  }

  group('CinemaDatabase creation', () {
    test('creates the bookings table', () async {
      final Database db = await cinemaDb.database;
      final List<Map<String, Object?>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' "
        "AND name = 'bookings'",
      );

      expect(tables.length, 1);
    });

    test('adds the sample bookings when first created', () async {
      final List<Booking> bookings = await cinemaDb.getAllBookings();

      expect(bookings.length, CinemaDatabase.sampleBookings.length);
      expect(bookings.length, 3);
    });

    test('sample bookings keep all their fields', () async {
      final List<Booking> bookings = await cinemaDb.getAllBookings();
      final Booking first = bookings.last;

      expect(first.bookingNumber, 'SC-0001');
      expect(first.summary, '2 x Dracula (1931)');
      expect(first.total, 15.0);
      expect(first.date, DateTime(2026, 10, 22, 18, 0));
      expect(first.id, isNotNull);
    });
  });

  group('CinemaDatabase saving and reading', () {
    test('getAllBookings returns the highest booking number first', () async {
      final List<Booking> bookings = await cinemaDb.getAllBookings();

      expect(
        bookings.map((b) => b.bookingNumber).toList(),
        ['SC-0003', 'SC-0002', 'SC-0001'],
      );
    });

    test('saveBooking returns the new id and stores the booking', () async {
      final int id = await cinemaDb.saveBooking(makeBooking('SC-0004'));

      expect(id, greaterThan(0));

      final List<Booking> bookings = await cinemaDb.getAllBookings();
      expect(bookings.length, 4);
      expect(bookings.first.id, id);
      expect(bookings.first.bookingNumber, 'SC-0004');
    });

    test('a saved booking keeps all its fields', () async {
      await cinemaDb.saveBooking(
        Booking(
          bookingNumber: 'SC-0004',
          summary: '2 x Halloween (1978)',
          total: 15,
          date: DateTime(2026, 11, 7, 21, 0),
        ),
      );

      final Booking saved = (await cinemaDb.getAllBookings()).first;

      expect(saved.bookingNumber, 'SC-0004');
      expect(saved.summary, '2 x Halloween (1978)');
      expect(saved.total, 15.0);
      expect(saved.date, DateTime(2026, 11, 7, 21, 0));
    });

    test('rejects a duplicate booking number', () async {
      expect(
        () => cinemaDb.saveBooking(makeBooking('SC-0001')),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('sorts booking numbers by their number, not as text', () async {
      await cinemaDb.saveBooking(makeBooking('SC-9999'));
      await cinemaDb.saveBooking(makeBooking('SC-10000'));

      final List<Booking> bookings = await cinemaDb.getAllBookings();

      expect(bookings.first.bookingNumber, 'SC-10000');
      expect(bookings[1].bookingNumber, 'SC-9999');
    });
  });

  group('CinemaDatabase booking numbers', () {
    test('formatBookingNumber pads the number to four digits', () {
      expect(CinemaDatabase.formatBookingNumber(1), 'SC-0001');
      expect(CinemaDatabase.formatBookingNumber(42), 'SC-0042');
      expect(CinemaDatabase.formatBookingNumber(12345), 'SC-12345');
    });

    test('next booking number follows the sample bookings', () async {
      expect(await cinemaDb.getNextBookingNumber(), 'SC-0004');
    });

    test('next booking number goes up after saving', () async {
      await cinemaDb.saveBooking(makeBooking('SC-0004'));

      expect(await cinemaDb.getNextBookingNumber(), 'SC-0005');
    });

    test('next booking number is SC-0001 in an empty database', () async {
      final Database db = await cinemaDb.database;
      await db.delete(CinemaDatabase.bookingTable);

      expect(await cinemaDb.getNextBookingNumber(), 'SC-0001');
    });

    test('next booking number handles numbers above 9999', () async {
      await cinemaDb.saveBooking(makeBooking('SC-10000'));

      expect(await cinemaDb.getNextBookingNumber(), 'SC-10001');
    });
  });

  group('CinemaDatabase close', () {
    test('close can be called twice without an error', () async {
      await cinemaDb.getAllBookings();

      await cinemaDb.close();
      await cinemaDb.close();
    });

    test('database can be used again after closing', () async {
      await cinemaDb.close();

      // A new in-memory database is created, with the samples again.
      expect((await cinemaDb.getAllBookings()).length, 3);
    });
  });
}
