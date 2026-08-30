import 'package:flutter/material.dart';

import '../../core/services/firestore_service.dart';
import '../parent_dashboard/parent_dashboard_screen.dart';

class AssessmentResultsScreen extends StatelessWidget {
  final String childId;
  final String guardianId;

  const AssessmentResultsScreen({
    super.key,
    required this.childId,
    required this.guardianId,
  });

  Color _getSupportColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return Colors.green;

      case 'mild':
        return Colors.orange;

      case 'moderate':
        return Colors.deepOrange;

      case 'high':
        return Colors.red;

      default:
        return Colors.deepPurple;
    }
  }

  IconData _getSupportIcon(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return Icons.sentiment_very_satisfied_rounded;

      case 'mild':
        return Icons.info_outline_rounded;

      case 'moderate':
        return Icons.priority_high_rounded;

      case 'high':
        return Icons.health_and_safety_rounded;

      default:
        return Icons.assessment_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1D1B20),
        centerTitle: true,
        title: const Text(
          "Assessment Results",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>?>(
        future: firestoreService.getLatestAssessment(childId),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                "No Assessment Found",
              ),
            );
          }

          final assessment = snapshot.data!;

          final supportLevel =
              assessment["supportLevel"] ?? "Unknown";

          final score = assessment["score"] ?? 0;

          final supportColor =
          _getSupportColor(supportLevel);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),

            children: [
              Container(
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      supportColor.withOpacity(0.80),
                      supportColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(28),

                  boxShadow: [
                    BoxShadow(
                      color:
                      supportColor.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    Container(
                      width: 75,
                      height: 75,

                      decoration: BoxDecoration(
                        color:
                        Colors.white.withOpacity(0.20),

                        shape: BoxShape.circle,
                      ),

                      child: Icon(
                        _getSupportIcon(
                          supportLevel,
                        ),

                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Assessment Result",

                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "$supportLevel Support",

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Total Score: $score / 20",

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Assessment Areas",

                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              _buildScoreCard(
                title: "Social Interaction",
                subtitle:
                "Social communication and interaction",
                icon: Icons.people_rounded,
                score:
                assessment["socialScore"] ?? 0,
                color: Colors.blue,
              ),

              const SizedBox(height: 12),

              _buildScoreCard(
                title: "Communication",
                subtitle:
                "Communication and expression skills",
                icon: Icons.chat_bubble_rounded,
                score:
                assessment["communicationScore"] ?? 0,
                color: Colors.purple,
              ),

              const SizedBox(height: 12),

              _buildScoreCard(
                title: "Restricted & Routine Behaviors",
                subtitle:
                "Routine preferences and restricted behaviors",
                icon: Icons.schedule_rounded,
                score:
                assessment[
                "restrictedRoutineScore"] ??
                    0,
                color: Colors.orange,
              ),

              const SizedBox(height: 12),

              _buildScoreCard(
                title: "Repetitive Behaviors",
                subtitle:
                "Repeated movements or behaviors",
                icon: Icons.repeat_rounded,
                score:
                assessment["repetitiveScore"] ?? 0,
                color: Colors.redAccent,
              ),

              const SizedBox(height: 12),

              _buildScoreCard(
                title: "Sensory Differences",
                subtitle:
                "Responses to sensory experiences",
                icon: Icons.hearing_rounded,
                score:
                assessment["sensoryScore"] ?? 0,
                color: Colors.teal,
              ),

              const SizedBox(height: 24),

              _buildSectionCard(
                icon: Icons.summarize_rounded,
                title: "Assessment Summary",

                child: Text(
                  assessment["summary"] ??
                      "No summary available.",

                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF55515C),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _buildSectionCard(
                icon:
                Icons.calendar_month_rounded,
                title: "Assessment Date",

                child: Text(
                  assessment["createdAt"] ??
                      "Unknown",

                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF55515C),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _buildSectionCard(
                icon: Icons.lightbulb_rounded,
                title: "General Recommendations",

                child: const Text(
                  "• Encourage communication and self-expression.\n\n"
                      "• Support positive social interaction.\n\n"
                      "• Maintain predictable routines when helpful.\n\n"
                      "• Observe sensory preferences and responses.\n\n"
                      "• Practice emotional expression and regulation.\n\n"
                      "• Use professional guidance when appropriate.",

                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF55515C),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF6C63FF),

                    foregroundColor: Colors.white,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                  ),

                  onPressed: () {
                    Navigator.pushReplacement(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            ParentDashboardScreen(
                              childId: childId,
                              guardianId: guardianId,
                            ),
                      ),
                    );
                  },

                  child: const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children: [
                      Text(
                        "Continue to Dashboard",

                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      SizedBox(width: 10),

                      Icon(
                        Icons.arrow_forward_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScoreCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required int score,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: color.withOpacity(0.12),

              borderRadius:
              BorderRadius.circular(16),
            ),

            child: Icon(
              icon,
              color: color,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,

                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 8,
            ),

            decoration: BoxDecoration(
              color: color.withOpacity(0.12),

              borderRadius:
              BorderRadius.circular(14),
            ),

            child: Text(
              "$score / 4",

              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,

                decoration: BoxDecoration(
                  color: const Color(
                    0xFF6C63FF,
                  ).withOpacity(0.10),

                  borderRadius:
                  BorderRadius.circular(13),
                ),

                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF6C63FF),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }
}