import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class StreamingService {
  static const List<String> vidsrcDomains = [
    'vidsrc.xyz',
    'vidsrc.in',
    'vidsrc.pm',
    'vidsrc.net',
    'vidsrc.cc'
  ];

  static String buildStreamUrl({
    required int tmdbId,
    required String mediaType,
    String? imdbId,
    int? season,
    int? episode,
  }) {
    final domain = vidsrcDomains[0];

    if (mediaType == 'movie') {
      return 'https://$domain/embed/movie?tmdb=$tmdbId';
    } else if (mediaType == 'tv' && season != null && episode != null) {
      return 'https://$domain/embed/tv?tmdb=$tmdbId&season=$season&episode=$episode';
    }

    throw ArgumentError('Invalid parameters for streaming URL');
  }

  static String buildAlternativeUrl({
    required int tmdbId,
    required String mediaType,
    int? season,
    int? episode,
  }) {
    // URLs alternatives
    const alternatives = [
      'https://multiembed.mov',
      'https://www.2embed.cc',
      'https://embed.warezcdn.net'
    ];

    final domain = alternatives[0];

    if (mediaType == 'movie') {
      return '$domain/embed/tmdb/movie?id=$tmdbId';
    } else if (mediaType == 'tv' && season != null && episode != null) {
      return '$domain/embed/tmdb/tv?id=$tmdbId&s=$season&e=$episode';
    }

    throw ArgumentError('Invalid parameters for alternative URL');
  }

  static Future<bool> canLaunchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }
}
