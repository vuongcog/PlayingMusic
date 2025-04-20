import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:working_message_mobile/constants/list.dart';
// Nếu bạn sử dụng LockCachingAudioSource, bạn cần import
// import 'package:just_audio_background/just_audio_background.dart';

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

  final AudioPlayer _player = AudioPlayer();

  // Biến theo dõi trạng thái
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String _playerStateText = "Đang khởi tạo";
  String _errorMessage = "";

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _loadAudio() async {
    debugPrint("DEBUG: Bắt đầu nạp audio");
    try {
      setState(() {
        _playerStateText = "Đang kết nối tới server...";
      });

      // Sử dụng ProgressiveAudioSource từ just_audio
      final audioSource = ProgressiveAudioSource(
        Uri.parse('http://192.168.3.102:3000/track/stream/alone.mp3'),
        headers: {
          'Range': 'bytes=0-', // Yêu cầu file từ byte 0 đến hết
        },
      );

      debugPrint(
        "DEBUG: Đã khởi tạo AudioSource với URI: http://10.0.2.2:3000/track/stream/alone.mp3",
      );

      // Lắng nghe trạng thái kết nối
      _player.processingStateStream.listen((state) {
        debugPrint("DEBUG: Trạng thái xử lý audio: $state");
        String stateText = "Không xác định";

        switch (state) {
          case ProcessingState.idle:
            stateText = "Chưa sẵn sàng";
            break;
          case ProcessingState.loading:
            stateText = "Đang tải...";
            break;
          case ProcessingState.buffering:
            stateText = "Đang đệm...";
            break;
          case ProcessingState.ready:
            stateText = "Sẵn sàng phát";
            break;
          case ProcessingState.completed:
            stateText = "Đã phát xong";
            break;
        }

        setState(() {
          _playerStateText = stateText;
        });
      });

      // Thiết lập AudioSource
      debugPrint("DEBUG: Đang thiết lập AudioSource...");
      await _player.setAudioSource(audioSource).catchError((error) {
        debugPrint("ERROR: Lỗi khi thiết lập AudioSource: $error");
        setState(() {
          _errorMessage = "Lỗi thiết lập: $error";
        });
        return null;
      });
      debugPrint("DEBUG: Đã thiết lập AudioSource thành công");

      // Lắng nghe thời lượng tổng cộng
      _player.durationStream.listen((duration) {
        if (duration != null) {
          debugPrint("DEBUG: Tổng thời lượng: ${duration.inSeconds} giây");
          setState(() {
            _totalDuration = duration;
          });
        }
      });

      // Lắng nghe vị trí hiện tại
      _player.positionStream.listen((position) {
        setState(() {
          _currentPosition = position;
        });
      });

      // Lắng nghe trạng thái phát
      _player.playerStateStream.listen((state) {
        debugPrint(
          "DEBUG: Trạng thái player: ${state.playing ? 'đang phát' : 'tạm dừng'}",
        );
        setState(() {
          _isPlaying = state.playing;
          if (_isPlaying) {
            _animationInfinityRotatePlayingController.repeat();
          } else {
            _animationInfinityRotatePlayingController.stop();
          }
        });
      });

      // Lắng nghe lỗi
      _player.playbackEventStream.listen(
        (event) {},
        onError: (Object e, StackTrace st) {
          debugPrint("ERROR: Lỗi trong quá trình phát: $e");
          setState(() {
            _errorMessage = "Lỗi phát: $e";
          });
        },
      );
    } catch (e) {
      debugPrint("ERROR: Lỗi tổng thể khi tải nhạc: $e");
      setState(() {
        _errorMessage = "Lỗi: $e";
      });
    }
  }

  void _debugNetworkRequest() async {
    debugPrint("DEBUG: Thử nghiệm kết nối trực tiếp...");

    try {
      // Import dart:io nếu chưa có
      // import 'dart:io';

      // Thử nghiệm kết nối HTTP đơn giản
      // final httpClient = HttpClient();
      // final request = await httpClient.getUrl(Uri.parse('http://10.0.2.2:3000/track/stream/alone.mp3'));
      // request.headers.add('Range', 'bytes=0-100');
      // final response = await request.close();
      // debugPrint("DEBUG: Kết quả truy vấn HTTP: ${response.statusCode}");
      // httpClient.close();

      // Hoặc thông báo rằng cần thêm import dart:io
      debugPrint(
        "DEBUG: Để kiểm tra kết nối network trực tiếp, hãy thêm import 'dart:io';",
      );
    } catch (e) {
      debugPrint("ERROR: Lỗi khi thử nghiệm kết nối: $e");
    }
  }

  // Hàm tua đến vị trí cụ thể
  void _seekToPosition(Duration position) {
    debugPrint("DEBUG: Tua đến vị trí: ${position.inSeconds} giây");
    _player.seek(position);
  }

  @override
  void initState() {
    super.initState();
    debugPrint("DEBUG: Khởi tạo MusicPlayerScreen");

    _loadAudio();
    _debugNetworkRequest();

    _animationInfinityRotatePlayingController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    );
    _animationInfinityRotatePlaying = Tween(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(
      CurvedAnimation(
        parent: _animationInfinityRotatePlayingController,
        curve: Curves.linear,
      ),
    );

    debugPrint("DEBUG: Đã khởi tạo animation controller");
  }

  @override
  void dispose() {
    debugPrint("DEBUG: Giải phóng tài nguyên");
    _animationInfinityRotatePlayingController.dispose();
    _player.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      debugPrint("DEBUG: Tạm dừng phát");
      _player.pause();
    } else {
      debugPrint("DEBUG: Bắt đầu phát");
      _player.play();
    }
  }

  void _skipForward() {
    final newPosition = _currentPosition + const Duration(seconds: 10);
    debugPrint(
      "DEBUG: Tua tới +10s (từ ${_currentPosition.inSeconds}s đến ${newPosition.inSeconds}s)",
    );
    _seekToPosition(
      newPosition < _totalDuration ? newPosition : _totalDuration,
    );
  }

  void _skipBackward() {
    final newPosition = _currentPosition - const Duration(seconds: 10);
    debugPrint(
      "DEBUG: Tua lùi -10s (từ ${_currentPosition.inSeconds}s đến ${newPosition.inSeconds}s)",
    );
    _seekToPosition(newPosition > Duration.zero ? newPosition : Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   title: Text("Music Player"),
      //   actions: [
      //     // Nút để refresh/reload audio
      //     IconButton(
      //       icon: Icon(Icons.refresh),
      //       onPressed: () {
      //         debugPrint("DEBUG: Tải lại audio");
      //         _player.stop();
      //         _loadAudio();
      //       },
      //     ),
      //   ],
      // ),
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
          Positioned.fill(
            child: Container(color: colorTheme.surface.withOpacity(0.36)),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 500,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colorTheme.surface.withOpacity(0.7),
                  ],
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

                // Container(
                //   margin: EdgeInsets.all(10),
                //   padding: EdgeInsets.all(10),
                //   decoration: BoxDecoration(
                //     color: Colors.black54,
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         "Debug Info:",
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       Text(
                //         "Trạng thái: $_playerStateText",
                //         style: TextStyle(color: Colors.white70),
                //       ),
                //       Text(
                //         "Vị trí: ${_currentPosition.inSeconds}s / ${_totalDuration.inSeconds}s",
                //         style: TextStyle(color: Colors.white70),
                //       ),
                //       if (_errorMessage.isNotEmpty)
                //         Text(
                //           "Lỗi: $_errorMessage",
                //           style: TextStyle(color: Colors.redAccent),
                //         ),
                //     ],
                //   ),
                // ),

                // Thêm ảnh đĩa quay ở đây
                SizedBox(
                  child: AnimatedBuilder(
                    animation: _animationInfinityRotatePlaying,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle:
                            _isPlaying
                                ? _animationInfinityRotatePlaying.value
                                : 0,
                        child: Container(
                          width: 300,
                          height: 300,
                          margin: EdgeInsets.all(50),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),

                          child: ClipOval(
                            child: Image.asset(
                              Assets.MAKING_MY_WAVE,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            Assets.MAKING_MY_WAVE,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Sơn Tùng MTP",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Slider và hiển thị thời gian
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          thumbColor: Colors.white,
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white30,
                          trackHeight: 2.0,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 8.0,
                          ),
                        ),
                        child: Slider(
                          min: 0.0,
                          max:
                              _totalDuration.inMilliseconds.toDouble() == 0
                                  ? 1.0
                                  : _totalDuration.inMilliseconds.toDouble(),
                          value: _currentPosition.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              _currentPosition = Duration(
                                milliseconds: value.toInt(),
                              );
                            });
                          },
                          onChangeEnd: (value) {
                            _seekToPosition(
                              Duration(milliseconds: value.toInt()),
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_currentPosition),
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              _formatDuration(_totalDuration),
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Các nút điều khiển
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.replay_10,
                        color: Colors.white,
                        size: 60,
                      ),
                      onPressed: _skipBackward,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      iconSize: 80,
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_circle_filled_outlined
                            : Icons.play_circle_fill_outlined,
                        color: Colors.white,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(
                        Icons.forward_10,
                        color: Colors.white,
                        size: 60,
                      ),
                      onPressed: _skipForward,
                    ),
                  ],
                ),

                // Nút stop và reload riêng biệt

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     ElevatedButton.icon(
                //       onPressed: () {
                //         debugPrint("DEBUG: Dừng phát");
                //         _player.stop();
                //       },
                //       icon: Icon(Icons.stop),
                //       label: Text("Stop"),
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.redAccent,
                //       ),
                //     ),
                //   ],
                // ),
                // SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
