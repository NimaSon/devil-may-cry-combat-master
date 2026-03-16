import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsArticle {
  final String title;
  final String description;
  final String source;
  final String url;
  final String publishedAt;
  final String? urlToImage;

  NewsArticle({
    required this.title,
    required this.description,
    required this.source,
    required this.url,
    required this.publishedAt,
    this.urlToImage,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? 'Нет описания',
      source: json['source']?['name'] ?? '',
      url: json['url'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      urlToImage: json['urlToImage'],
    );
  }

  String get timeAgo {
    try {
      final dt = DateTime.parse(publishedAt).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} мин. назад';
      if (diff.inHours < 24) return '${diff.inHours} ч. назад';
      return '${diff.inDays} д. назад';
    } catch (_) {
      return '';
    }
  }
}

class NewsService {
  static const _apiKey = '9b1a0df9542f4868b9863b57659f4ec9';
  static const _baseUrl = 'https://newsapi.org/v2/everything';

  static Future<List<NewsArticle>> fetchEconomyNews({String query = 'economy finance currency oil gold'}) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final uri = Uri.parse(
        '$_baseUrl?q=$encodedQuery&language=en&sortBy=publishedAt&pageSize=30&apiKey=$_apiKey',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List;
        return articles
            .where((a) => a['title'] != null && a['title'] != '[Removed]')
            .map((a) => NewsArticle.fromJson(a))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
