import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:working_message_mobile/constants/list.dart';
import 'package:working_message_mobile/model/track.dart';
import 'package:working_message_mobile/modules/MusicPlayerScreen/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Track> tracks = [];
  int currentPage = 1;
  int totalPages = 1;
  final int pageSize = 10;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTracks();
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
              const Text(
                "DANH SÁCH NHẠC",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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
                                vertical: 4,
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
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                track.artist,
                                style: const TextStyle(color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
