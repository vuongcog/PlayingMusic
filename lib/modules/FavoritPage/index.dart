import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:working_message_mobile/constants/list.dart';
import 'package:working_message_mobile/model/track.dart';
import 'package:working_message_mobile/modules/MusicPlayerScreen/index.dart';
import 'package:working_message_mobile/utils/shared.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  String? userId;
  List<Track> tracks = [];
  bool isLoading = true;

  Future<void> fetchLikedTracks() async {
    setState(() {
      isLoading = true;
    });

    String? userId = await getUserIdFromToken();
    if (userId != null) {
      final url = "${Assets.API_URL}/user/like/$userId";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          tracks = data.map((e) => Track.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        print('Không thể lấy danh sách bài hát yêu thích');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addLikeTrack(String trackId) async {
    String? userId = await getUserIdFromToken();
    if (userId != null) {
      final response = await http.post(
        Uri.parse('${Assets.API_URL}/user/$userId/like/$trackId'),
      );

      if (response.statusCode == 200) {
        print('Đã thêm bài hát vào danh sách yêu thích');
        fetchLikedTracks(); // Cập nhật lại danh sách yêu thích
      } else {
        print('Lỗi khi thêm bài hát vào danh sách yêu thích');
      }
    }
  }

  Future<void> removeLikeTrack(String trackId) async {
    String? userId = await getUserIdFromToken();
    if (userId != null) {
      final response = await http.delete(
        Uri.parse('${Assets.API_URL}/user/$userId/like/$trackId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa khỏi danh sách yêu thích'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 1),
          ),
        );
        fetchLikedTracks();
      } else {
        print('Lỗi khi xóa bài hát khỏi danh sách yêu thích');
      }
    }
  }

  String formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    fetchLikedTracks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'Bài hát yêu thích',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child:
            isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                )
                : tracks.isEmpty
                ? _buildEmptyState()
                : _buildTracksList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Chưa có bài hát yêu thích',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nhấn icon trái tim để thêm bài hát vào đây',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTracksList() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 10),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        Track track = tracks[index];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Card(
            color: Color(0xFF1E1E1E),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          track.imageUrl != null && track.imageUrl!.isNotEmpty
                              ? Image.network(
                                "${Assets.IMAGE_URL}/${track.imageUrl!}",
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[800],
                                    child: Icon(
                                      Icons.music_note,
                                      color: Colors.white54,
                                      size: 30,
                                    ),
                                  );
                                },
                              )
                              : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[800],
                                child: Icon(
                                  Icons.music_note,
                                  color: Colors.white54,
                                  size: 30,
                                ),
                              ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            track.artist,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              if (track.album != null &&
                                  track.album!.isNotEmpty)
                                Flexible(
                                  child: Text(
                                    track.album!,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if (track.album != null &&
                                  track.album!.isNotEmpty)
                                SizedBox(width: 8),
                              Text(
                                formatDuration(track.duration),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.red[400],
                        size: 28,
                      ),
                      onPressed: () {
                        removeLikeTrack(track.id);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.play_arrow, size: 28),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullMusicPlayerScreen(track: track),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
