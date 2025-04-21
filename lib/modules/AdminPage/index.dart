import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:working_message_mobile/constants/list.dart';

class AdminMusicPage extends StatefulWidget {
  const AdminMusicPage({super.key});

  @override
  State<AdminMusicPage> createState() => _AdminMusicPageState();
}

class _AdminMusicPageState extends State<AdminMusicPage> {
  List<dynamic> tracks = [];
  File? selectedFile;
  String? fileName;

  // 🆕 Các controller cho metadata
  final TextEditingController titleController = TextEditingController();
  final TextEditingController artistController = TextEditingController();
  final TextEditingController albumController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTracks();
  }

  Future<void> fetchTracks() async {
    final response = await http.get(Uri.parse('${Assets.API_URL}/track'));
    if (response.statusCode == 200) {
      setState(() {
        tracks = jsonDecode(response.body);
      });
    } else {
      print("❌ Failed to load tracks");
    }
  }

  Future<void> pickMusicFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        fileName = result.files.single.name;
      });
    }
  }

  Future<void> uploadMusicFile() async {
    if (selectedFile == null) return;

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
        await http.MultipartFile.fromPath('file', selectedFile!.path),
      );

      request.fields['title'] = titleController.text;
      request.fields['artist'] = artistController.text;
      request.fields['album'] = albumController.text;
      request.fields['genre'] = genreController.text;
      request.fields['duration'] = durationController.text;

      var response = await request.send();
      Navigator.of(context).pop();

      if (response.statusCode == 201) {
        setState(() {
          selectedFile = null;
          fileName = null;

          titleController.clear();
          artistController.clear();
          albumController.clear();
          genreController.clear();
          durationController.clear();
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Upload thành công!')),
          );
        }

        fetchTracks();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('❌ Upload thất bại!')));
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
      appBar: AppBar(title: const Text("Quản lý nhạc")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👉 Bọc phần đầu bằng scroll view để tránh tràn
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Chọn file nhạc"),
                      onPressed: pickMusicFile,
                    ),
                    const SizedBox(height: 8),
                    if (fileName != null) ...[
                      Text('📁 Đã chọn: $fileName'),
                      const SizedBox(height: 16),

                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: '🎵 Tiêu đề',
                        ),
                      ),
                      TextField(
                        controller: artistController,
                        decoration: const InputDecoration(
                          labelText: '👤 Ca sĩ',
                        ),
                      ),
                      TextField(
                        controller: albumController,
                        decoration: const InputDecoration(
                          labelText: '💿 Album',
                        ),
                      ),
                      TextField(
                        controller: genreController,
                        decoration: const InputDecoration(
                          labelText: '🎶 Thể loại',
                        ),
                      ),
                      TextField(
                        controller: durationController,
                        decoration: const InputDecoration(
                          labelText: '⏱️ Thời lượng (giây)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text("🎵 Xác nhận gửi lên server"),
                        onPressed: uploadMusicFile,
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Divider(),
                    const Text(
                      "Nhạc đã tải lên:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            // 👉 Phần danh sách nhạc vẫn được scroll riêng
            Flexible(
              child: ListView.builder(
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  return ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(track['title'] ?? 'Không có tiêu đề'),
                    subtitle: Text(track['artist'] ?? ''),
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
