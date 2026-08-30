import 'package:flutter/material.dart';
import 'package:sensibuddy1/modules/authentication/frogot_pin/reset_pin_screen.dart';

import '../../../core/models/guardian_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';

class ForgotPinScreen extends StatefulWidget {
  const ForgotPinScreen({super.key});

  @override
  State<ForgotPinScreen> createState() =>
      _ForgotPinScreenState();
}

class _ForgotPinScreenState
    extends State<ForgotPinScreen> {

  final _formKey = GlobalKey<FormState>();

  final emailController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  bool loading = false;

  bool hidePassword = true;

  @override
  void dispose() {

    emailController.dispose();

    passwordController.dispose();

    super.dispose();

  }

  Future<void> continueReset() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {

      // Login to Firebase
      await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Find guardian in Firestore
      final GuardianModel? guardian =
      await firestoreService.getGuardianByEmail(
        emailController.text.trim(),
      );

      if (guardian == null) {
        throw Exception("Guardian account not found.");
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPinScreen(
            guardianId: guardian.id,
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString()),
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

      appBar: AppBar(
        title: const Text(
          "Forgot Parent PIN",

        ),
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

                const SizedBox(height: 25),

                const Text(
                  "Forgot Parent PIN",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Enter your registered email and password.\nAfter verification you can create a new PIN.",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter email";
                    }

                    if (!RegExp(
                      r'^[^@]+@[^@]+\.[^@]+$',
                    ).hasMatch(value)) {
                      return "Invalid email";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),

                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return "Enter your password";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/forgot-password',
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: loading ? null : continueReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: loading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      "Continue",
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