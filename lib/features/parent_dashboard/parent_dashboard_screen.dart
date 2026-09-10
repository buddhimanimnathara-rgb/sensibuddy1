import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/models/child_model.dart';
import '../../core/models/guardian_model.dart';

import '../../core/services/activity_service.dart';
import '../../core/services/emosion_history_service.dart';
import '../../core/services/pdf_service.dart';
import '../../core/services/firestore_service.dart';


import '../assessment_results/assessment_results_screen.dart';
import '../child_profile/child_face_registraion.dart';
import '../child_profile/child_profile_screen.dart';
import '../guardian_profile/guardian_profile_screen.dart';
import '../settings/settings_screen.dart';
import '../welcome/welcome_screen.dart';

import 'widgets/dashboard_header.dart';

class ParentDashboardScreen extends StatelessWidget {
  final String childId;
  final String guardianId;

  const ParentDashboardScreen({
    super.key,
    required this.childId,
    required this.guardianId,
  });

  @override
  Widget build(BuildContext context) {
    final activityService = ActivityService();

    final EmotionHistoryService emotionHistoryService =
    EmotionHistoryService();


    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),

      appBar: AppBar(
        title: const Text("Parent Dashboard"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          firestoreService.getChild(childId),
          firestoreService.getGuardian(guardianId),
          activityService.getActivities(childId),
          firestoreService.getAIInteractionAnalysis(childId),
          emotionHistoryService.getEmotionHistory(
            childId: childId,
          ),
        ]),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Failed to load dashboard\n\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data == null) {
            return const Center(
              child: Text("Child not found"),
            );
          }



          final data = snapshot.data!;

          final child = data[0] as ChildModel?;
          final guardian = data[1] as GuardianModel?;

          final activities =
          data[2] as List<Map<String, dynamic>>;

          final aiInteractions =
          data[3] as List<Map<String, dynamic>>;

          final emotionLogs =
          data[4] as List<Map<String, dynamic>>;



          if (child == null) {
            return const Center(
              child: Text("Child not found"),
            );
          }

          if (guardian == null) {
            return const Center(
              child: Text("Guardian not found"),
            );
          }

          // NEW GAME ANALYTICS

          int correctAnswers = 0;
          int wrongAnswers = 0;
          int attempts = 0;
          int durationSeconds = 0;

          double totalAccuracy = 0;

          for (final activity in activities) {
            correctAnswers +=
                (activity['correctAnswers'] as num?)
                    ?.toInt() ??
                    0;

            wrongAnswers +=
                (activity['wrongAnswers'] as num?)
                    ?.toInt() ??
                    0;

            attempts +=
                (activity['attempts'] as num?)
                    ?.toInt() ??
                    0;

            durationSeconds +=
                (activity['durationSeconds'] as num?)
                    ?.toInt() ??
                    0;

            totalAccuracy +=
                (activity['accuracy'] as num?)
                    ?.toDouble() ??
                    0;
          }

          final gamesCount = activities.length;

          final averageAccuracy =
          activities.isEmpty
              ? 0.0
              : totalAccuracy /
              activities.length;

          final totalMinutes =
              durationSeconds ~/ 60;


          final totalAIConversations = aiInteractions.length;

          int happyCount = 0;
          int sadCount = 0;
          int angryCount = 0;
          int fearCount = 0;
          int surpriseCount = 0;
          int neutralCount = 0;

          for (final emotionLog in emotionLogs) {
            final emotion = (emotionLog['emotion'] ?? 'neutral')
                .toString()
                .toLowerCase()
                .trim();

            switch (emotion) {
              case 'happy':
              case 'joy':
                happyCount++;
                break;

              case 'sad':
              case 'sadness':
                sadCount++;
                break;

              case 'angry':
              case 'anger':
                angryCount++;
                break;

              case 'fear':
                fearCount++;
                break;

              case 'surprise':
                surpriseCount++;
                break;

              case 'neutral':
              case 'natural':
              default:
                neutralCount++;
                break;
            }
          }

          final emotionCounts = {
            'Happy': happyCount,
            'Sad': sadCount,
            'Angry': angryCount,
            'Fear': fearCount,
            'Surprise': surpriseCount,
            'Neutral': neutralCount,
          };

          final mostFrequentEmotion = emotionCounts.entries
              .reduce(
                (current, next) =>
            current.value >= next.value ? current : next,
          )
              .key;

          Map<String, dynamic>? latestAIInteraction;

          if (aiInteractions.isNotEmpty) {
            latestAIInteraction = aiInteractions.first;
          }

          final latestEmotion = latestAIInteraction?['emotion'] ??
              'neutral';

          final latestMessage = latestAIInteraction?['message'] ??
              'No AI interactions yet.';

          final sevenDaysAgo = DateTime.now().subtract(
            const Duration(days: 7),
          );

          final recentAIInteractions = aiInteractions.where(
                (interaction) {
              final createdAt = DateTime.tryParse(
                interaction['createdAt']?.toString() ?? '',
              );

              if (createdAt == null) {
                return false;
              }

              return createdAt.isAfter(sevenDaysAgo);
            },
          ).toList();

          final last7DaysConversations =
              recentAIInteractions.length;

          final recentEmotionCounts = {
            'Happy': 0,
            'Sad': 0,
            'Angry': 0,
            'Fear': 0,
            'Surprise': 0,
            'Neutral': 0,
          };

          for (final interaction in recentAIInteractions) {
            final emotion = (interaction['emotion'] ?? 'neutral')
                .toString()
                .toLowerCase()
                .trim();

            switch (emotion) {
              case 'happy':
                recentEmotionCounts['Happy'] =
                    recentEmotionCounts['Happy']! + 1;
                break;

              case 'sad':
                recentEmotionCounts['Sad'] =
                    recentEmotionCounts['Sad']! + 1;
                break;

              case 'angry':
                recentEmotionCounts['Angry'] =
                    recentEmotionCounts['Angry']! + 1;
                break;

              case 'fear':
                recentEmotionCounts['Fear'] =
                    recentEmotionCounts['Fear']! + 1;
                break;

              case 'surprise':
                recentEmotionCounts['Surprise'] =
                    recentEmotionCounts['Surprise']! + 1;
                break;

              case 'neutral':
              default:
                recentEmotionCounts['Neutral'] =
                    recentEmotionCounts['Neutral']! + 1;
                break;
            }
          }

          final recentMostFrequentEmotion =
          recentAIInteractions.isEmpty
              ? 'No interactions yet'
              : recentEmotionCounts.entries.reduce(
                (current, next) =>
            current.value >= next.value
                ? current
                : next,
          ).key;

          String analysisInsight;

          if (aiInteractions.isEmpty) {
            analysisInsight =
            'More AI interactions are needed to identify emotional patterns.';
          } else {
            switch (mostFrequentEmotion.toLowerCase()) {
              case 'happy':
                analysisInsight =
                'The child mostly showed positive emotions during AI interactions.';
                break;

              case 'sad':
                analysisInsight =
                'The child often expressed sadness. Gentle support may be helpful.';
                break;

              case 'angry':
                analysisInsight =
                'The child frequently expressed anger. Encourage calm communication.';
                break;

              case 'fear':
                analysisInsight =
                'The child often expressed fear. Provide reassurance and support.';
                break;

              case 'surprise':
                analysisInsight =
                'The child frequently showed surprise during recent interactions.';
                break;

              case 'neutral':
              default:
                analysisInsight =
                'The child mostly showed neutral emotions during AI interactions.';
                break;
            }
          }

          final now = DateTime.now();

          final todayAIInteractions = aiInteractions.where(
                (interaction) {
              final createdAt = DateTime.tryParse(
                interaction['createdAt']?.toString() ?? '',
              );

              if (createdAt == null) {
                return false;
              }

              return createdAt.year == now.year &&
                  createdAt.month == now.month &&
                  createdAt.day == now.day;
            },
          ).toList();

          final todayConversations =
              todayAIInteractions.length;



          return ListView(
            padding: EdgeInsets.zero,

            children: [

              // DASHBOARD HEADER

              DashboardHeader(
                guardianName: guardian.name,
              ),

              const SizedBox(height: 20),


              // CHILD PROFILE CARD

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: Card(
                  elevation: 8,
                  shadowColor:
                  Colors.deepPurple.withOpacity(0.20),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(25),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      children: [

                        FutureBuilder<
                            Map<String, dynamic>?>(
                          future:
                          firestoreService.getChildFace(
                            childId,
                          ),

                          builder:
                              (context, faceSnapshot) {

                            final imageData =
                            faceSnapshot
                                .data?["imageData"];

                            return CircleAvatar(
                              radius: 55,

                              backgroundColor:
                              Colors.deepPurple
                                  .shade100,

                              backgroundImage:
                              imageData != null
                                  ? MemoryImage(
                                base64Decode(
                                  imageData,
                                ),
                              )
                                  : null,

                              child:
                              imageData == null
                                  ? const Icon(
                                Icons.child_care,
                                size: 55,
                                color:
                                Colors.deepPurple,
                              )
                                  : null,
                            );
                          },
                        ),

                        const SizedBox(height: 15),

                        Text(
                          child.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),

                          decoration: BoxDecoration(
                            color:
                            Colors.deepPurple.shade50,

                            borderRadius:
                            BorderRadius.circular(30),
                          ),

                          child: Text(
                            child.diagnosis,

                            style: const TextStyle(
                              color:
                              Colors.deepPurple,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Row(
                          children: [

                            Expanded(
                              child: _infoBox(
                                Icons.cake,
                                "Age",
                                child.ageRange,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: _infoBox(
                                Icons.person,
                                "Gender",
                                child.gender,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        _fullInfoBox(
                          Icons.language,
                          "Language",
                          child.language,
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,

                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.person_outline,
                            ),

                            label: const Text(
                              "View Child Profile",
                            ),

                            onPressed: () {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (_) =>
                                      ChildProfileScreen(
                                        childId: childId,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: FutureBuilder<Map<String, dynamic>?>(
                  future: firestoreService.getLatestAssessment(
                    childId,
                  ),
                  builder: (context, assessmentSnapshot) {
                    if (assessmentSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }

                    if (!assessmentSnapshot.hasData ||
                        assessmentSnapshot.data == null) {
                      return _dashboardCard(
                        title: "Assessment Results",
                        icon: Icons.assessment,
                        child: const Text(
                          "No assessment available",
                        ),
                      );
                    }

                    final assessment = assessmentSnapshot.data!;

                    final socialScore =
                        assessment["socialScore"] ?? 0;

                    final communicationScore =
                        assessment["communicationScore"] ?? 0;

                    final restrictedRoutineScore =
                        assessment["restrictedRoutineScore"] ?? 0;

                    final repetitiveScore =
                        assessment["repetitiveScore"] ?? 0;

                    final sensoryScore =
                        assessment["sensoryScore"] ?? 0;

                    final totalScore =
                        assessment["score"] ?? 0;

                    final supportLevel =
                        assessment["supportLevel"] ?? "Unknown";

                    final summary =
                        assessment["summary"] ??
                            "No summary available";

                    return _dashboardCard(
                      title: "Assessment Results",
                      icon: Icons.assessment,
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          _assessmentRow(
                            "Social Interaction",
                            socialScore,
                            "/4",
                          ),
                          _assessmentRow(
                            "Communication",
                            communicationScore,
                            "/4",
                          ),
                          _assessmentRow(
                            "Restricted / Routine",
                            restrictedRoutineScore,
                            "/4",
                          ),
                          _assessmentRow(
                            "Repetitive Behaviors",
                            repetitiveScore,
                            "/4",
                          ),
                          _assessmentRow(
                            "Sensory Differences",
                            sensoryScore,
                            "/4",
                          ),
                          const Divider(),
                          _assessmentRow(
                            "Total Score",
                            totalScore,
                            "/20",
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Support Level",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            supportLevel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            summary,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(
                                Icons.arrow_forward,
                              ),
                              label: const Text(
                                "View Full Assessment",
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AssessmentResultsScreen(
                                          childId: childId,
                                          guardianId: guardianId,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ACTIVITY SUMMARY

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: _dashboardCard(
                  title: "Activity Summary",

                  icon: Icons.insights,

                  child: Column(
                    children: [

                      _summaryTile(
                        Icons.games,
                        Colors.deepPurple,
                        "Games Played",
                        "$gamesCount",
                      ),

                      _summaryTile(
                        Icons.check_circle,
                        Colors.green,
                        "Correct Answers",
                        "$correctAnswers",
                      ),

                      _summaryTile(
                        Icons.cancel,
                        Colors.red,
                        "Wrong Answers",
                        "$wrongAnswers",
                      ),

                      _summaryTile(
                        Icons.touch_app,
                        Colors.blue,
                        "Total Attempts",
                        "$attempts",
                      ),

                      _summaryTile(
                        Icons.bar_chart,
                        Colors.orange,
                        "Average Game Accuracy",
                        "${averageAccuracy.toStringAsFixed(1)}%",
                      ),

                      _summaryTile(
                        Icons.timer,
                        Colors.purple,
                        "Game Time",
                        "$totalMinutes min",
                      ),


                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),




              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade400,
                            Colors.deepPurple.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Analysis',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Emotional interaction overview',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.deepPurple.shade50,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.10),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade100,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.deepPurple.shade700,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI Interaction Analysis',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Based on recorded AI interactions',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: _aiStatCard(
                                icon: Icons.chat_bubble_rounded,
                                title: 'Conversations',
                                value: '$totalAIConversations',
                                iconColor: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _aiStatCard(
                                icon: Icons.today_rounded,
                                title: 'Today',
                                value: '$todayConversations',
                                iconColor: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _aiStatCard(
                                icon: Icons.calendar_month_rounded,
                                title: '7 Days',
                                value: '$last7DaysConversations',
                                iconColor: Colors.orange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Icon(
                              Icons.emoji_emotions_rounded,
                              color: Colors.deepPurple.shade700,
                              size: 21,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Detected Emotions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        _emotionProgressRow(
                          emoji: '😊',
                          label: 'Happy',
                          count: happyCount,
                          total: emotionLogs.length,
                        ),

                        _emotionProgressRow(
                          emoji: '😢',
                          label: 'Sad',
                          count: sadCount,
                          total: emotionLogs.length,
                        ),

                        _emotionProgressRow(
                          emoji: '😡',
                          label: 'Angry',
                          count: angryCount,
                          total: emotionLogs.length,
                        ),

                        _emotionProgressRow(
                          emoji: '😨',
                          label: 'Fear',
                          count: fearCount,
                          total: emotionLogs.length,
                        ),

                        _emotionProgressRow(
                          emoji: '😲',
                          label: 'Surprise',
                          count: surpriseCount,
                          total: emotionLogs.length,
                        ),

                        _emotionProgressRow(
                          emoji: '😐',
                          label: 'Neutral',
                          count: neutralCount,
                          total: emotionLogs.length,
                        ),

                        const SizedBox(height: 18),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.trending_up_rounded,
                                  color: Colors.deepPurple.shade700,
                                  size: 21,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Most Frequent Emotion',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      mostFrequentEmotion,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.amber.shade100,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.lightbulb_rounded,
                                  color: Colors.amber.shade800,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'AI Insight',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      analysisInsight,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.45,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.history_rounded,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Latest AI Interaction',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      'Emotion: $latestEmotion',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      latestMessage,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.4,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),











              const SizedBox(height: 20),

              // CHILD FACE REGISTRATION

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: _actionCard(
                  icon: Icons.face_retouching_natural,

                  title:
                  "Child Face Registration",

                  subtitle:
                  "Register or update the child's face",

                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            ChildFaceRegistrationScreen(
                              childId: childId,
                            ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // CHILD PROFILE

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: _actionCard(
                  icon: Icons.child_care,

                  title: "Child Profile",

                  subtitle:
                  "View child's information",

                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            ChildProfileScreen(
                              childId: childId,
                            ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // GUARDIAN PROFILE

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: _actionCard(
                  icon: Icons.family_restroom,

                  title: "Guardian Profile",

                  subtitle:
                  "View guardian information",

                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            GuardianProfileScreen(
                              guardianId: guardianId,
                            ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),


              const SizedBox(height: 12),

              // PDF REPORT

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: SizedBox(
                  width: double.infinity,

                  height: 55,

                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.picture_as_pdf,
                    ),

                    label: const Text(
                      "Download PDF Report",
                    ),

                    onPressed: () async {
                      try {
                        await PdfService.generateWeeklyReport(
                          childId: childId,
                        );

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "PDF report generated successfully",
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              "Failed to generate PDF: $e",
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // SETTINGS

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: _actionCard(
                  icon: Icons.settings,

                  title: "Settings",

                  subtitle:
                  "Language, notifications and security",

                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                        const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // LOGOUT

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),

                    title: const Text(
                      "Logout",

                      style: TextStyle(
                        color: Colors.red,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                          const WelcomeScreen(),
                        ),

                            (route) => false,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  // INFO BOX

  static Widget _infoBox(
      IconData icon,
      String title,
      String value,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,

        borderRadius:
        BorderRadius.circular(18),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            color: Colors.deepPurple,
          ),

          const SizedBox(height: 6),

          Text(
            title,

            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,

            textAlign: TextAlign.center,

            style: const TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // FULL INFO BOX

  static Widget _fullInfoBox(
      IconData icon,
      String title,
      String value,
      ) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,

        borderRadius:
        BorderRadius.circular(18),
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color: Colors.deepPurple,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,

                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // DASHBOARD CARD

  static Widget _dashboardCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 6,

      shadowColor:
      Colors.deepPurple.withOpacity(0.12),

      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(22),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Row(
              children: [

                Container(
                  padding:
                  const EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color:
                    Colors.deepPurple.shade50,

                    borderRadius:
                    BorderRadius.circular(14),
                  ),

                  child: Icon(
                    icon,
                    color: Colors.deepPurple,
                  ),
                ),

                const SizedBox(width: 12),

                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            child,
          ],
        ),
      ),
    );
  }

  // SUMMARY TILE

  static Widget _summaryTile(
      IconData icon,
      Color color,
      String title,
      String value,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: CircleAvatar(
        backgroundColor:
        color.withOpacity(0.12),

        child: Icon(
          icon,
          color: color,
        ),
      ),

      title: Text(title),

      trailing: Text(
        value,

        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }


  // ASSESSMENT ROW


  static Widget _assessmentRow(
      String title,
      dynamic value,
      String suffix,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 5,
      ),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

        children: [

          Text(title),

          Text(
            "${value ?? 0}$suffix",

            style: const TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ACTION CARD


  static Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),
      ),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
          Colors.deepPurple.shade50,

          child: Icon(
            icon,
            color: Colors.deepPurple,
          ),
        ),

        title: Text(
          title,

          style: const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),

        subtitle: Text(subtitle),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),

        onTap: onTap,
      ),
    );
  }


  static Widget _aiStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 23,
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _emotionProgressRow({
    required String emoji,
    required String label,
    required int count,
    required int total,
  }) {
    final double progress =
    total == 0 ? 0 : count / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 19),
            ),
          ),
          SizedBox(
            width: 65,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.deepPurple.shade400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 28,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

}