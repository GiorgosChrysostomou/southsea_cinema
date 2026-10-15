import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';

void main() {
  group('Movie', () {
    test('constructor assigns all properties', () {
      final movie = Movie(
        id: 'dracula',
        title: 'Dracula (1931)',
        synopsis: 'Count Dracula travels to London.',
        ageRating: 'PG',
        runtime: '75 min',
        screeningTime: 'Thursday 22 Oct 2026, 18:00',
        ticketPrice: 7.50,
        posterPath: 'assets/images/dracula.jpg',
      );

      expect(movie.id, 'dracula');
      expect(movie.title, 'Dracula (1931)');
      expect(movie.synopsis, 'Count Dracula travels to London.');
      expect(movie.ageRating, 'PG');
      expect(movie.runtime, '75 min');
      expect(movie.screeningTime, 'Thursday 22 Oct 2026, 18:00');
      expect(movie.ticketPrice, 7.50);
      expect(movie.posterPath, 'assets/images/dracula.jpg');
    });

    test('formattedPrice shows a whole-pound price with two decimals', () {
      final movie = Movie(
        id: 'halloween',
        title: 'Halloween (1978)',
        synopsis: 'Michael Myers returns home.',
        ageRating: '18',
        runtime: '91 min',
        screeningTime: 'Saturday 31 Oct 2026, 21:00',
        ticketPrice: 8,
        posterPath: 'assets/images/halloween.jpg',
      );

      expect(movie.formattedPrice, '£8.00');
    });

    test('formattedPrice shows a price with pence with two decimals', () {
      final movie = Movie(
        id: 'dracula',
        title: 'Dracula (1931)',
        synopsis: 'Count Dracula travels to London.',
        ageRating: 'PG',
        runtime: '75 min',
        screeningTime: 'Thursday 22 Oct 2026, 18:00',
        ticketPrice: 7.5,
        posterPath: 'assets/images/dracula.jpg',
      );

      expect(movie.formattedPrice, '£7.50');
    });
  });
}