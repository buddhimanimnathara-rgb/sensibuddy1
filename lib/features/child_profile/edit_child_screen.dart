import 'package:flutter/material.dart';
import '../../core/services/firestore_service.dart';

class EditChildScreen extends StatefulWidget {
  final String childId;

  const EditChildScreen({
    super.key,
    required this.childId,
  });

  @override
  State<EditChildScreen> createState() =>
      _EditChildScreenState();
}

class _EditChildScreenState
    extends State<EditChildScreen> {

  final _nameController =
  TextEditingController();

  bool _loading = true;

  String selectedAgeRange = "3-5";
  String selectedLanguage = "en";

  @override
  void initState() {
    super.initState();
    _loadChild();
  }

  Future<void> _loadChild() async {

    final child =
    await firestoreService.getChild(
      widget.childId,
    );

    if (child != null) {

      _nameController.text =
          child.name;

      selectedAgeRange =
          child.ageRange;

      selectedLanguage =
          child.language;
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveChild() async {

    await firestoreService.updateChild(
      widget.childId,
      {
        "name":
        _nameController.text.trim(),

        "ageRange":
        selectedAgeRange,

        "language":
        selectedLanguage,
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Child information updated",
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
        title: const Text("Edit Child Profile"),
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
                      Icons.child_care,
                      size: 55,
                      color: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Update Child Information",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Keep your child's profile information up to date.",
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
                      labelText: "Child Name",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: selectedAgeRange,
                    decoration: InputDecoration(
                      labelText: "Age Range",
                      prefixIcon: const Icon(Icons.cake),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items: const [

                      DropdownMenuItem(
                        value: "3-5",
                        child: Text("3 - 5 Years"),
                      ),

                      DropdownMenuItem(
                        value: "6-9",
                        child: Text("6 - 9 Years"),
                      ),

                      DropdownMenuItem(
                        value: "10-12",
                        child: Text("10 - 12 Years"),
                      ),

                      DropdownMenuItem(
                        value: "13-15",
                        child: Text("13 - 15 Years"),
                      ),

                    ],
                    onChanged: (value) {

                      if (value == null) return;

                      setState(() {
                        selectedAgeRange = value;
                      });

                    },
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: selectedLanguage,
                    decoration: InputDecoration(
                      labelText: "Preferred Language",
                      prefixIcon: const Icon(Icons.language),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items: const [

                      DropdownMenuItem(
                        value: "en",
                        child: Text("English"),
                      ),

                      DropdownMenuItem(
                        value: "si",
                        child: Text("Sinhala"),
                      ),

                      DropdownMenuItem(
                        value: "ta",
                        child: Text("Tamil"),
                      ),

                    ],
                    onChanged: (value) {

                      if (value == null) return;

                      setState(() {
                        selectedLanguage = value;
                      });

                    },
                  ),

                  const SizedBox(height: 35),

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
                      onPressed: _saveChild,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
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
    super.dispose();
  }
}