import 'package:flutter/material.dart';

class AssessmentCard extends StatelessWidget {
  final String supportLevel;
  final int score;
  final VoidCallback? onTap;

  const AssessmentCard({
    super.key,
    required this.supportLevel,
    required this.score,
    this.onTap,
  });

  Color getLevelColor() {
    final level = supportLevel.toLowerCase();

    if (level.contains('low')) {
      return const Color(0xFF4CAF50);
    }

    if (level.contains('mild')) {
      return const Color(0xFFFFA726);
    }

    if (level.contains('moderate')) {
      return const Color(0xFFFF7043);
    }

    if (level.contains('high')) {
      return const Color(0xFFEF5350);
    }

    return const Color(0xFF7C4DFF);
  }

  IconData getLevelIcon() {
    final level = supportLevel.toLowerCase();

    if (level.contains('low')) {
      return Icons.sentiment_satisfied_alt_rounded;
    }

    if (level.contains('mild')) {
      return Icons.info_outline_rounded;
    }

    if (level.contains('moderate')) {
      return Icons.support_agent_rounded;
    }

    if (level.contains('high')) {
      return Icons.favorite_rounded;
    }

    return Icons.assessment_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = getLevelColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -45,
                right: -35,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.08),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        getLevelIcon(),
                        color: color,
                        size: 36,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Assessment Result",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8E8E93),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 7),

                          Text(
                            supportLevel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF252525),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.10),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Support Level",
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Column(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.10),
                            border: Border.all(
                              color: color.withOpacity(0.25),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$score",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                    FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                const Text(
                                  "/20",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF8E8E93),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: color,
                          size: 17,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}