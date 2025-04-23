import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:working_message_mobile/constants/list.dart';
import 'package:working_message_mobile/model/track.dart';
import 'package:working_message_mobile/modules/MusicPlayerScreen/index.dart';
import 'package:working_message_mobile/utils/shared.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Track> tracks = [];
  List<String> likedTrackIds = []; // Danh sách các track đã yêu thích theo id
  int currentPage = 1;
  int totalPages = 1;
  final int pageSize = 10;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await fetchLikedTracks();
      await fetchTracks();
    } catch (e) {
      print("Lỗi khi khởi tạo dữ liệu: $e");
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
        fetchLikedTracks();
      } else {
        print('Lỗi khi thêm bài hát vào danh sách yêu thích');
      }
    }
  }

  Future<void> fetchLikedTracks() async {
    String? userId = await getUserIdFromToken();
    final url = "${Assets.API_URL}/user/like/${userId}";
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List result = jsonDecode(response.body);
        setState(() {
          likedTrackIds = result.map((e) => e['id'] as String).toList();
        });
      } else {
        print("❌ Lỗi khi fetch liked tracks: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Exception khi fetch liked tracks: $e");
    }
  }

  Future<void> fetchTracks() async {
    final uri = Uri.parse(
      '${Assets.API_URL}/track?page=$currentPage&limit=$pageSize&search=$searchQuery',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        final List<dynamic> items = result['data'];
        setState(() {
          tracks = items.map((e) => Track.fromJson(e)).toList();
          totalPages = result['totalPages'];
        });
      } else {
        print("❌ Lỗi khi fetch tracks: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Exception khi fetch tracks: $e");
    }
  }

  void _onSearch(String value) {
    setState(() {
      searchQuery = value.trim();
      currentPage = 1;
    });
    fetchTracks();
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      setState(() => currentPage = page);
      fetchTracks();
    }
  }

  void _toggleLike(Track track) async {
    final bool wasLiked = likedTrackIds.contains(track.id);

    setState(() {
      if (wasLiked) {
        likedTrackIds.remove(track.id);
      } else {
        likedTrackIds.add(track.id);
      }
    });

    String? userId = await getUserIdFromToken();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thích bài hát')),
      );

      setState(() {
        if (wasLiked) {
          likedTrackIds.add(track.id);
        } else {
          likedTrackIds.remove(track.id);
        }
      });
      return;
    }

    try {
      final url = '${Assets.API_URL}/user/$userId/like/${track.id}';
      final response = await http
          .post(Uri.parse('${Assets.API_URL}/user/$userId/like/${track.id}'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        print(
          'Lỗi khi thêm bài hát vào danh sách yêu thích: ${response.statusCode}',
        );
        setState(() {
          if (wasLiked) {
            likedTrackIds.add(track.id);
          } else {
            likedTrackIds.remove(track.id);
          }
        });
      }
    } catch (e) {
      print('Exception khi thêm bài hát vào danh sách yêu thích: $e');
      setState(() {
        if (wasLiked) {
          likedTrackIds.add(track.id);
        } else {
          likedTrackIds.remove(track.id);
        }
      });
    }
  }

  String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  // Hàm tiện ích để định dạng DateTime (ví dụ: 12/04/2025)
  String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  Widget buildTrackListTile({
    required BuildContext context,
    required Track track,
    required List<String> likedTrackIds,
    required Function(Track) onToggleLike,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          '${Assets.IMAGE_URL}/${track.imageUrl}',
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) =>
                  const Icon(Icons.image_not_supported, color: Colors.white),
        ),
      ),
      title: Text(
        track.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            track.artist,
            style: const TextStyle(color: Colors.white70),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Album: ${track.album ?? 'Không có'}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Thể loại: ${track.genre ?? 'Không có'}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Thời lượng: ${formatDuration(track.duration)}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Tạo: ${formatDate(track.createdAt)}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Bỏ qua updatedAt để giữ giao diện gọn, có thể thêm nếu cần
          // Text(
          //   'Cập nhật: ${formatDate(track.updatedAt)}',
          //   style: const TextStyle(color: Colors.white54, fontSize: 12),
          //   maxLines: 1,
          //   overflow: TextOverflow.ellipsis,
          // ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          likedTrackIds.contains(track.id)
              ? Icons.favorite
              : Icons.favorite_border,
          color: likedTrackIds.contains(track.id) ? Colors.red : Colors.white,
        ),
        onPressed: () {
          onToggleLike(track); // Cập nhật like/unlike
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullMusicPlayerScreen(track: track),
          ),
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$remainingSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Bài hát mới nhất",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onSubmitted: _onSearch,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '🔍 Tìm kiếm bài hát...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white12,
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      _searchController.clear();
                      _onSearch('');
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    tracks.isEmpty
                        ? const Center(
                          child: Text(
                            "Không có kết quả",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                        : ListView.builder(
                          itemCount: tracks.length,
                          itemBuilder: (context, index) {
                            final track = tracks[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 12,
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  '${Assets.IMAGE_URL}/${track.imageUrl}',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                              title: Text(
                                track.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.artist,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        "Thể loại: ",
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Tooltip(
                                        message: 'Thể loại: ${track.genre}',
                                        child: Container(
                                          width: 40,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            track.genre!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.timer,
                                        size: 14,
                                        color: Colors.white38,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDuration(
                                          track.duration,
                                        ), // Chuyển thời lượng giây → mm:ss
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  likedTrackIds.contains(track.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      likedTrackIds.contains(track.id)
                                          ? Colors.red
                                          : Colors.white,
                                ),
                                onPressed: () {
                                  _toggleLike(track);
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            FullMusicPlayerScreen(track: track),
                                  ),
                                );
                              },
                            );
                          },
                        ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => _goToPage(currentPage - 1),
                  ),
                  Text(
                    'Trang $currentPage / $totalPages',
                    style: const TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                    onPressed: () => _goToPage(currentPage + 1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
