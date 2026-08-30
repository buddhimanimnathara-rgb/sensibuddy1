import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'assessment_screen_4.dart';

class AssessmentScreen3 extends StatefulWidget {
  final String childId;
  final List<bool?> previousAnswers;
  final int previousScore;

  final int socialScore;
  final int communicationScore;

  const AssessmentScreen3({
    super.key,
    required this.childId,
    required this.previousAnswers,
    required this.previousScore,
    required this.socialScore,
    required this.communicationScore,

  });

  @override
  State<AssessmentScreen3> createState() => _AssessmentScreen3State();
}

class _AssessmentScreen3State extends State<AssessmentScreen3> {

  final List<String> questions = [

    "Does your child bring objects to show them to others?",

    "Does your child attempt to start conversations with others?",

    "Does your child become upset when routines change?",

    "Does your child insist on doing activities in a specific order?",

  ];

  late List<bool?> answers;

  int pageScore = 0;

  @override
  void initState() {
    super.initState();
    answers = List<bool?>.filled(questions.length, null);
  }

  bool get completed => !answers.contains(null);

  void calculateScore() {
    pageScore = 0;

    // Q1 - No = Concern
    if (answers[0] == false) {
      pageScore++;
    }

    // Q2 - No = Concern
    if (answers[1] == false) {
      pageScore++;
    }

    // Q3 - Yes = Concern
    if (answers[2] == true) {
      pageScore++;
    }

    // Q4 - Yes = Concern
    if (answers[3] == true) {
      pageScore++;
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
              title: const Text("Yes"),
              value: true,
              groupValue: answers[index],
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  answers[index] = value;
                });
              },
            ),

            RadioListTile<bool>(
              title: const Text("No"),
              value: false,
              groupValue: answers[index],
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
    ).animate().fade(duration: 400.ms).slideY(begin: 0.2);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF7F3FF),

      appBar: AppBar(
        title: const Text("Assessment"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
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
                "Step 3 of 5",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const LinearProgressIndicator(
                  value: 0.60,
                  minHeight: 10,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation(
                    Colors.deepPurple,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Restricted Routines",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
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
                  onPressed: () {

                    if (!completed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please answer all questions before continuing.",
                          ),
                        ),
                      );
                      return;
                    }

                    calculateScore();

                    final int totalScore =
                        widget.previousScore + pageScore;

                    final List<bool?> allAnswers = [
                      ...widget.previousAnswers,
                      ...List<bool?>.from(answers),
                    ];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssessmentScreen4(
                          childId: widget.childId,
                          previousAnswers:
                          List<bool?>.from(allAnswers),

                          previousScore: totalScore,

                          socialScore: widget.socialScore,

                          communicationScore:
                          widget.communicationScore,
                          restrictedRoutineScore: pageScore,

                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Next",
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