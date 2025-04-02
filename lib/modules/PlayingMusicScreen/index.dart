import 'package:flutter/material.dart';
import 'package:working_message_mobile/constants/list.dart';

class MusicPlayerScreen extends StatefulWidget {
  MusicPlayerScreen({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MusicPlayerScreenState createState() {
    return _MusicPlayerScreenState();
  }
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
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
    _animationInfinityRotatePlayingController
        .dispose(); // Hủy controller khi không còn sử dụng
    super.dispose();
  }

  bool isPlaying = false;
  double currentPosition = 0.0;
  double maxDuration = 100.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), elevation: 0),
      body: Column(
        children: [
          Center(
            child: RotationTransition(
              turns: _animationInfinityRotatePlaying,
              child: Container(
                width: 300,
                height: 300,
                margin: EdgeInsets.symmetric(vertical: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(150),
                  child: Image.asset(
                    Assets.Card,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
