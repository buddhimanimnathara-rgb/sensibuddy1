import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/assessment_model.dart';
import '../../core/services/firestore_service.dart';
import 'assessment_summary_screen.dart';

class AssessmentScreen5 extends StatefulWidget {
  final String childId;
  final List<bool?> previousAnswers;
  final int previousScore;
  final int socialScore;
  final int communicationScore;
  final int restrictedRoutineScore;
  final int repetitiveScore;

  const AssessmentScreen5({
    super.key,
    required this.childId,
    required this.previousAnswers,
    required this.previousScore,
    required this.socialScore,
    required this.communicationScore,
    required this.restrictedRoutineScore,
    required this.repetitiveScore,
  });

  @override
  State<AssessmentScreen5> createState() =>
      _AssessmentScreen5State();
}

class _AssessmentScreen5State
    extends State<AssessmentScreen5> {

  final List<String> questions = [

    "Does your child flap hands, rock, spin, or make repetitive body movements?",

    "Is your child sensitive to loud sounds?",

    "Is your child sensitive to lights, textures, smells, or touch?",

    "Does your child seek sensory stimulation such as rocking, spinning, or staring at moving objects?",

  ];

  late List<bool?> answers;

  int sensoryScore = 0;

  int totalScore = 0;

  String supportLevel = "";

  String summary = "";

  @override
  void initState() {
    super.initState();

    answers =
    List<bool?>.filled(questions.length, null);
  }

  bool get completed =>
      !answers.contains(null);


  void calculateSensoryScore() {

    sensoryScore = 0;

    // Q1 - Yes = Concern
    if (answers[0] == true) {
      sensoryScore++;
    }

    // Q2 - Yes = Concern
    if (answers[1] == true) {
      sensoryScore++;
    }

    // Q3 - Yes = Concern
    if (answers[2] == true) {
      sensoryScore++;
    }

    // Q4 - Yes = Concern
    if (answers[3] == true) {
      sensoryScore++;
    }
  }

//--------------------------------------------------
// Calculate Final Assessment Score
//--------------------------------------------------

  void calculateTotalScore() {

    totalScore =
        widget.previousScore +
            sensoryScore;

  }

  //--------------------------------------------------
  // Rule Based Expert System
  //--------------------------------------------------

  void determineSupportLevel() {

    if (totalScore <= 5) {

      supportLevel = "Low";

      summary =
      "The assessment indicates minimal developmental concerns. Continue encouraging communication, social interaction, and regular developmental monitoring.";

    }

    else if (totalScore <= 10) {

      supportLevel = "Mild";

      summary =
      "Some developmental concerns were identified. Continue monitoring your child's progress and consider consulting a healthcare professional if concerns persist.";

    }

    else if (totalScore <= 15) {

      supportLevel = "Moderate";

      summary =
      "Several developmental concerns were identified. A developmental assessment by a qualified specialist is recommended.";

    }

    else {

      supportLevel = "High";

      summary =
      "Significant developmental concerns were identified. A comprehensive evaluation by a qualified healthcare professional is strongly recommended.";

    }

  }


    Future<void> saveAssessment() async {
      calculateSensoryScore();
      calculateTotalScore();
      determineSupportLevel();

      final List<bool> allAnswers = [

        ...widget.previousAnswers.cast<bool>(),

        ...answers.cast<bool>(),

      ];

      final assessment = AssessmentModel(
        childId: widget.childId,

        answers: allAnswers,

        socialScore: widget.socialScore,
        communicationScore: widget.communicationScore,
        restrictedRoutineScore:
        widget.restrictedRoutineScore,

        repetitiveScore:
        widget.repetitiveScore,

        sensoryScore:
        sensoryScore,

        score: totalScore,
        supportLevel: supportLevel,
        summary: summary,
      );

      try {

        await firestoreService.saveAssessment(
          widget.childId,
          assessment.toMap(),
        );

        debugPrint("Assessment Saved Successfully");

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AssessmentSummaryScreen(
              childId: widget.childId,
            ),
          ),
        );

      } catch (e) {

        debugPrint("Assessment Save Error: $e");

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error : $e"),
          ),
        );

      }
    }

  Widget buildQuestionCard(int index) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${index + 1} of ${questions.length}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              questions[index],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 18),

            RadioListTile<bool>(
              value: true,
              groupValue: answers[index],
              title: const Text("Yes"),
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  answers[index] = value;
                });
              },
            ),

            RadioListTile<bool>(
              value: false,
              groupValue: answers[index],
              title: const Text("No"),
              activeColor: Colors.red,
              onChanged: (value) {
                setState(() {
                  answers[index] = value;
                });
              },
            ),
          ],
        ),
      ),
    ).animate().fade().slideY(begin: .2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F3FF),

      appBar: AppBar(
        title: const Text("Assessment"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
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

              const SizedBox(height: 10),

              const Text(
                "Step 5 of 5",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const LinearProgressIndicator(
                  value: 1.0,
                  minHeight: 10,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation(
                    Colors.deepPurple,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Sensory Differences",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (_, index) {
                    return buildQuestionCard(index);
                  },
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {

                    if (!completed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please answer all questions before submitting.",
                          ),
                        ),
                      );
                      return;
                    }

                    await saveAssessment();

                  },
                  child: const Text(
                    "Finish Assessment",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

            ],
          ),
        ),
      ),
    );
  }
}
