import 'package:flutter/material.dart';
import 'package:working_message_mobile/modules/FavoritPage/index.dart';
import 'package:working_message_mobile/modules/HomeScreen/index.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(), // Trang tìm kiếm nhạc
    FavoriteScreen(), // Trang nhạc yêu thích
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm nhạc'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
        ],
      ),
    );
  }
}
