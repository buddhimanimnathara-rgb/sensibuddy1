import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/guardian_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/session_service.dart';
import '../home/home_screen.dart';

class PinLoginScreen extends StatefulWidget {
  final String guardianId;

  const PinLoginScreen({
    super.key,
    required this.guardianId,
  });

  @override
  State<PinLoginScreen> createState() =>
      _PinLoginScreenState();
}

class _PinLoginScreenState
    extends State<PinLoginScreen> {

  final pinController =
  TextEditingController();

  final FocusNode pinFocusNode = FocusNode();

  bool loading = false;

  bool hidePin = true;

  GuardianModel? guardian;

  bool loadingGuardian = true;

  Future<void> login() async {

    FocusScope.of(context).unfocus();

    if (pinController.text.length != 4 ||
        int.tryParse(pinController.text) == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Please enter a valid 4-digit PIN.",
          ),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {

      final doc = await firestoreService.getParentPin(
        widget.guardianId,
      );

      if (doc == null) {

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Parent PIN not found.",
            ),
          ),
        );

        return;
      }

      if (doc["pin"] == pinController.text) {

        final guardian =
        await firestoreService.getGuardian(
          widget.guardianId,
        );

        if (guardian == null) {
          throw Exception("Guardian not found.");
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Login successful.",
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              guardianId: widget.guardianId,
              childId: guardian.childId,
            ),
          ),
        );

      } else {

        pinController.clear();
        setState(() {});

        pinFocusNode.requestFocus();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Incorrect PIN. Please try again.",
            ),
          ),
        );
      }

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Login failed.\n$e",
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
  void initState() {
    super.initState();
    loadGuardian();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      pinFocusNode.requestFocus();

    });
  }

  @override
  void dispose() {

    pinController.dispose();

    pinFocusNode.dispose();

    super.dispose();

  }

  Future<void> loadGuardian() async {

    guardian =
    await firestoreService.getGuardian(
      widget.guardianId,
    );

    if (mounted) {
      setState(() {
        loadingGuardian = false;
      });
    }

  }

  Widget buildPinDots() {

    return Row(

      mainAxisAlignment: MainAxisAlignment.center,

      children: List.generate(4, (index) {

        final filled = index < pinController.text.length;

        return AnimatedContainer(

          duration: const Duration(milliseconds: 200),

          margin: const EdgeInsets.symmetric(horizontal: 8),

          width: 18,

          height: 18,

          decoration: BoxDecoration(

            shape: BoxShape.circle,

            color: filled
                ? Colors.deepPurple
                : Colors.white,

            border: Border.all(
              color: Colors.deepPurple,
              width: 2,
            ),

          ),

        );

      }),

    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF7F3FF),

      appBar: AppBar(
        title: const Text("Parent Login"),
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

                        if (loadingGuardian)
                          const CircularProgressIndicator()

                        else ...[

                          Text(
                            "Welcome Back 👋",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            guardian!.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            guardian!.email,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),

                        ],

                        const SizedBox(height: 20),

                        const Text(
                          "Parent Login",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Enter your secure 4-digit Parent PIN\nto access the Parent Dashboard.",
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

                                Column(

                                  children: [

                                    GestureDetector(

                                      onTap: () {

                                        pinFocusNode.requestFocus();

                                      },

                                      child: buildPinDots(),

                                    ),

                                    const SizedBox(height: 20),

                                    SizedBox(

                                      width: 1,

                                      height: 1,

                                      child: TextField(

                                        controller: pinController,

                                        focusNode: pinFocusNode,

                                        keyboardType: TextInputType.number,

                                        maxLength: 4,

                                        obscureText: true,

                                        autofocus: true,

                                        inputFormatters: [

                                          FilteringTextInputFormatter.digitsOnly,

                                        ],

                                        buildCounter: (

                                            context, {

                                              required currentLength,

                                              required isFocused,

                                              required maxLength,

                                            }) => null,

                                        onChanged: (value) {

                                          setState(() {});

                                          if (value.length == 4) {

                                            login();

                                          }

                                        },

                                        decoration: const InputDecoration(

                                          border: InputBorder.none,

                                        ),

                                      ),

                                    ),

                                  ],

                                ),

                                const SizedBox(height: 30),

                                SizedBox(
                                  width: double.infinity,
                                  height: 55,

                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      Colors.deepPurple,
                                      foregroundColor:
                                      Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(16),
                                      ),
                                    ),

                                    onPressed:
                                    loading ? null : login,

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
                                      "Login",
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

                        const SizedBox(height: 15),

                        TextButton(

                          onPressed: () {

                            Navigator.pushNamed(
                              context,
                              '/forgot-pin',
                            );

                          },

                          child: const Text(
                            "Forgot PIN?",
                          ),

                        ),

                        TextButton(

                          onPressed: () async {

                            await authService.logout();

                            await sessionService.clearSession();

                            if (!context.mounted) return;

                            Navigator.pushNamedAndRemoveUntil(

                              context,

                              '/login',

                                  (route) => false,

                            );

                          },

                          child: const Text(
                            "Use Another Account",
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