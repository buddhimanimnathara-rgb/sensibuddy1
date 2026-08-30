import 'package:flutter/material.dart';
import '../../core/services/firestore_service.dart';

class EditGuardianScreen extends StatefulWidget {
  final String guardianId;

  const EditGuardianScreen({
    super.key,
    required this.guardianId,
  });

  @override
  State<EditGuardianScreen> createState() =>
      _EditGuardianScreenState();
}

class _EditGuardianScreenState
    extends State<EditGuardianScreen> {

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _loading = true;

  String selectedRelationship = "Mother";

  @override
  void initState() {
    super.initState();
    _loadGuardian();
  }

  Future<void> _loadGuardian() async {

    final guardian =
    await firestoreService.getGuardian(
      widget.guardianId,
    );

    if (guardian != null) {

      _nameController.text =
          guardian.name;

      _phoneController.text =
          guardian.phone;

      selectedRelationship =
          guardian.relationship;
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveGuardian() async {

    await firestoreService.updateGuardian(
      widget.guardianId,
      {
        "name":
        _nameController.text.trim(),

        "phone":
        _phoneController.text.trim(),

        "relationship":
        selectedRelationship,
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Guardian information updated",
        ),
      ),
    );

    Navigator.pop(
      context,
      true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF7F3FF),

      appBar: AppBar(
        title: const Text("Edit Guardian"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [

                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.deepPurple.shade100,
                    child: const Icon(
                      Icons.family_restroom,
                      size: 55,
                      color: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Update Guardian Information",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Keep guardian information up to date.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Guardian Name",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: selectedRelationship,
                    decoration: InputDecoration(
                      labelText: "Relationship",
                      prefixIcon:
                      const Icon(Icons.people),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                    ),
                    items: const [

                      DropdownMenuItem(
                        value: "Mother",
                        child: Text("Mother"),
                      ),

                      DropdownMenuItem(
                        value: "Father",
                        child: Text("Father"),
                      ),

                      DropdownMenuItem(
                        value: "Guardian",
                        child: Text("Guardian"),
                      ),

                    ],
                    onChanged: (value) {

                      if (value == null) return;

                      setState(() {
                        selectedRelationship = value;
                      });

                    },
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.deepPurple,
                        foregroundColor:
                        Colors.white,
                        elevation: 5,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _saveGuardian,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}