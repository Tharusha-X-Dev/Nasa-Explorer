import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:version_1_0/features/explore/models/nasa_image_model.dart';
import 'package:version_1_0/core/services/network_service.dart';
import 'package:version_1_0/core/utils/network_error_utils.dart';

class NasaImageService {
  final NetworkService _networkService = NetworkService();

  Future<List<NasaImageModel>> searchMedia({
    required String query,
    required int page,
    int limit = 6,
  }) async {
    final bool connected = await _networkService.isConnected();
    if (!connected) {
      throw Exception(NetworkErrorUtils.noInternetMessage);
    }

    final Uri uri = Uri.https(
      'images-api.nasa.gov',
      '/search',
      <String, String>{'q': query, 'page': page.toString()},
    );

    final http.Response response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Unable to load data from NASA.');
    }

    final Map<String, dynamic> jsonMap =
        json.decode(response.body) as Map<String, dynamic>;

    final Map<String, dynamic> collection =
        jsonMap['collection'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final List<dynamic> items =
        collection['items'] as List<dynamic>? ?? <dynamic>[];

    final List<NasaImageModel> imageList = items
        .map(
          (dynamic item) =>
              NasaImageModel.fromJson(item as Map<String, dynamic>),
        )
        .where(
          (NasaImageModel item) =>
              (item.mediaType == 'image' || item.mediaType == 'video') &&
              item.imageUrl.isNotEmpty,
        )
        .take(limit)
        .toList();

    return imageList;
  }

  Future<List<NasaImageModel>> fetchImages({
    required String topic,
    required int page,
    int limit = 6,
  }) async {
    final List<NasaImageModel> items = await searchMedia(
      query: topic,
      page: page,
      limit: limit * 3,
    );

    return items
        .where((NasaImageModel item) => item.mediaType == 'image')
        .take(limit)
        .toList();
  }

  Future<String?> getPlayableVideoUrl(String collectionUrl) async {
    final bool connected = await _networkService.isConnected();
    if (!connected) {
      return null;
    }

    final Uri? uri = Uri.tryParse(collectionUrl);
    if (uri == null) {
      return null;
    }

    final http.Response response = await http.get(uri);
    if (response.statusCode != 200) {
      return null;
    }

    final dynamic decoded = json.decode(response.body);
    if (decoded is! List<dynamic>) {
      return null;
    }

    final List<String> urls = decoded.whereType<String>().toList();

    for (final String url in urls) {
      if (url.contains('~medium.mp4')) {
        return url;
      }
    }

    for (final String url in urls) {
      if (url.contains('~large.mp4')) {
        return url;
      }
    }

    for (final String url in urls) {
      if (url.contains('~orig.mp4')) {
        return url;
      }
    }

    return null;
  }
}
