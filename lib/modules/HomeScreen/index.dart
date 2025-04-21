import 'package:flutter/material.dart';
import 'package:working_message_mobile/components/ToggleNav/index.dart';
import 'package:working_message_mobile/constants/list.dart';
import 'package:working_message_mobile/modules/MusicPlayerScreen/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<dynamic> tracks = [];

  @override
  void initState() {
    super.initState();
    fetchTracks();
  }

  void _handleToggle(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> fetchTracks() async {
    try {
      final response = await http.get(Uri.parse('${Assets.API_URL}/track'));
      if (response.statusCode == 200) {
        setState(() {
          tracks = jsonDecode(response.body);
        });
      } else {
        print('❌ Lỗi khi fetch track: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Exception khi fetch track: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
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
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      tracks.map((track) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => FullMusicPlayerScreen(
                                      title:
                                          track['title'] ?? 'Không rõ tiêu đề',
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            width: 144,
                            height: 186,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 140,
                                  child: Image.asset(Assets.Card),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Tooltip(
                                    message: track['artist'] ?? '',
                                    child: Text(
                                      track['title'] ?? 'Không có tiêu đề',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
