import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:working_message_mobile/app-routers/index.dart';
import 'package:working_message_mobile/objects/app_theme.dart';
import 'package:working_message_mobile/objects/theme_provider.dart';

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
      initialRoute: '/',
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

class _HomePage extends State<HomePage> {
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
                      // width: 356,
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
            SizedBox(height: 40),
            Center(
              child: MaterialButton(
                minWidth: 170,
                height: 60,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () {},
                color: colorTheme.secondary,
                child: MaterialButton(
                  onPressed: () => {Navigator.pushNamed(context, '/home')},
                  child: Text(
                    "Get Started",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
