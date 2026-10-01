import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

class MovieListing extends StatefulWidget {
  const MovieListing({super.key});

  @override
  State<MovieListing> createState() => _MovieListingState();
}

class _MovieListingState extends State<MovieListing> {
  int _quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle, style: cinemaHeaderStyle),
        backgroundColor: cinemaSurface,
        iconTheme: const IconThemeData(color: cinemaBrand),
        elevation: 0,
      ),
      drawer: const NavDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DRACULA (1931) (PG)', style: TextStyle(fontSize: 32)),
          SizedBox(height: 35),
          Text('Southsea Cinema Room', style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          Text('Thrusday 22 Oct 2026, 18:00 - ends at 19:14',
              style: TextStyle(fontSize: 16)),
          SizedBox(height: 30),
          Text(
              'Please note that Discounts / Membership Benefits will be applied once you have selected your ticckets',
              style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          Text('Select Quantities(up to 5 in total)',
              style: TextStyle(fontSize: 16)),
          SizedBox(height: 30),
          Text('Tickets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Row(
            children: [
              DropdownButton<int>(
                  value: _quantity,
                  items: [
                    DropdownMenuItem(value: 0, child: Text('0')),
                    DropdownMenuItem(value: 1, child: Text('1')),
                    DropdownMenuItem(value: 2, child: Text('2')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _quantity = value!;
                    });
                  }),
              SizedBox(width: 12),
              Text('Adult (£7.50)'),
            ],
          )
        ],
      ),
    );
  }
}
