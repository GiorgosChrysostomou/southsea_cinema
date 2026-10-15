import 'package:southsea_cinema/models/movie.dart';

class MovieRepository {
  List<Movie> getMovies() {
    return [
      Movie(
        id: 'dracula',
        title: 'Dracula (1931)',
        synopsis:
            'Count Dracula leaves Transylvania for London, where he preys on the young and the beautiful.',
        ageRating: 'PG',
        runtime: '75 min',
        screeningTime: 'Thursday 22 Oct 2026, 18:00',
        ticketPrice: 7.50,
        posterPath: 'assets/images/dracula.jpg',
      ),
      Movie(
        id: 'halloween',
        title: 'Halloween (1978)',
        synopsis:
            'Fifteen years after a Halloween murder, Michael Myers escapes and returns to his hometown to kill again.',
        ageRating: '18',
        runtime: '91 min',
        screeningTime: 'Saturday 31 Oct 2026, 21:00',
        ticketPrice: 7.50,
        posterPath: 'assets/images/halloween.jpg',
      ),
    ];
  }
}
