import 'package:flutter/material.dart';
import 'dart:convert';
import '../../core/models/guardian_model.dart';
import '../../core/services/firestore_service.dart';
import '../guardian/edit_gardian_screen.dart';

class GuardianProfileScreen extends StatelessWidget {
  final String guardianId;

  const GuardianProfileScreen({
    super.key,
    required this.guardianId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F3FF),

      appBar: AppBar(
        title: const Text("Guardian Profile"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: FutureBuilder<GuardianModel?>(
        future: firestoreService.getGuardian(guardianId),
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
              child: Text("Guardian not found"),
            );
          }

          final guardian = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [

                /// PROFILE HEADER

                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding:
                    const EdgeInsets.all(24),
                    child: Column(
                      children: [

                        FutureBuilder<
                            Map<String, dynamic>?>(
                          future:
                          firestoreService
                              .getGuardianFace(
                              guardianId),
                          builder:
                              (context, snapshot) {

                            final imageData =
                            snapshot.data?[
                            "imageData"];

                            return CircleAvatar(
                              radius: 60,
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
                                Icons
                                    .family_restroom,
                                size: 60,
                                color: Colors
                                    .deepPurple,
                              )
                                  : null,
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        Text(
                          guardian.name,
                          style:
                          const TextStyle(
                            fontSize: 25,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration:
                          BoxDecoration(
                            color: Colors
                                .deepPurple
                                .shade50,
                            borderRadius:
                            BorderRadius
                                .circular(
                                30),
                          ),
                          child: Text(
                            guardian.relationship,
                            style:
                            const TextStyle(
                              color: Colors
                                  .deepPurple,
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _InfoCard(
                  icon: Icons.person,
                  title: "Guardian Name",
                  value: guardian.name,
                ),

                _InfoCard(
                  icon: Icons.phone,
                  title: "Phone Number",
                  value: guardian.phone,
                ),

                _InfoCard(
                  icon: Icons.people,
                  title: "Relationship",
                  value: guardian.relationship,
                ),

                _InfoCard(
                  icon: Icons.email,
                  title: "Email",
                  value: guardian.email,
                ),

                FutureBuilder<
                    Map<String, dynamic>?>(
                  future: firestoreService
                      .getGuardianFace(
                      guardianId),
                  builder:
                      (context, snapshot) {

                    final registered =
                        snapshot.data?[
                        "registered"] ??
                            false;

                    return Card(
                      elevation: 5,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                            18),
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
                              ? Colors
                              .green
                              : Colors.red,
                          label: Text(
                            registered
                                ? "Registered"
                                : "Not Registered",
                            style:
                            const TextStyle(
                              color: Colors
                                  .white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                _InfoCard(
                  icon: Icons.calendar_today,
                  title: "Registration Date",
                  value: guardian.createdAt,
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      Colors.deepPurple,
                      foregroundColor:
                      Colors.white,
                      elevation: 5,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                            16),
                      ),
                    ),
                    onPressed: () async {

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditGuardianScreen(
                                guardianId:
                                guardianId,
                              ),
                        ),
                      );

                    },
                    icon:
                    const Icon(Icons.edit),
                    label: const Text(
                      "Edit Guardian Information",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

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