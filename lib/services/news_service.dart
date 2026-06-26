import 'dart:async';
import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:pina/models/news_article.dart';
import 'package:pina/screens/constants.dart';

// Lightweight wrapper around News API - routes through backend for security
class Apiservice {
  String get _newsUrl => "${ApiConstants.authUrl}/api/news";

  // Fetches the latest feed and maps it into strongly typed models.
  Future<List<NewsArticle>> fetchNews() async {
    final response = await http
        .get(Uri.parse(_newsUrl))
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw TimeoutException("News API timed out. Please retry.");
          },
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["results"] == null) return [];
      List articles = data["results"];

      return articles.map((e) => NewsArticle.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch news: ${response.statusCode}");
    }
  }
}
