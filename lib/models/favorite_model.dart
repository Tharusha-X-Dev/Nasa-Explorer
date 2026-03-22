class FavoriteModel {
  final String title;
  final String description;
  final String imageUrl;
  final String mediaType;
  final String? mediaUrl;
  final String? date;
  final String? nasaId;
  final List<String> keywords;
  final String? localImagePath;

  const FavoriteModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.mediaType = 'image',
    this.mediaUrl,
    this.date,
    this.nasaId,
    this.keywords = const <String>[],
    this.localImagePath,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? '') as String,
      mediaType: (json['mediaType'] ?? 'image') as String,
      mediaUrl: json['mediaUrl'] as String?,
      date: json['date'] as String?,
      nasaId: json['nasaId'] as String?,
      keywords:
          (json['keywords'] as List<dynamic>?)?.cast<String>().toList() ??
          <String>[],
      localImagePath: json['localImagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'mediaType': mediaType,
      'mediaUrl': mediaUrl,
      'date': date,
      'nasaId': nasaId,
      'keywords': keywords,
      'localImagePath': localImagePath,
    };
  }
}
