import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  final _formKey =
  GlobalKey<FormState>();

  final emailController =
  TextEditingController();

  bool loading = false;

  @override
  void dispose() {

    emailController.dispose();

    super.dispose();

  }

  Future<void> resetPassword() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {

      await authService.forgotPassword(
        emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Password reset link has been sent to your email.",
          ),
        ),

      );

      Navigator.pop(context);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString()),
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

      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(

        child: Form(

          key: _formKey,

          child: Padding(

            padding: const EdgeInsets.all(24),

            child: Column(

              mainAxisAlignment:
              MainAxisAlignment.center,

              children: [

                const Icon(
                  Icons.lock_reset,
                  size: 100,
                  color: Colors.deepPurple,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Enter your registered email address.",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                TextFormField(

                  controller:
                  emailController,

                  keyboardType:
                  TextInputType.emailAddress,

                  decoration:
                  InputDecoration(

                    labelText:
                    "Email Address",

                    prefixIcon:
                    const Icon(Icons.email),

                    border:
                    OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(15),

                    ),

                  ),

                  validator: (value) {

                    if (value == null ||
                        value.isEmpty) {

                      return "Enter email";

                    }

                    return null;

                  },

                ),

                const SizedBox(height: 25),

                SizedBox(

                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(

                    onPressed:
                    loading
                        ? null
                        : resetPassword,

                    style:
                    ElevatedButton.styleFrom(

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
                      "Send Reset Link",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),

                  ),

                ),

              ],

            ),

          ),

        ),

      ),

    );

  }

}