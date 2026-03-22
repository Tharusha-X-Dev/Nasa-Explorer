class NasaImageModel {
  final String title;
  final String description;
  final String dateCreated;
  final String nasaId;
  final String center;
  final String photographer;
  final List<String> keywords;
  final String mediaType;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? mediaUrl;

  const NasaImageModel({
    required this.title,
    required this.description,
    required this.dateCreated,
    required this.nasaId,
    required this.center,
    required this.photographer,
    required this.keywords,
    required this.mediaType,
    required this.imageUrl,
    this.thumbnailUrl,
    this.mediaUrl,
  });

  factory NasaImageModel.fromJson(Map<String, dynamic> itemJson) {
    final List<dynamic> dataList =
        itemJson['data'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> linksList =
        itemJson['links'] as List<dynamic>? ?? <dynamic>[];

    final Map<String, dynamic> firstData = dataList.isNotEmpty
        ? dataList.first as Map<String, dynamic>
        : <String, dynamic>{};

    final String mediaType = (firstData['media_type'] ?? '') as String;

    String displayUrl = '';
    String? thumbnailUrl;
    for (final dynamic link in linksList) {
      final Map<String, dynamic> linkMap = link as Map<String, dynamic>;
      final String? render = linkMap['render'] as String?;
      final String? href = linkMap['href'] as String?;

      if (href == null || href.isEmpty) {
        continue;
      }

      if (render == 'image') {
        displayUrl = href;
        thumbnailUrl ??= href;
        break;
      }

      thumbnailUrl ??= href;
      if (displayUrl.isEmpty) {
        displayUrl = href;
      }
    }

    return NasaImageModel(
      title: (firstData['title'] ?? 'NASA Image') as String,
      description: (firstData['description'] ?? '') as String,
      dateCreated: (firstData['date_created'] ?? '') as String,
      nasaId: (firstData['nasa_id'] ?? '') as String,
      center: (firstData['center'] ?? '') as String,
      photographer: (firstData['photographer'] ?? '') as String,
      keywords: ((firstData['keywords'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic item) => item.toString())
          .toList(),
      mediaType: mediaType,
      imageUrl: displayUrl,
      thumbnailUrl: thumbnailUrl,
      mediaUrl: itemJson['href'] as String?,
    );
  }
}
