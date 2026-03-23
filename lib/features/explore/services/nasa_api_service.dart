import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:version_1_0/features/explore/models/apod_model.dart';
import 'package:version_1_0/core/services/network_service.dart';
import 'package:version_1_0/core/utils/network_error_utils.dart';

class NasaApiService {
  final NetworkService _networkService = NetworkService();

  Future<ApodModel> fetchApod() async {
    final bool connected = await _networkService.isConnected();
    if (!connected) {
      throw Exception(NetworkErrorUtils.noInternetMessage);
    }

    final String apiKey = dotenv.env['NASA_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('NASA API key is missing.');
    }

    final Uri uri = Uri.https(
      'api.nasa.gov',
      '/planetary/apod',
      <String, String>{'api_key': apiKey, 'thumbs': 'true'},
    );
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap =
          json.decode(response.body) as Map<String, dynamic>;
      return ApodModel.fromJson(jsonMap);
    }
    throw Exception('Unable to load data from NASA.');
  }
}
