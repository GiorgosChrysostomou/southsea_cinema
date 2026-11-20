import 'package:southsea_cinema/models/movie.dart';

class BasketItem {
  final Movie movie;
  int quantity;

  BasketItem({
    required this.movie,
    required this.quantity,
  });

  double get totalPrice => movie.ticketPrice * quantity;
}

class BasketRepository {
  final Map<String, BasketItem> _items = {};

  List<BasketItem> get items => _items.values.toList();

  int get totalTickets =>
      _items.values.fold(0, (total, item) => total + item.quantity);

  double get total =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  void addTicket(Movie movie, {int quantity = 1}) {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be greater than zero');
    }

    if (_items.containsKey(movie.id)) {
      _items[movie.id]!.quantity += quantity;
    } else {
      _items[movie.id] = BasketItem(
        movie: movie,
        quantity: quantity,
      );
    }
  }

  void removeTicket(Movie movie, {int quantity = 1}) {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be greater than zero');
    }

    final item = _items[movie.id];

    if (item == null) return;

    if (quantity >= item.quantity) {
      _items.remove(movie.id);
    } else {
      item.quantity -= quantity;
    }
  }

  void clearBasket() {
    _items.clear();
  }
}

final BasketRepository basketRepository = BasketRepository();
