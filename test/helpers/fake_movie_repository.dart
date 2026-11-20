import 'dart:async';

import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';

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

class FailingMovieRepository extends MovieRepository {
  @override
  Future<List<Movie>> loadMoviesFromAsset([
    String path = 'assets/data/movies.json',
  ]) {
    return Future.error(Exception('could not read movies.json'));
  }
}
