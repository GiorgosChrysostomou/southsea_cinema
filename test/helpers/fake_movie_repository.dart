import 'dart:async';

import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';

// A repository that returns the films without reading any file.
// If a completer is given, the films only arrive when the test completes it.
class FakeMovieRepository extends MovieRepository {
  final Completer<List<Movie>>? completer;

  FakeMovieRepository({this.completer});

  @override
  Future<List<Movie>> loadMoviesFromAsset([
    String path = 'assets/data/movies.json',
  ]) {
    if (completer != null) {
      return completer!.future;
    }
    return Future.value(getMovies());
  }
}

// A repository whose loading always fails.
class FailingMovieRepository extends MovieRepository {
  @override
  Future<List<Movie>> loadMoviesFromAsset([
    String path = 'assets/data/movies.json',
  ]) {
    return Future.error(Exception('could not read movies.json'));
  }
}
