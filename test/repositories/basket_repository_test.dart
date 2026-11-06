
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';

void main() {
  late BasketRepository basket;
  late Movie movie;

  setUp(() {
    basket = BasketRepository();

    movie = Movie(
      id: '1',
      title: 'The Batman',
      synopsis: 'A superhero film',
      ageRating: '12A',
      runtime: '2h 56m',
      screeningTime: '18:00',
      ticketPrice: 10.00,
      posterPath: 'assets/batman.jpg',
    );
  });

  test('Add tickets to basket', () {
    basket.addTicket(movie, quantity: 2);

    expect(basket.items.length, 1);
    expect(basket.items.first.quantity, 2);
  });

  test('Adding tickets to the same movie increases quantity', () {
    basket.addTicket(movie, quantity: 2);
    basket.addTicket(movie, quantity: 1);

    expect(basket.items.first.quantity, 3);
  });

  test('Remove tickets from basket', () {
    basket.addTicket(movie, quantity: 3);
    basket.removeTicket(movie);

    expect(basket.items.first.quantity, 2);
  });

  test('Remove all tickets when quantity reaches zero', () {
    basket.addTicket(movie, quantity: 2);
    basket.removeTicket(movie, quantity: 2);

    expect(basket.items, isEmpty);
  });

  test('Clear the entire basket', () {
    basket.addTicket(movie, quantity: 2);
    basket.clearBasket();

    expect(basket.items, isEmpty);
    expect(basket.total, 0);
  });

  test('Calculate the basket total correctly', () {
    basket.addTicket(movie, quantity: 3);

    expect(basket.total, 30.00);
  });

  test('Calculate total number of tickets', () {
    basket.addTicket(movie, quantity: 3);

    expect(basket.totalTickets, 3);
  });
}
