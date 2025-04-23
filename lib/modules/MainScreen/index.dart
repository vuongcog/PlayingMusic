import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:working_message_mobile/modules/AdminPage/index.dart';
import 'package:working_message_mobile/modules/FavoritPage/index.dart';
import 'package:working_message_mobile/modules/HomeScreen/index.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  late String _role = "";

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoriteScreen(),
    AdminMusicPage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkLogin();
    _checkRole();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null && token.isNotEmpty) {
      final decodedToken = JwtDecoder.decode(token);
      final role = decodedToken["role"];
      setState(() {
        _role = role;
      });
    } else {
      print("Không tìm thấy token, chưa đăng nhập.");
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    setState(() {
      _isLoggedIn = false;
      _role = "";
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<BottomNavigationBarItem> _buildBottomNavItems(String? role) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: 'Tìm nhạc',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.favorite),
        label: 'Yêu thích',
      ),
    ];

    if (role == "admin") {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.music_note),
          label: 'Quản lý nhạc',
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: const Text(
          "DANH SÁCH NHẠC",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (!_isLoggedIn) ...[
            IconButton(
              icon: const Icon(Icons.login),
              tooltip: 'Đăng nhập',
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
            IconButton(
              icon: const Icon(Icons.app_registration),
              tooltip: 'Đăng ký',
              onPressed: () => Navigator.pushNamed(context, '/register'),
            ),
          ],
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Đăng xuất',
              onPressed: _logout,
            ),
          SizedBox(width: 12),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _buildBottomNavItems(_role),
      ),
    );
  }
}
