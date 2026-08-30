import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'assessment_screen_2.dart';

class AssessmentScreen1 extends StatefulWidget {
  final String childId;

  const AssessmentScreen1({
    super.key,
    required this.childId,
  });

  @override
  State<AssessmentScreen1> createState() => _AssessmentScreen1State();
}

class _AssessmentScreen1State extends State<AssessmentScreen1> {

  final List<String> questions = [

    "Does your child make eye contact during conversations?",

    "Does your child show interest in interacting with other children?",

    "Does your child respond when someone smiles or waves?",

    "Does your child point to objects to share interest with others?",

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

    for (final answer in answers) {
      // "No" indicates possible difficulty
      if (answer == false) {
        pageScore++;
      }
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
                fontSize: 14,
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
    ).animate().fade(duration: 400.ms).slideY(begin: 0.2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F3FF),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Assessment"),
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

              const SizedBox(height: 12),

              const Text(
                "Step 1 of 5",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const LinearProgressIndicator(
                  value: 0.20,
                  minHeight: 10,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation(
                    Colors.deepPurple,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Social Interaction",
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

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssessmentScreen2(
                          childId: widget.childId,
                          // Copy answers safely
                          previousAnswers: List<bool?>.from(answers),

                          // Total score so far
                          previousScore: pageScore,

                          // Social category score
                          socialScore: pageScore,
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