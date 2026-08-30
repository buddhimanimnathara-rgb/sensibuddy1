import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sensibuddy1/features/onboarding/assessment_screen_1.dart';

import '../../core/services/firestore_service.dart';

class ChildRegistrationScreen extends StatefulWidget {
  const ChildRegistrationScreen({super.key});

  @override
  State<ChildRegistrationScreen> createState() =>
      _ChildRegistrationScreenState();
}

class _ChildRegistrationScreenState
    extends State<ChildRegistrationScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
  TextEditingController();

  String? ageRange;

  String? gender;

  String? diagnosis;

  String? selectedLanguage;

  bool loading = false;


  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> saveChild() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please select a preferred language."),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {

      debugPrint(
        "Selected Language: $selectedLanguage",
      );

      final childId =
      await firestoreService.saveChild({

        "name": nameController.text.trim(),

        "ageRange": ageRange,

        "gender": gender,

        "diagnosis": diagnosis,

        "language": selectedLanguage,

        "createdAt":
        DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AssessmentScreen1(
            childId: childId,
          ),
        ),
      );

    } catch (e) {

      debugPrint(
        "Error saving child: $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [

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
                      duration: 2.seconds,
                    )
                        .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: 2.seconds,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Let's Get Started!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A148C),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Tell us about your little friend.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 30),

                    TextFormField(
                      controller: nameController,

                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.child_care),
                        labelText: "Child Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      validator: (value) {

                        if (value == null ||
                            value.trim().isEmpty) {

                          return
                            "Please enter child name";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: ageRange,
                      hint: const Text("Select Age Range"),

                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.cake),
                        labelText: "Age Range",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: "3-5",
                          child: Text("3-5 Years"),
                        ),
                        DropdownMenuItem(
                          value: "6-9",
                          child: Text("6-9 Years"),
                        ),
                        DropdownMenuItem(
                          value: "10-12",
                          child: Text("10-12 Years"),
                        ),
                        DropdownMenuItem(
                          value: "13-15",
                          child: Text("13-15 Years"),
                        ),
                      ],

                      onChanged: (value) {
                        setState(() {
                          ageRange = value;
                        });
                      },

                      validator: (value) {
                        if (value == null) {
                          return "Please select age range";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.people),
                        labelText: "Gender",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Male",
                          child: Text("Male"),
                        ),
                        DropdownMenuItem(
                          value: "Female",
                          child: Text("Female"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          gender = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Please select gender";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Preferred Language",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      children: [

                        ChoiceChip(
                          label: const Text("English"),
                          selected: selectedLanguage == "en",
                          onSelected: (_) {
                            setState(() {
                              selectedLanguage = "en";
                            });
                          },
                        ),

                        ChoiceChip(
                          label: const Text("සිංහල"),
                          selected: selectedLanguage == "si",
                          onSelected: (_) {
                            setState(() {
                              selectedLanguage = "si";
                            });
                          },
                        ),

                        ChoiceChip(
                          label: const Text("தமிழ்"),
                          selected: selectedLanguage == "ta",
                          onSelected: (_) {
                            setState(() {
                              selectedLanguage = "ta";
                            });
                          },
                        ),

                      ],
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: diagnosis,
                      hint: const Text("Select Autism Status"),

                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.medical_information),
                        labelText: "Autism Status",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      items: const [

                        DropdownMenuItem(
                          value: "No Diagnosis Yet",
                          child: Text("No Diagnosis Yet"),
                        ),

                        DropdownMenuItem(
                          value: "Autism Spectrum Disorder (ASD)",
                          child: Text("Autism Spectrum Disorder (ASD)"),
                        ),

                        DropdownMenuItem(
                          value: "Suspected Autism",
                          child: Text("Suspected Autism"),
                        ),

                        DropdownMenuItem(
                          value: "Other",
                          child: Text("Other"),
                        ),

                      ],

                      onChanged: (value) {
                        setState(() {
                          diagnosis = value;
                        });
                      },

                      validator: (value) {
                        if (value == null) {
                          return "Please select autism status";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 40,
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C4DFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: loading ? null : saveChild,
                        child: loading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              " Continue ",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}