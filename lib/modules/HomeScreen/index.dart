import 'package:flutter/material.dart';
import 'package:working_message_mobile/components/ToggleNav/index.dart';
import 'package:working_message_mobile/constants/list.dart';
import 'package:working_message_mobile/modules/MusicPlayerScreen/index.dart';
import 'package:working_message_mobile/modules/PlayingMusicScreen/index.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _handleToggle(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;

    return Scaffold(
      // appBar: AppBar(title: Text('Home')),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              height: 156,
              child: Text(
                "DANNY AVILLA ALBUMES",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            ToggleNav(
              selectedIndex: _selectedIndex,
              onPressed: _handleToggle,
              colorTheme: colorTheme,
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    10,
                    (index) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => FullMusicPlayerScreen(
                                  title: "Making My Way",
                                ),
                          ),
                        );
                      },
                      child: Container(
                        width: 144,
                        height: 186,
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 140,
                              child: Image.asset(Assets.Card),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                              ),
                              child: Tooltip(
                                message: "The Caption Single",
                                child: Text(
                                  'The Caption Single Single Single',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
