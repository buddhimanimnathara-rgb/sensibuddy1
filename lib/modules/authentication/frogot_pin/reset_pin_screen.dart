import 'package:flutter/material.dart';

import '../../../core/services/firestore_service.dart';
import '../../../features/security/pin_login_screen.dart';

class ResetPinScreen extends StatefulWidget {
  final String guardianId;

  const ResetPinScreen({
    super.key,
    required this.guardianId,
  });

  @override
  State<ResetPinScreen> createState() =>
      _ResetPinScreenState();
}

class _ResetPinScreenState
    extends State<ResetPinScreen> {

  final _formKey = GlobalKey<FormState>();

  final pinController =
  TextEditingController();

  final confirmPinController =
  TextEditingController();

  bool loading = false;
  bool hidePin = true;
  bool hideConfirmPin = true;

  @override
  void dispose() {

    pinController.dispose();

    confirmPinController.dispose();

    super.dispose();

  }

  Future<void> savePin() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (pinController.text !=
        confirmPinController.text) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          backgroundColor: Colors.red,

          content: Text(
            "PINs do not match.",
          ),

        ),

      );

      return;

    }

    setState(() {

      loading = true;

    });

    try {

      await firestoreService.updateParentPin(
        guardianId: widget.guardianId,
        newPin: pinController.text.trim(),
      );

      if (!mounted) return;

      showDialog(

        context: context,

        barrierDismissible: false,

        builder: (_) {

          return AlertDialog(

            title: const Text(
              "Success",
            ),

            content: const Text(
              "Parent PIN updated successfully.",
            ),

            actions: [

              ElevatedButton(

                onPressed: () {

                  Navigator.pushAndRemoveUntil(

                    context,

                    MaterialPageRoute(

                      builder: (_) => PinLoginScreen(

                        guardianId:
                        widget.guardianId,

                      ),

                    ),

                        (route) => false,

                  );

                },

                child: const Text(
                  "OK",
                ),

              ),

            ],

          );

        },

      );

    }

    catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          backgroundColor: Colors.red,

          content: Text(
            e.toString(),
          ),

        ),

      );

    }

    if (mounted) {

      setState(() {

        loading = false;

      });

    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        title: const Text("Create New PIN"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const SizedBox(height: 20),

                const Icon(
                  Icons.lock_reset,
                  size: 100,
                  color: Colors.deepPurple,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Create New Parent PIN",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Create a new secure 4-digit PIN.",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  obscureText: hidePin,
                  maxLength: 4,

                  decoration: InputDecoration(
                    labelText: "New PIN",

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePin
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePin = !hidePin;
                        });
                      },
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.length != 4) {
                      return "Enter 4-digit PIN";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: confirmPinController,
                  keyboardType: TextInputType.number,
                  obscureText: hideConfirmPin,
                  maxLength: 4,

                  decoration: InputDecoration(
                    labelText: "Confirm PIN",

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        hideConfirmPin
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          hideConfirmPin =
                          !hideConfirmPin;
                        });
                      },
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.length != 4) {
                      return "Confirm your PIN";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : savePin,

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Colors.deepPurple,
                      foregroundColor:
                      Colors.white,
                    ),

                    child: loading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      "Save PIN",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

              ],
            ),
          ),
        ),
      ),
    );
  }



}