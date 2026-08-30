import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../features/face/guardian_face_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String childId;
  final String guardianName;
  final String email;
  final String phone;
  final String relationship;

  const EmailVerificationScreen({
    super.key,
    required this.childId,
    required this.guardianName,
    required this.email,
    required this.phone,
    required this.relationship,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends State<EmailVerificationScreen> {
  bool loading = false;

  Future<void> checkVerification() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    try {
      await authService.reloadUser();

      if (!authService.isEmailVerified()) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Your email has not been verified yet.",
            ),
          ),
        );

        return;
      }

      final guardianId =
      await firestoreService.saveGuardian({
        "childId": widget.childId,
        "name": widget.guardianName,
        "email": widget.email,
        "phone": widget.phone,
        "relationship": widget.relationship,
        "emailVerified": true,
        "createdAt": DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Email verified successfully.",
          ),
        ),
      );

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GuardianFaceScreen(
            childId: widget.childId,
            guardianId: guardianId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
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

  Future<void> resendEmail() async {
    if (loading) return;

    try {
      await authService.sendVerificationEmail();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
          content: Text(
            "Verification email sent again.\n"
                "Please check your Inbox or Spam folder.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight =
        MediaQuery.of(context).size.height;

    final isSmallScreen = screenHeight < 650;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        title: const Text(
          "Verify Email",
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics:
              const BouncingScrollPhysics(),

              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,

              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical:
                isSmallScreen ? 20 : 32,
              ),

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                  constraints.maxHeight -
                      (isSmallScreen
                          ? 40
                          : 64),
                ),

                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                    children: [

                      Center(
                        child: Icon(
                          Icons.mark_email_read,
                          size:
                          isSmallScreen
                              ? 75
                              : 100,
                          color:
                          Colors.deepPurple,
                        ),
                      ),

                      SizedBox(
                        height:
                        isSmallScreen
                            ? 16
                            : 25,
                      ),

                      const Text(
                        "Verification Email Sent",

                        textAlign:
                        TextAlign.center,

                        style: TextStyle(
                          fontSize: 28,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      Container(
                        padding:
                        const EdgeInsets.all(14),

                        decoration:
                        BoxDecoration(
                          color:
                          Colors.deepPurple
                              .withValues(
                            alpha: 0.08,
                          ),

                          borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                        ),

                        child: Text(
                          widget.email,

                          textAlign:
                          TextAlign.center,

                          overflow:
                          TextOverflow.visible,

                          style:
                          const TextStyle(
                            fontSize: 17,
                            color:
                            Colors.deepPurple,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(
                        height:
                        isSmallScreen
                            ? 18
                            : 25,
                      ),

                      const Text(
                        "We have sent a verification "
                            "link to your email.\n\n"
                            "1. Open your Inbox.\n"
                            "2. If you don't see it, check "
                            "your Spam/Junk folder.\n"
                            "3. Click the verification link.\n"
                            "4. Return to SensiBuddy and tap "
                            "the button below.",

                        textAlign:
                        TextAlign.center,

                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(
                        height:
                        isSmallScreen
                            ? 16
                            : 24,
                      ),

                      Center(
                        child: TextButton.icon(
                          onPressed:
                          loading
                              ? null
                              : resendEmail,

                          icon: const Icon(
                            Icons.refresh,
                          ),

                          label: const Text(
                            "Resend Verification Email",
                          ),
                        ),
                      ),

                      SizedBox(
                        height:
                        isSmallScreen
                            ? 20
                            : 35,
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: ElevatedButton(
                          onPressed:
                          loading
                              ? null
                              : checkVerification,

                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            Colors.deepPurple,

                            foregroundColor:
                            Colors.white,

                            disabledBackgroundColor:
                            Colors.deepPurple
                                .withValues(
                              alpha: 0.6,
                            ),

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                14,
                              ),
                            ),
                          ),

                          child: loading
                              ? const SizedBox(
                            width: 24,
                            height: 24,

                            child:
                            CircularProgressIndicator(
                              strokeWidth: 3,
                              color:
                              Colors.white,
                            ),
                          )
                              : const Text(
                            "I've Verified My Email",

                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}