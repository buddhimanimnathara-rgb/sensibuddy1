import 'package:flutter/material.dart';

import '../core/services/video_search_service.dart';
import 'kids_video_player_screen.dart';

class KidsTubeScreen extends StatefulWidget {
  final String childId;
  final String topic;

  const KidsTubeScreen({
    super.key,
    required this.childId,
    required this.topic,
  });

  @override
  State<KidsTubeScreen> createState() => _KidsTubeScreenState();
}

class _KidsTubeScreenState extends State<KidsTubeScreen> {
  late final VideoSearchService _videoSearchService;

  List<Map<String, String>> _videos = [];

  bool _isLoading = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();


    // INITIALIZE VIDEO SEARCH SERVICE
    // API KEY IS LOADED FROM .env

    _videoSearchService = VideoSearchService();


    // LOAD VIDEOS

    _loadVideos();
  }

  // LOAD VIDEOS

  Future<void> _loadVideos() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint(
        ' SEARCHING VIDEOS FOR: ${widget.topic}',
      );

      final videos =
      await _videoSearchService.searchVideos(
        topic: widget.topic,
      );

      if (!mounted) return;

      setState(() {
        _videos = videos;
        _isLoading = false;
      });

      debugPrint(
        ' VIDEOS FOUND: ${videos.length}',
      );
    } catch (e) {
      debugPrint(
        ' VIDEO SEARCH ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load videos.';
      });
    }
  }


  // OPEN VIDEO


  Future<void> _openVideo(
      Map<String, String> video,
      ) async {
    final videoId = video['videoId'];

    if (videoId == null || videoId.isEmpty) {
      debugPrint(
        ' VIDEO ID NOT FOUND',
      );

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KidsVideoPlayerScreen(
          videoId: videoId,
          title: video['title'] ?? 'Kids Video',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KidsTube',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadVideos,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // TOPIC HEADER

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  const Icon(
                    Icons.play_circle_fill,
                    size: 60,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Videos for you',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    widget.topic,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // LOADING

            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )


            // ERROR


            else if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 70,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        _errorMessage!,
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: _loadVideos,
                        child: const Text(
                          'Try Again',
                        ),
                      ),
                    ],
                  ),
                ),
              )


            // NO VIDEOS


            else if (_videos.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No videos found.',
                    ),
                  ),
                )


              // VIDEO LIST

              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _videos.length,

                    itemBuilder: (
                        context,
                        index,
                        ) {
                      final video = _videos[index];

                      final thumbnail =
                          video['thumbnail'] ?? '';

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 16,
                        ),

                        clipBehavior: Clip.antiAlias,

                        child: InkWell(
                          onTap: () => _openVideo(video),

                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [
                              // VIDEO THUMBNAIL


                              if (thumbnail.isNotEmpty)
                                AspectRatio(
                                  aspectRatio: 16 / 9,

                                  child: Image.network(
                                    thumbnail,
                                    fit: BoxFit.cover,

                                    errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                        ) {
                                      return const Center(
                                        child: Icon(
                                          Icons.video_library,
                                          size: 60,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              else
                                const AspectRatio(
                                  aspectRatio: 16 / 9,

                                  child: Center(
                                    child: Icon(
                                      Icons.video_library,
                                      size: 60,
                                    ),
                                  ),
                                ),

                              // VIDEO INFORMATION


                              Padding(
                                padding:
                                const EdgeInsets.all(12),

                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      video['title'] ??
                                          'Kids Video',

                                      maxLines: 2,

                                      overflow:
                                      TextOverflow.ellipsis,

                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      video['description'] ?? '',

                                      maxLines: 2,

                                      overflow:
                                      TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}