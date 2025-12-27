class Video {
  final String title;
  final String url;
  final String duration;
  final String? thumbnailUrl;

  Video({
    required this.title,
    required this.url,
    required this.duration,
    this.thumbnailUrl,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      duration: json['duration'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}
