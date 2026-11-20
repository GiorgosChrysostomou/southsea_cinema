import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

class BasketView extends StatefulWidget {
  final CinemaDatabase? database;

  const BasketView({super.key, this.database});

  @override
  State<BasketView> createState() => _BasketViewState();
}

class _BasketViewState extends State<BasketView> {
  late final CinemaDatabase _database;

  List<Booking> _bookings = [];
  bool _isLoadingBookings = true;
  String? _bookingsError;

  @override
  void initState() {
    super.initState();
    _database = widget.database ?? cinemaDatabase;
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final List<Booking> bookings = await _database.getAllBookings();

      if (!mounted) return;

      setState(() {
        _bookings = bookings;
        _bookingsError = null;
        _isLoadingBookings = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _bookingsError = 'Could not load bookings';
        _isLoadingBookings = false;
      });
    }
  }

  Future<void> _checkout() async {
    final List<BasketItem> items = basketRepository.items;
    if (items.isEmpty) return;

    final String summary = items
        .map((item) => '${item.quantity} x ${item.movie.title}')
        .join(', ');
    final double total = basketRepository.total;

    String bookingNumber;
    try {
      bookingNumber = await _database.getNextBookingNumber();
      await _database.saveBooking(
        Booking(
          bookingNumber: bookingNumber,
          summary: summary,
          total: total,
          date: DateTime.now(),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      // Saving failed, so the basket is left as it was.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save booking'),
        ),
      );
      return;
    }

    // Only clear the basket once the booking is saved.
    basketRepository.clearBasket();

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking $bookingNumber confirmed'),
      ),
    );

    await _loadBookings();
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _formatDate(DateTime date) {
    return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year} '
        '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  List<Widget> _buildBasket(List<BasketItem> items) {
    return [
      const Text(
        'Your Tickets',
        style: TextStyle(
          color: cinemaFontWhite,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      for (final BasketItem item in items)
        Card(
          color: cinemaSurface,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              item.movie.title,
              style: const TextStyle(
                color: cinemaFontWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${item.quantity} ticket(s) x '
              '${item.movie.formattedPrice}\n'
              'Total: £${item.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                color: cinemaFontMuted,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete,
                color: cinemaBrand,
              ),
              onPressed: () {
                setState(() {
                  basketRepository.removeTicket(
                    item.movie,
                    quantity: item.quantity,
                  );
                });
              },
            ),
          ),
        ),
      const Divider(color: cinemaFontMuted),
      Text(
        'Total: £${basketRepository.total.toStringAsFixed(2)}',
        style: const TextStyle(
          color: cinemaFontWhite,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      PrimaryButton(
        label: 'CLEAR BASKET',
        onPressed: () {
          setState(() {
            basketRepository.clearBasket();
          });
        },
      ),
      const SizedBox(height: 12),
      PrimaryButton(
        label: 'CHECKOUT',
        onPressed: _checkout,
      ),
    ];
  }

  List<Widget> _buildPastBookings() {
    final List<Widget> widgets = [
      const Text(
        'Past Bookings',
        style: TextStyle(
          color: cinemaFontWhite,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
    ];

    if (_isLoadingBookings) {
      widgets.add(const Center(child: CircularProgressIndicator()));
    } else if (_bookingsError != null) {
      widgets.add(
        Text(
          _bookingsError!,
          style: const TextStyle(color: cinemaFontWhite, fontSize: 16),
        ),
      );
    } else if (_bookings.isEmpty) {
      widgets.add(
        const Text(
          'You have no past bookings yet',
          style: TextStyle(color: cinemaFontMuted, fontSize: 16),
        ),
      );
    } else {
      for (final Booking booking in _bookings) {
        widgets.add(
          Card(
            color: cinemaSurface,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                'Booking ${booking.bookingNumber}',
                style: const TextStyle(
                  color: cinemaFontWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${booking.summary}\n'
                'Total: ${booking.formattedTotal} - '
                '${_formatDate(booking.date)}',
                style: const TextStyle(
                  color: cinemaFontMuted,
                ),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final List<BasketItem> items = basketRepository.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Basket'),
      ),
      drawer: const NavDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Your basket is empty',
                  style: TextStyle(
                    color: cinemaFontWhite,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          else
            ..._buildBasket(items),
          const SizedBox(height: 24),
          const Divider(color: cinemaFontMuted),
          const SizedBox(height: 16),
          ..._buildPastBookings(),
        ],
      ),
    );
  }
}
