import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:working_message_mobile/constants/list.dart';
import 'package:working_message_mobile/model/track.dart';
import 'package:working_message_mobile/modules/MusicPlayerScreen/index.dart';
import 'package:working_message_mobile/utils/show-confirm-dialog.dart';

class AdminMusicPage extends StatefulWidget {
  const AdminMusicPage({super.key});

  @override
  State<AdminMusicPage> createState() => _AdminMusicPageState();
}

class _AdminMusicPageState extends State<AdminMusicPage> {
  List<Track> tracks = [];
  final TextEditingController searchController = TextEditingController();
  int currentPage = 1;
  int totalPages = 1;
  final int limit = 10;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTracks();
    searchController.addListener(() {
      setState(() {
        currentPage = 1;
      });
      fetchTracks();
    });
  }

  Future<void> fetchTracks({bool isRefresh = false}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      if (isRefresh) tracks.clear();
    });

    try {
      final queryParams = {
        'page': currentPage.toString(),
        'limit': limit.toString(),
        'search': searchController.text.trim(),
      };
      final uri = Uri.parse(
        '${Assets.API_URL}/track',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        final int pages = jsonResponse['totalPages'] ?? 1;

        setState(() {
          tracks = data.map((e) => Track.fromJson(e)).toList();
          totalPages = pages;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ Không thể tải danh sách bài hát: ${response.body}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('⚠️ Lỗi: $e')));
      }
    }
  }

  Future<void> deleteTrack(String trackId) async {
    final response = await http.delete(
      Uri.parse('${Assets.API_URL}/track/$trackId'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('🗑️ Xoá thành công')));
      fetchTracks(isRefresh: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Xoá thất bại: ${response.body}')),
      );
    }
  }

  void showEditTrackDialog(Track track) {
    final parentContext = context;
    final TextEditingController editTitle = TextEditingController(
      text: track.title,
    );
    final TextEditingController editArtist = TextEditingController(
      text: track.artist,
    );
    final TextEditingController editAlbum = TextEditingController(
      text: track.album ?? '',
    );
    final TextEditingController editGenre = TextEditingController(
      text: track.genre ?? '',
    );

    File? newMusicFile;
    File? newImageFile;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('🛠️ Chỉnh sửa bài hát'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: editTitle,
                          decoration: const InputDecoration(
                            labelText: '🎵 Tiêu đề',
                          ),
                        ),
                        TextField(
                          controller: editArtist,
                          decoration: const InputDecoration(
                            labelText: '👤 Ca sĩ',
                          ),
                        ),
                        TextField(
                          controller: editAlbum,
                          decoration: const InputDecoration(
                            labelText: '💿 Album',
                          ),
                        ),
                        TextField(
                          controller: editGenre,
                          decoration: const InputDecoration(
                            labelText: '🎶 Thể loại',
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.music_note),
                          label: const Text("Chọn file nhạc mới (tuỳ chọn)"),
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.audio,
                            );
                            if (result?.files.single.path != null) {
                              setState(
                                () =>
                                    newMusicFile = File(
                                      result!.files.single.path!,
                                    ),
                              );
                            }
                          },
                        ),
                        if (newMusicFile != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '🎵 Nhạc mới: ${newMusicFile!.path.split('/').last}',
                            ),
                          ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.image),
                          label: const Text("Chọn ảnh bìa mới (tuỳ chọn)"),
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                            );
                            if (result?.files.single.path != null) {
                              setState(
                                () =>
                                    newImageFile = File(
                                      result!.files.single.path!,
                                    ),
                              );
                            }
                          },
                        ),
                        if (newImageFile != null) ...[
                          const SizedBox(height: 4),
                          Image.file(
                            newImageFile!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Huỷ"),
                      onPressed: () => Navigator.of(parentContext).pop(),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Lưu"),
                      onPressed: () async {
                        Navigator.of(parentContext).pop();
                        showDialog(
                          context: parentContext,
                          barrierDismissible: false,
                          builder:
                              (_) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                        );

                        try {
                          final uri = Uri.parse(
                            '${Assets.API_URL}/track/${track.id}',
                          );
                          final req = http.MultipartRequest('PUT', uri);
                          req.fields['title'] = editTitle.text;
                          req.fields['artist'] = editArtist.text;
                          req.fields['album'] = editAlbum.text;
                          req.fields['genre'] = editGenre.text;

                          if (newMusicFile != null) {
                            final part = await http.MultipartFile.fromPath(
                              'audio',
                              newMusicFile!.path,
                            );
                            req.files.add(part);
                          }

                          if (newImageFile != null) {
                            final partImg = await http.MultipartFile.fromPath(
                              'image',
                              newImageFile!.path,
                            );
                            req.files.add(partImg);
                          }

                          final streamed = await req.send();
                          final body = await streamed.stream.bytesToString();
                          Navigator.of(parentContext).pop();

                          if (streamed.statusCode == 200) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Cập nhật thành công'),
                              ),
                            );
                            fetchTracks(isRefresh: true);
                          } else {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(content: Text('❌ Lỗi: $body')),
                            );
                          }
                        } catch (e, st) {
                          Navigator.of(parentContext).pop();
                          debugPrint('Update error: $e\n$st');
                          ScaffoldMessenger.of(
                            parentContext,
                          ).showSnackBar(SnackBar(content: Text('⚠️ Lỗi: $e')));
                        }
                      },
                    ),
                  ],
                ),
          ),
    );
  }

  void showUploadDialog() {
    final parentContext = context;

    final TextEditingController titleController = TextEditingController();
    final TextEditingController artistController = TextEditingController();
    final TextEditingController albumController = TextEditingController();
    final TextEditingController genreController = TextEditingController();
    File? selectedMusicFile;
    String? musicFileName;
    File? selectedImageFile;
    String? imageFileName;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('🎵 Upload Bài Hát'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PickerCard(
                          icon: Icons.upload_file,
                          label: musicFileName ?? 'Chọn nhạc',
                          onTap: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.audio,
                            );
                            if (result?.files.single.path != null) {
                              setState(() {
                                selectedMusicFile = File(
                                  result!.files.single.path!,
                                );
                                musicFileName = result.files.single.name;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _PickerCard(
                          icon: Icons.image,
                          label: imageFileName ?? 'Chọn ảnh',
                          onTap: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                            );
                            if (result?.files.single.path != null) {
                              setState(() {
                                selectedImageFile = File(
                                  result!.files.single.path!,
                                );
                                imageFileName = result.files.single.name;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildField('Tiêu đề', titleController),
                        const SizedBox(height: 12),
                        _buildField('Ca sĩ', artistController),
                        const SizedBox(height: 12),
                        _buildField('Album', albumController),
                        const SizedBox(height: 12),
                        _buildField('Thể loại', genreController),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Huỷ"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text("Gửi"),
                      onPressed: () async {
                        if (selectedMusicFile == null ||
                            selectedImageFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '⚠️ Vui lòng chọn file nhạc và ảnh bìa!',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.of(context).pop(); // Đóng dialog upload

                        // Lưu context hiện tại để sử dụng sau này
                        final dialogContext = parentContext;

                        // Hiển thị loading dialog
                        showDialog(
                          context: dialogContext,
                          barrierDismissible: false,
                          builder:
                              (_) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                        );

                        try {
                          var request = http.MultipartRequest(
                            'POST',
                            Uri.parse('${Assets.API_URL}/track/upload'),
                          );
                          request.files.add(
                            await http.MultipartFile.fromPath(
                              'audio',
                              selectedMusicFile!.path,
                            ),
                          );
                          request.files.add(
                            await http.MultipartFile.fromPath(
                              'image',
                              selectedImageFile!.path,
                            ),
                          );
                          request.fields['title'] = titleController.text;
                          request.fields['artist'] = artistController.text;
                          request.fields['album'] = albumController.text;
                          request.fields['genre'] = genreController.text;

                          var response = await request.send();

                          // Sử dụng dialogContext đã lưu để đóng loading dialog
                          Navigator.of(dialogContext).pop();

                          if (response.statusCode == 201) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('🎉 Upload thành công!'),
                              ),
                            );
                            fetchTracks(isRefresh: true);
                          } else {
                            final responseBody =
                                await response.stream.bytesToString();
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '❌ Upload thất bại! $responseBody',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          // Sử dụng dialogContext đã lưu để đóng loading dialog trong trường hợp lỗi
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(
                            dialogContext,
                          ).showSnackBar(SnackBar(content: Text('⚠️ Lỗi: $e')));
                        }
                      },
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.refresh),
      //       onPressed: () => fetchTracks(isRefresh: true),
      //     ),
      //   ],
      // ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close, // icon chuyển động
        backgroundColor: Colors.amber,
        overlayOpacity: 0.1,
        children: [
          SpeedDialChild(
            child: Icon(Icons.refresh),
            onTap: () => fetchTracks(isRefresh: true),
          ),
          SpeedDialChild(child: Icon(Icons.add), onTap: showUploadDialog),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Thanh tìm kiếm
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm bài hát',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon:
                    searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              currentPage = 1;
                            });
                            fetchTracks(isRefresh: true);
                          },
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 16),

            // Danh sách bài hát
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => fetchTracks(isRefresh: true),
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : tracks.isEmpty
                        ? const Center(child: Text('Không có bài hát nào'))
                        : ListView.builder(
                          itemCount: tracks.length,
                          itemBuilder: (context, index) {
                            final Track track = tracks[index];
                            return ListTile(
                              leading: Image.network(
                                '${Assets.IMAGE_URL}/${track.imageUrl}',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(Icons.image_not_supported),
                              ),
                              title: Tooltip(
                                message: track.title,
                                child: Text(
                                  track.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              subtitle: Tooltip(
                                message: track.artist,
                                child: Text(
                                  track.artist,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'play':
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => FullMusicPlayerScreen(
                                                track: track,
                                              ),
                                        ),
                                      );
                                      break;
                                    case 'update':
                                      showEditTrackDialog(track);
                                      break;
                                    case 'delete':
                                      showConfirmDialog(
                                        context: context,
                                        title: "Xoá bài hát",
                                        message:
                                            "Bạn có chắc chắn muốn xoá \"${track.title}\"?",
                                        confirmText: "Xoá",
                                        isDanger: true,
                                        onConfirm: () => deleteTrack(track.id),
                                      );
                                      break;
                                  }
                                },
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem<String>(
                                        value: 'play',
                                        child: ListTile(
                                          leading: Icon(Icons.play_arrow),
                                          title: Text('Nghe thử'),
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'update',
                                        child: ListTile(
                                          leading: Icon(Icons.edit),
                                          title: Text('Chỉnh sửa'),
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          title: Text('Xoá'),
                                        ),
                                      ),
                                    ],
                              ),
                            );
                          },
                        ),
              ),
            ),

            // Phân trang
            if (totalPages > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed:
                          currentPage > 1 && !isLoading
                              ? () {
                                setState(() {
                                  currentPage--;
                                });
                                fetchTracks();
                              }
                              : null,
                    ),
                    Text('Trang $currentPage / $totalPages'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed:
                          currentPage < totalPages && !isLoading
                              ? () {
                                setState(() {
                                  currentPage++;
                                });
                                fetchTracks();
                              }
                              : null,
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

Widget _buildField(
  String label,
  TextEditingController controller, {
  TextInputType keyboard = TextInputType.text,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboard,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    decoration: InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white, fontSize: 13),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );
}

// Widget tái sử dụng cho Picker
class _PickerCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
