class ApodModel {
  final String title;
  final String explanation;
  final String date;
  final String url;
  final String? hdUrl;
  final String mediaType;
  final String? copyright;
  final String? thumbnailUrl;

  const ApodModel({
    required this.title,
    required this.explanation,
    required this.date,
    required this.url,
    this.hdUrl,
    required this.mediaType,
    this.copyright,
    this.thumbnailUrl,
  });

  factory ApodModel.fromJson(Map<String, dynamic> json) {
    return ApodModel(
      title: (json['title'] ?? '') as String,
      explanation: (json['explanation'] ?? '') as String,
      date: (json['date'] ?? '') as String,
      url: (json['url'] ?? '') as String,
      hdUrl: json['hdurl'] as String?,
      mediaType: (json['media_type'] ?? '') as String,
      copyright: json['copyright'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }
}
