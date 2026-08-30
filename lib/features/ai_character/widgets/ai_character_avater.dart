import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class AICharacterAvatar extends StatefulWidget {
  final String characterId;
  final String emotion;
  final bool isSpeaking;

  const AICharacterAvatar({
    super.key,
    required this.characterId,
    required this.emotion,
    required this.isSpeaking,
  });

  @override
  State<AICharacterAvatar> createState() =>
      _AICharacterAvatarState();
}

class _AICharacterAvatarState
    extends State<AICharacterAvatar>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _mouthController;
  late AnimationController _headController;
  late AnimationController _breathingController;

  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _mouthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _headController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _startBlinking();

    if (widget.isSpeaking) {
      _mouthController.repeat(reverse: true);
    }
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(
      const Duration(seconds: 3),
          (_) async {
        if (!mounted) return;

        await _blinkController.forward();

        if (!mounted) return;

        await _blinkController.reverse();
      },
    );
  }

  @override
  void didUpdateWidget(
      covariant AICharacterAvatar oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSpeaking && !oldWidget.isSpeaking) {
      _mouthController.repeat(reverse: true);
    }

    if (!widget.isSpeaking && oldWidget.isSpeaking) {
      _mouthController.stop();

      _mouthController.value = 0;
    }
  }

  String _getCharacterImage() {
    switch (widget.characterId.toLowerCase()) {
      case 'girl':
        return 'assets/images/characters/girl.png';

      case 'bunny':
        return 'assets/images/characters/bunny.png';

      case 'teddy':
        return 'assets/images/characters/teddy.png';

      case 'robot':
      default:
        return 'assets/images/characters/robot.png';
    }
  }

  Color _getEmotionColor() {
    switch (widget.emotion.toLowerCase()) {
      case 'happy':
      case 'joy':
        return Colors.orange;

      case 'sad':
      case 'sadness':
        return Colors.blue;

      case 'angry':
        return Colors.deepOrange;

      case 'fear':
        return Colors.deepPurple;

      case 'surprise':
        return Colors.pink;

      case 'neutral':
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final emotionColor = _getEmotionColor();

    return AnimatedBuilder(
      animation: Listenable.merge([
        _headController,
        _breathingController,
        _mouthController,
      ]),
      builder: (context, child) {
        final headMove =
            (_headController.value - 0.5) * 10;

        final breathingScale =
            1.0 +
                (_breathingController.value * 0.02);

        final speakingScale = widget.isSpeaking
            ? 1.02 +
            (_mouthController.value * 0.025)
            : 1.0;

        final totalScale =
            breathingScale * speakingScale;

        final rotation =
            math.sin(
              _headController.value * math.pi,
            ) *
                0.025;

        return Transform.translate(
          offset: Offset(
            headMove,
            widget.isSpeaking ? -2 : 0,
          ),
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: totalScale,
              child: child,
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(
              milliseconds: 500,
            ),
            width: 255,
            height: 255,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: emotionColor.withOpacity(0.10),
              boxShadow: [
                BoxShadow(
                  color: emotionColor.withOpacity(0.25),
                  blurRadius: 35,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),

          SizedBox(
            width: 235,
            height: 235,
            child: Image.asset(
              _getCharacterImage(),
              fit: BoxFit.contain,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return const Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_rounded,
                      size: 65,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Character image not found',
                    ),
                  ],
                );
              },
            ),
          ),

          AnimatedBuilder(
            animation: _blinkController,
            builder: (context, child) {
              final blinkValue =
                  _blinkController.value;

              if (blinkValue <= 0.05) {
                return const SizedBox.shrink();
              }

              return Positioned(
                top: 88,
                child: Opacity(
                  opacity: blinkValue,
                  child: Container(
                    width: 72,
                    height: 4 +
                        (blinkValue * 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(
                        0.55,
                      ),
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                  ),
                ),
              );
            },
          ),

          if (widget.isSpeaking)
            AnimatedBuilder(
              animation: _mouthController,
              builder: (context, child) {
                final mouthOpen =
                    6 +
                        (_mouthController.value * 10);

                return Positioned(
                  bottom: 28,
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 80,
                    ),
                    width: 26 +
                        (_mouthController.value * 10),
                    height: mouthOpen,
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(
                        0.75,
                      ),
                      borderRadius:
                      BorderRadius.circular(30),
                    ),
                  ),
                );
              },
            ),

          if (widget.isSpeaking)
            Positioned(
              bottom: -12,
              child: _SpeakingDots(
                controller: _mouthController,
                color: emotionColor,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();

    _blinkController.dispose();
    _mouthController.dispose();
    _headController.dispose();
    _breathingController.dispose();

    super.dispose();
  }
}

class _SpeakingDots extends StatelessWidget {
  final AnimationController controller;
  final Color color;

  const _SpeakingDots({
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          children: List.generate(
            3,
                (index) {
              final phase =
                  (controller.value + index * 0.25) % 1;

              final size =
                  5 + (math.sin(phase * math.pi) * 3);

              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 2,
                ),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
        );
      },
    );
  }
}