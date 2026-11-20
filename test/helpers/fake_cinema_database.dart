import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';

class FakeCinemaDatabase extends CinemaDatabase {
  final List<Booking> saved = [];
  final bool failSaving;
  int _nextId = 1;

  FakeCinemaDatabase({bool withSamples = false, this.failSaving = false}) {
    if (withSamples) {
      for (final Booking booking in CinemaDatabase.sampleBookings) {
        saved.add(_withId(booking));
      }
    }
  }

  Booking _withId(Booking booking) {
    return Booking(
      id: _nextId++,
      bookingNumber: booking.bookingNumber,
      summary: booking.summary,
      total: booking.total,
      date: booking.date,
    );
  }

  int _numberOf(Booking booking) {
    return int.parse(booking.bookingNumber.substring(3));
  }

  @override
  Future<int> saveBooking(Booking booking) async {
    if (failSaving) {
      throw Exception('could not save');
    }

    final Booking stored = _withId(booking);
    saved.add(stored);
    return stored.id!;
  }

  @override
  Future<List<Booking>> getAllBookings() async {
    final List<Booking> sorted = List<Booking>.of(saved);
    sorted.sort((a, b) => _numberOf(b).compareTo(_numberOf(a)));
    return sorted;
  }

  @override
  Future<String> getNextBookingNumber() async {
    int highest = 0;
    for (final Booking booking in saved) {
      if (_numberOf(booking) > highest) {
        highest = _numberOf(booking);
      }
    }
    return CinemaDatabase.formatBookingNumber(highest + 1);
  }

  @override
  Future<void> close() async {}
}
