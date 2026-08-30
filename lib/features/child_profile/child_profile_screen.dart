import 'package:flutter/material.dart';
import 'dart:convert';
import '../../core/models/child_model.dart';
import '../../core/services/firestore_service.dart';
import 'edit_child_screen.dart';

class ChildProfileScreen extends StatelessWidget {

  final String childId;

  const ChildProfileScreen({
    super.key,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF7F3FF),
      appBar: AppBar(
        title: const Text(
          "Child Profile",
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: FutureBuilder<ChildModel?>(
        future: firestoreService.getChild(
          childId,
        ),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data == null) {

            return const Center(
              child: Text(
                "Child not found",
              ),
            );
          }

          final child = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(

              children: [

                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [

                        FutureBuilder<Map<String, dynamic>?>(
                          future: firestoreService.getChildFace(childId),
                          builder: (context, snapshot) {

                            final imageData =
                            snapshot.data?["imageData"];

                            return CircleAvatar(
                              radius: 60,
                              backgroundColor:
                              Colors.deepPurple.shade100,
                              backgroundImage: imageData != null
                                  ? MemoryImage(
                                base64Decode(imageData),
                              )
                                  : null,
                              child: imageData == null
                                  ? const Icon(
                                Icons.child_care,
                                size: 60,
                                color: Colors.deepPurple,
                              )
                                  : null,
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        Text(
                          child.name,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius:
                            BorderRadius.circular(30),
                          ),
                          child: Text(
                            child.diagnosis,
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                FutureBuilder<Map<String, dynamic>?>(
                  future: firestoreService.getChildFace(childId),
                  builder: (context, snapshot) {

                    final registered =
                        snapshot.data?["registered"] ?? false;

                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(

                        leading: Icon(
                          Icons.face,
                          color: registered
                              ? Colors.green
                              : Colors.red,
                        ),

                        title: const Text(
                          "Face Registration",
                        ),

                        trailing: Chip(
                          backgroundColor:
                          registered
                              ? Colors.green
                              : Colors.red,

                          label: Text(
                            registered
                                ? "Registered"
                                : "Not Registered",
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                 SizedBox(height: 20),

                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.person,
                    ),
                    title: const Text(
                      "Name",
                    ),
                    subtitle: Text(
                      child.name,
                    ),
                  ),
                ),

                _InfoCard(
                  icon: Icons.cake,
                  title: "Age Range",
                  value: child.ageRange,
                ),

                _InfoCard(
                  icon: Icons.wc,
                  title: "Gender",
                  value: child.gender,
                ),

                _InfoCard(
                  icon: Icons.language,
                  title: "Language",
                  value: child.language,
                ),

                _InfoCard(
                  icon: Icons.health_and_safety,
                  title: "Diagnosis",
                  value: child.diagnosis,
                ),

                const SizedBox(
                  height: 20,
                ),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditChildScreen(
                                childId: childId,
                              ),
                        ),
                      );

                    },
                    icon: const Icon(Icons.edit),
                    label: const Text(
                      "Edit Child Information",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {

  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: ListTile(

        leading: CircleAvatar(
          backgroundColor:
          Colors.deepPurple.shade100,
          child: Icon(
            icon,
            color: Colors.deepPurple,
          ),
        ),

        title: Text(title),

        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}