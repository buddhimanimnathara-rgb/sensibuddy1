import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class VideoSearchService {

  // YOUTUBE API KEY


  final String _apiKey =
      dotenv.env['YOUTUBE_API_KEY'] ?? '';


  // SEARCH VIDEOS


  Future<List<Map<String, String>>> searchVideos({
    required String topic,
  }) async {
    try {

      // CHECK API KEY


      if (_apiKey.isEmpty) {
        throw Exception(
          'YOUTUBE_API_KEY not found in .env',
        );
      }


      // CREATE SEARCH QUERY


      final cleanTopic = topic.trim();

      if (cleanTopic.isEmpty) {
        return [];
      }

      final query = '$cleanTopic for kids';


      // CREATE YOUTUBE API URL


      final uri = Uri.https(
        'www.googleapis.com',
        '/youtube/v3/search',
        {
          'part': 'snippet',
          'type': 'video',
          'maxResults': '10',
          'q': query,
          'key': _apiKey,
        },
      );

      debugPrint(
        '🎬 SEARCHING YOUTUBE: $query',
      );

      // API REQUEST


      final response = await http.get(uri);


      // ERROR CHECK


      if (response.statusCode != 200) {
        debugPrint(
          ' YOUTUBE API ERROR: '
              '${response.statusCode}',
        );

        debugPrint(
          ' RESPONSE: ${response.body}',
        );

        throw Exception(
          'Video search failed: '
              '${response.statusCode}',
        );
      }


      // DECODE RESPONSE


      final Map<String, dynamic> data =
      jsonDecode(response.body);

      final List<dynamic> items =
          data['items'] as List<dynamic>? ?? [];


      // CONVERT RESULTS


      final videos = <Map<String, String>>[];

      for (final item in items) {
        try {
          final Map<String, dynamic>? snippet =
          item['snippet']
          as Map<String, dynamic>?;

          final Map<String, dynamic>? id =
          item['id']
          as Map<String, dynamic>?;

          if (snippet == null || id == null) {
            continue;
          }

          final String? videoId =
          id['videoId']?.toString();

          if (videoId == null ||
              videoId.isEmpty) {
            continue;
          }

          final Map<String, dynamic>? thumbnails =
          snippet['thumbnails']
          as Map<String, dynamic>?;

          String thumbnail = '';


          // GET BEST THUMBNAIL


          if (thumbnails != null) {
            if (thumbnails['high'] != null) {
              thumbnail =
                  thumbnails['high']['url']
                      ?.toString() ??
                      '';
            } else if (thumbnails['medium'] != null) {
              thumbnail =
                  thumbnails['medium']['url']
                      ?.toString() ??
                      '';
            } else if (thumbnails['default'] != null) {
              thumbnail =
                  thumbnails['default']['url']
                      ?.toString() ??
                      '';
            }
          }


          // ADD VIDEO


          videos.add(
            {
              'videoId': videoId,
              'title':
              snippet['title']
                  ?.toString() ??
                  'Kids Video',
              'description':
              snippet['description']
                  ?.toString() ??
                  '',
              'thumbnail': thumbnail,
            },
          );
        } catch (e) {
          debugPrint(
            ' SKIPPING INVALID VIDEO: $e',
          );
        }
      }

      debugPrint(
        ' VIDEOS FOUND: ${videos.length}',
      );

      return videos;
    } catch (e) {
      debugPrint(
        ' VIDEO SEARCH ERROR: $e',
      );

      rethrow;
    }
  }
}