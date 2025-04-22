class Track {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? genre;
  final int duration;
  final String? fileUrl;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.genre,
    required this.duration,
    this.fileUrl,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      genre: json['genre'],
      duration: json['duration'],
      fileUrl: json['fileUrl'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'genre': genre,
      'duration': duration,
      'fileUrl': fileUrl,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
