import 'package:flutter/material.dart';
import 'package:working_message_mobile/constants/list.dart';

class FullMusicPlayerScreen extends StatefulWidget {
  FullMusicPlayerScreen({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _FullMusicPlayerScreenState createState() {
    return _FullMusicPlayerScreenState();
  }
}

class _FullMusicPlayerScreenState extends State<FullMusicPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationInfinityRotatePlayingController;
  late Animation<double> _animationInfinityRotatePlaying;

  @override
  void initState() {
    super.initState();
    _animationInfinityRotatePlayingController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _animationInfinityRotatePlaying = Tween(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(
      CurvedAnimation(
        parent: _animationInfinityRotatePlayingController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _animationInfinityRotatePlayingController.dispose();
    super.dispose();
  }

  bool isPlaying = false;
  double currentPosition = 0.0;
  double maxDuration = 100.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 20),
              child: ClipRRect(
                child: Image.asset(
                  Assets.MAKING_MY_WAVE,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: 24),
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 500),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
