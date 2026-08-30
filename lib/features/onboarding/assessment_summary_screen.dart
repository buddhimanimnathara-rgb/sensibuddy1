import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/firestore_service.dart';
import '../guardian/guardian_registration_screen.dart';

class AssessmentSummaryScreen extends StatefulWidget {

  final String childId;

  const AssessmentSummaryScreen({
    super.key,
    required this.childId,
  });

  @override
  State<AssessmentSummaryScreen> createState() =>
      _AssessmentSummaryScreenState();
}

class _AssessmentSummaryScreenState
    extends State<AssessmentSummaryScreen> {

  bool loading = true;

  int score = 0;

  String supportLevel = "";

  String summary = "";

  @override
  void initState() {
    super.initState();
    loadAssessment();
  }

  Future<void> loadAssessment() async {

    final data =
    await firestoreService.getLatestAssessment(
      widget.childId,
    );

    if (data != null) {

      score = data["score"] ?? 0;

      supportLevel =
          data["supportLevel"] ?? "";

      summary =
          data["summary"] ?? "";
    }

    setState(() {
      loading = false;
    });
  }

  Color getLevelColor() {

    switch (supportLevel) {

      case "Low":
        return Colors.green;

      case "Mild":
        return Colors.orange;

      case "Moderate":
        return Colors.deepOrange;

      case "High":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  IconData getLevelIcon() {

    switch (supportLevel) {

      case "Low":
        return Icons.sentiment_very_satisfied;

      case "Mild":
        return Icons.sentiment_satisfied;

      case "Moderate":
        return Icons.sentiment_neutral;

      case "High":
        return Icons.warning_rounded;

      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      backgroundColor: const Color(0xffF7F3FF),

      appBar: AppBar(
        title: const Text("Assessment Summary"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              Image.asset(
                "assets/images/mascot.png",
                height: 120,
              )
                  .animate(
                onPlay: (controller) =>
                    controller.repeat(reverse: true),
              )
                  .moveY(
                begin: 0,
                end: -10,
                duration: 2.seconds,
              ),

              const SizedBox(height: 15),

              const Text(
                "Assessment Completed",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "The assessment has been completed successfully.\nYou can view the detailed report later from the Parent Dashboard.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 25),

              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [

                      const Text(
                        "Overall Score",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "$score / 20",
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),

                      const Divider(height: 40),

                      const Text(
                        "Support Level",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Chip(
                        avatar: Icon(
                          getLevelIcon(),
                          color: Colors.white,
                          size: 20,
                        ),
                        backgroundColor: getLevelColor(),
                        label: Text(
                          supportLevel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "Assessment Summary",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        summary,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            GuardianRegistrationScreen(
                              childId: widget.childId,
                            ),
                      ),
                    );
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}
