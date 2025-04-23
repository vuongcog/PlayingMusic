import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:working_message_mobile/app-routers/index.dart';
import 'package:working_message_mobile/objects/app_theme.dart';
import 'package:working_message_mobile/objects/theme_provider.dart';
import 'package:working_message_mobile/utils/shared.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: "Stream Video",
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.isDartMode ? ThemeMode.dark : ThemeMode.light,
      // home: HomePage(),
      initialRoute: '/splash',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> with WidgetsBindingObserver {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLoginStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Trang được hiển thị lại (ví dụ: sau khi vuốt quay lại)
      _checkLoginStatus();
    }
  }

  // Kiểm tra trạng thái đăng nhập
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Gỡ observer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: Switch(
          value: themeProvider.isDartMode,
          onChanged: (value) {
            themeProvider.toggleTheme();
          },
        ),
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            "assets/images/main-image/home.png",
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 50,
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 175,
                        child: Text(
                          "“How is it that music can, without words, evoke our laughter, our fears, our highest aspirations?”",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, height: 12 / 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: MaterialButton(
                minWidth: 170,
                height: 60,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () => Navigator.pushNamed(context, '/home'),
                color: colorTheme.secondary,
                child: Text(
                  "Get Started",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (!_isLoggedIn) // Chỉ hiển thị nếu chưa đăng nhập
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: Text(
                        "Đăng nhập",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    MaterialButton(
                      onPressed:
                          () => Navigator.pushNamed(context, '/register'),
                      child: Text(
                        "Đăng ký",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
