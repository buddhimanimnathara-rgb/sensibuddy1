import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About SensiBuddy"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF6F2FF),
              Color(0xFFE4D7FF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                /// Mascot
                Image.asset(
                  "assets/images/mascot.png",
                  height: 170,
                )
                    .animate(
                  onPlay: (controller) =>
                      controller.repeat(reverse: true),
                )
                    .moveY(
                  begin: 0,
                  end: -8,
                  duration: const Duration(seconds: 2),
                )
                    .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                  duration: const Duration(seconds: 2),
                ),

                const SizedBox(height: 20),

                const Text(
                  "SensiBuddy",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "AI Companion for Children",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 25),

                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "SensiBuddy is an AI-powered mobile application specially designed to support children with Autism Spectrum Disorder (ASD) and developmental challenges.\n\nThe application provides interactive learning, speech practice, emotional support, daily activities, and AI-assisted communication while allowing parents to monitor their child's progress in a secure environment.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Main Features",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                _featureTile(
                  Icons.smart_toy,
                  "AI Buddy",
                  "Interactive AI companion for children",
                ),

                _featureTile(
                  Icons.psychology,
                  "Emotion Recognition",
                  "Understand and monitor emotions",
                ),

                _featureTile(
                  Icons.school,
                  "Learning Activities",
                  "Fun educational games and exercises",
                ),

                _featureTile(
                  Icons.family_restroom,
                  "Parent Dashboard",
                  "Monitor child progress and reports",
                ),

                _featureTile(
                  Icons.child_care,
                  "Child Dashboard",
                  "Child-friendly interactive experience",
                ),

                _featureTile(
                  Icons.analytics,
                  "Progress Tracking",
                  "View assessments and improvements",
                ),

                const SizedBox(height: 30),

                Card(
                  color: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      children: [

                        Text(
                          "Version 1.0.0",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          "Developed for the Final Year Research Project\nUniversity of ICBU Kurunegala",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          "© 2026 SensiBuddy\nHelping Every Child Shine",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _featureTile(
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade100,
          child: Icon(
            icon,
            color: Colors.deepPurple,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}