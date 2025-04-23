import 'package:flutter/material.dart';
import 'package:working_message_mobile/app/index.dart';
import 'package:working_message_mobile/modules/AdminPage/index.dart';
import 'package:working_message_mobile/modules/LoginPage/index.dart';
import 'package:working_message_mobile/modules/MainScreen/index.dart';
import 'package:working_message_mobile/modules/PlashScreen/index.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/home':
        return MaterialPageRoute(builder: (_) => MainScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminMusicPage());
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(child: Text("404 - Không tìm thấy trang !")),
              ),
        );
    }
  }
}
