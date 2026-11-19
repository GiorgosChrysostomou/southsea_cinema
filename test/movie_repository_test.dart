import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MovieRepository unit tests', () {
    test('getMovies returns two movies', () {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = repository.getMovies();

      expect(movies.length, 2);
    });

    test('getMovies contains valid Dracula and Halloween films', () {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = repository.getMovies();

      final Movie dracula = movies[0];
      expect(dracula.id, 'dracula');
      expect(dracula.title, 'Dracula (1931)');
      expect(dracula.ageRating, 'PG');
      expect(dracula.ticketPrice, 7.50);
      expect(dracula.posterPath, 'assets/images/dracula.jpg');

      final Movie halloween = movies[1];
      expect(halloween.id, 'halloween');
      expect(halloween.title, 'Halloween (1978)');
      expect(halloween.ageRating, '18');
      expect(halloween.ticketPrice, 7.50);
      expect(halloween.posterPath, 'assets/images/halloween.jpg');
    });

    test('getMovieById returns matching movie when id exists', () {
      final MovieRepository repository = MovieRepository();
      final Movie? movie = repository.getMovieById('halloween');

      expect(movie, isNotNull);
      expect(movie?.title, 'Halloween (1978)');
      expect(movie?.ageRating, '18');
    });

    test('getMovieById returns null when id does not exist', () {
      final MovieRepository repository = MovieRepository();
      final Movie? movie = repository.getMovieById('non-existent');

      expect(movie, isNull);
    });
  });

  group('MovieRepository asset loading', () {
    test('loadMoviesFromAsset reads every film from movies.json', () async {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = await repository.loadMoviesFromAsset();

      expect(movies.length, 2);

      expect(movies[0].id, 'dracula');
      expect(movies[0].title, 'Dracula (1931)');
      expect(movies[0].ageRating, 'PG');
      expect(movies[0].ticketPrice, 7.50);
      expect(movies[0].posterPath, 'assets/images/dracula.jpg');

      expect(movies[1].id, 'halloween');
      expect(movies[1].title, 'Halloween (1978)');
      expect(movies[1].ageRating, '18');
      expect(movies[1].ticketPrice, 7.50);
      expect(movies[1].posterPath, 'assets/images/halloween.jpg');
    });

    test('loadMoviesFromAsset matches getMovies', () async {
      final MovieRepository repository = MovieRepository();
      final List<Movie> loaded = await repository.loadMoviesFromAsset();
      final List<Movie> hardCoded = repository.getMovies();

      expect(loaded.length, hardCoded.length);
      for (int i = 0; i < loaded.length; i++) {
        expect(loaded[i].toJson(), hardCoded[i].toJson());
      }
    });
  });
}