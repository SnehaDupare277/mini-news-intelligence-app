import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsApiException implements Exception {
  const NewsApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class NewsApi {
  NewsApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static const _baseUrl = 'https://newsapi.org/v2';
  static const _apiKey = String.fromEnvironment('NEWS_API_KEY');

  Future<List<Article>> topHeadlines({String category = 'general', int page = 1}) async {
    if (_apiKey.isEmpty) {
      throw const NewsApiException('Add your NewsAPI key using --dart-define=NEWS_API_KEY=YOUR_KEY.');
    }
    final uri = Uri.parse('$_baseUrl/top-headlines').replace(queryParameters: {
      'country': 'us', 'category': category, 'page': '$page', 'pageSize': '20',
      'apiKey': _apiKey,
    });
    return _getArticles(uri);
  }

  Future<List<Article>> search(String query, {int page = 1}) async {
    if (_apiKey.isEmpty) {
      throw const NewsApiException('Add your NewsAPI key using --dart-define=NEWS_API_KEY=YOUR_KEY.');
    }
    final uri = Uri.parse('$_baseUrl/everything').replace(queryParameters: {
      'q': query, 'sortBy': 'publishedAt', 'page': '$page', 'pageSize': '20',
      'language': 'en', 'apiKey': _apiKey,
    });
    return _getArticles(uri);
  }

  Future<List<Article>> _getArticles(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 15));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200 || body['status'] != 'ok') {
        throw NewsApiException(body['message'] as String? ?? 'News service returned an error.');
      }
      final rows = body['articles'] as List<dynamic>? ?? [];
      return rows.whereType<Map<String, dynamic>>()
          .map(Article.fromJson)
          .where((a) => a.title != '[Removed]' && a.url.isNotEmpty)
          .toList();
    } on NewsApiException {
      rethrow;
    } catch (_) {
      throw const NewsApiException('Could not load stories. Check your connection and try again.');
    }
  }
}
