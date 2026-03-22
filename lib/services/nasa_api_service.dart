import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/apod_model.dart';
import 'network_service.dart';

class NasaApiService {
  final NetworkService _networkService = NetworkService();

  static const String _apodUrl =
      'https://api.nasa.gov/planetary/apod?api_key=bk9mMayFLVhh8e1S2LSVL9BJmuIVuqEVWkP1LUr9&thumbs=true';

  Future<ApodModel> fetchApod() async {
    final bool connected = await _networkService.isConnected();
    if (!connected) {
      throw Exception('No internet connection');
    }

    final Uri uri = Uri.parse(_apodUrl);
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap =
          json.decode(response.body) as Map<String, dynamic>;
      return ApodModel.fromJson(jsonMap);
    }
    throw Exception('Unable to load data from NASA.');
  }
}
