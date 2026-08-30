import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/parent_pin_model.dart';
import '../../core/services/firestore_service.dart';
import 'pin_login_screen.dart';

class ParentPinScreen extends StatefulWidget {
  final String guardianId;
  final String childId;


  const ParentPinScreen({
    super.key,
    required this.guardianId,
    required this.childId,
  });

  @override
  State<ParentPinScreen> createState() =>
      _ParentPinScreenState();
}

class _ParentPinScreenState
    extends State<ParentPinScreen> {

  final TextEditingController confirmPinController =
  TextEditingController();

  final TextEditingController pinController =
  TextEditingController();

  bool loading = false;


  @override
  void dispose() {
    confirmPinController.dispose();
    pinController.dispose();
    super.dispose();
  }

  Future<void> savePin() async {

    FocusScope.of(context).unfocus();

    if (pinController.text.length != 4 ||
        int.tryParse(pinController.text) == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Please enter a valid 4-digit PIN.",
          ),
        ),
      );
      return;
    }

    if (pinController.text != confirmPinController.text) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "PINs do not match. Please try again.",
          ),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {

      final pin = ParentPinModel(
        guardianId: widget.guardianId,
        pin: pinController.text,
      );

      await firestoreService.saveParentPin(
        widget.guardianId,
        pin.toMap(),
      );

      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
        "setup_complete",
        true,
      );

      await prefs.setString(
        "guardian_id",
        widget.guardianId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "PIN created successfully.\nRedirecting to login...",
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PinLoginScreen(
            guardianId: widget.guardianId,
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Failed to save PIN.\n$e",
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
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF7F3FF),

      appBar: AppBar(
        title: const Text("Parent PIN Setup"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

        body: SizedBox.expand(
          child: Container(
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),

                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),

                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [

                            Image.asset(
                              "assets/images/mascot.png",
                              height: 120,
                            )
                                .animate(
                              onPlay: (c) => c.repeat(reverse: true),
                            )
                                .moveY(
                              begin: 0,
                              end: -10,
                              duration: 2.seconds,
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              "Create Parent PIN",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              "Create a secure 4-digit PIN to protect the Parent Dashboard.\nOnly the parent or guardian should know this PIN.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 30),

                            Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),

                              child: Padding(
                                padding: const EdgeInsets.all(20),

                                child: Column(
                                  children: [

                                    TextField(
                                      controller: pinController,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      obscureText: true,
                                      maxLength: 4,

                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],

                                      buildCounter: (
                                          context, {
                                            required currentLength,
                                            required isFocused,
                                            required maxLength,
                                          }) =>
                                      null,

                                      decoration: InputDecoration(
                                        labelText: "Enter PIN",
                                        prefixIcon: const Icon(
                                          Icons.lock,
                                          color: Colors.deepPurple,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(18),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    TextField(
                                      controller: confirmPinController,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.done,
                                      obscureText: true,
                                      maxLength: 4,

                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],

                                      buildCounter: (
                                          context, {
                                            required currentLength,
                                            required isFocused,
                                            required maxLength,
                                          }) =>
                                      null,

                                      decoration: InputDecoration(
                                        labelText: "Confirm PIN",
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                          color: Colors.deepPurple,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(18),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 25),

                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,

                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(16),
                                          ),
                                        ),

                                        onPressed:
                                        loading ? null : savePin,

                                        child: loading
                                            ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child:
                                          CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Colors.white,
                                          ),
                                        )
                                            : const Text(
                                          "Save PIN",
                                          style: TextStyle(
                                            fontSize: 18,
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

                            const Spacer(),

                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

      ),
        ),
    );
  }

}