import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
  File? selectedMusicFile;
  String? musicFileName;
  File? selectedImageFile;
  String? imageFileName;

  // 🆕 Các controller cho metadata

  final TextEditingController titleController = TextEditingController();
  final TextEditingController artistController = TextEditingController();
  final TextEditingController albumController = TextEditingController();
  final TextEditingController genreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTracks();
  }

  Future<void> fetchTracks() async {
    final response = await http.get(Uri.parse('${Assets.API_URL}/track'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        tracks = data.map((e) => Track.fromJson(e)).toList();
      });
    } else {
      print("❌ Failed to load tracks");
    }
  }

  Future<void> pickMusicFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedMusicFile = File(result.files.single.path!);
        musicFileName = result.files.single.name;
      });
    }
  }

  Future<void> deleteTrack(String trackId) async {
    final response = await http.delete(
      Uri.parse('${Assets.API_URL}/track/$trackId'),
    );

    if (response.statusCode == 200) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('🗑️ Xoá thành công')));
      }
      fetchTracks();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Xoá thất bại: ${response.body}')),
        );
      }
    }
  }

  Future<void> pickImageFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedImageFile = File(result.files.single.path!);
        imageFileName = result.files.single.name;
      });
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
                        Navigator.of(parentContext).pop(); // đóng dialog edit

                        // Mở loading
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

                          // metadata
                          req.fields['title'] = editTitle.text;
                          req.fields['artist'] = editArtist.text;
                          req.fields['album'] = editAlbum.text;
                          req.fields['genre'] = editGenre.text;

                          // nếu newMusicFile khác null thì gán
                          final musicFile = newMusicFile;
                          if (musicFile != null) {
                            final part = await http.MultipartFile.fromPath(
                              'audio',
                              musicFile.path,
                            );
                            req.files.add(part);
                          }

                          // tương tự với image
                          final imageFileLocal = newImageFile;
                          if (imageFileLocal != null) {
                            final partImg = await http.MultipartFile.fromPath(
                              'image',
                              imageFileLocal.path,
                            );
                            req.files.add(partImg);
                          }

                          final streamed = await req.send();
                          final body = await streamed.stream.bytesToString();
                          Navigator.of(parentContext).pop(); // đóng loading

                          if (streamed.statusCode == 200) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Cập nhật thành công'),
                              ),
                            );
                            fetchTracks();
                          } else {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(content: Text('❌ Lỗi: $body')),
                            );
                          }
                        } catch (e, st) {
                          Navigator.of(parentContext).pop(); // đóng loading
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

  Future<void> uploadMusicFile() async {
    if (selectedMusicFile == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Vui lòng chọn file nhạc!')),
        );
      }
      return;
    }

    if (selectedImageFile == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Vui lòng chọn file ảnh bìa!')),
        );
      }
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Assets.API_URL}/track/upload'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('audio', selectedMusicFile!.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('image', selectedImageFile!.path),
      );

      // Thêm metadata vào yêu cầu
      request.fields['title'] = titleController.text;
      request.fields['artist'] = artistController.text;
      request.fields['album'] = albumController.text;
      request.fields['genre'] = genreController.text;

      var response = await request.send();
      Navigator.of(context).pop();

      if (response.statusCode == 201) {
        setState(() {
          selectedMusicFile = null;
          musicFileName = null;
          selectedImageFile = null;
          imageFileName = null;

          titleController.clear();
          artistController.clear();
          albumController.clear();
          genreController.clear();
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Upload thành công!')),
          );
        }

        fetchTracks();
      } else {
        final responseBody = await response.stream.bytesToString();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Upload thất bại! $responseBody')),
          );
        }
      }
    } catch (e) {
      Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('⚠️ Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Quản lý nhạc"),
            MaterialButton(
              child: Icon(Icons.refresh),
              onPressed: () {
                fetchTracks();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👉 Bọc phần đầu bằng scroll view để tránh tràn
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎵 Upload Bài Hát',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _PickerCard(
                              icon: Icons.upload_file,
                              label: musicFileName ?? 'Nhạc',
                              onTap: pickMusicFile,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PickerCard(
                              icon: Icons.image,
                              label: imageFileName ?? 'Ảnh',
                              onTap: pickImageFile,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildField('Tiêu đề', titleController),
                      const SizedBox(height: 12),
                      _buildField('Ca sĩ', artistController),
                      const SizedBox(height: 12),
                      _buildField('Album', albumController),
                      const SizedBox(height: 12),
                      _buildField('Thể loại', genreController),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.send,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Gửi",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: uploadMusicFile,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
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
                          (_, __, ___) => const Icon(Icons.image_not_supported),
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
                                    (_) => FullMusicPlayerScreen(track: track),
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
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Xoá'),
                              ),
                            ),
                          ],
                    ),
                  );
                },
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
      labelStyle: TextStyle(color: Colors.white70, fontSize: 13),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );
}

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
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
