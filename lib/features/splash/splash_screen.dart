import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/session_service.dart';
import '../security/pin_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  final AudioPlayer player = AudioPlayer();

  double progress = 0;

  String message =
      "Welcome to SensiBuddy";

  @override
  void initState() {

    super.initState();

    speakWelcome();

    startAnimation();
  }

  Future<void> speakWelcome() async {

    await player.play(
      AssetSource("audio/splash_voice.mp3"),
    );

    await player.onPlayerComplete.first;

    await checkSetup();
  }

  Future<void> startAnimation() async {

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    setState(() {
      progress = 0.15;
      message = " Hiiii, My Friend!";
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      progress = 0.35;
      message = " Welcome to SensiBuddy!";
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      progress = 0.55;
      message = " I'm Buddy,\nYour New Best Friend!";
    });

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    setState(() {
      progress = 0.80;
      message = " Let's Play,\nLearn & Smile Together!";
    });

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    setState(() {
      progress = 1.0;
      message = " Ready?\nLet's Go!";
    });
  }

  Future<void> checkSetup() async {

    final loggedIn = await sessionService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {

      final guardianId =
      await sessionService.getGuardianId();

      if (guardianId == null) {

        await sessionService.clearSession();

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          '/welcome',
        );

        return;
      }

      final guardian =
      await firestoreService.getGuardianById(
        guardianId,
      );

      if (guardian == null) {

        await sessionService.clearSession();

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          '/welcome',
        );

        return;
      }

      if (!mounted) return;

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) => PinLoginScreen(
            guardianId: guardian.id,
          ),

        ),

      );

    } else {

      Navigator.pushReplacementNamed(
        context,
        '/welcome',
      );

    }

  }



  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      body: Container(

        decoration:
        const BoxDecoration(
          gradient:
          LinearGradient(
            begin:
            Alignment.topCenter,
            end:
            Alignment.bottomCenter,
            colors: [
              Color(
                0xFFEDE7F6,
              ),
              Color(
                0xFFD1C4E9,
              ),
            ],
          ),
        ),

        child: Center(
          child: Padding(
            padding:
            const EdgeInsets.all(
              24,
            ),

            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,

              children: [

                Image.asset(
                  "assets/images/mascot.png",
                  height: 220,
                )
                    .animate(
                  onPlay:
                      (controller) =>
                      controller
                          .repeat(
                        reverse:
                        true,
                      ),
                )
                    .moveY(
                  begin: 0,
                  end: -12,
                  duration:
                  2.seconds,
                )
                    .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                  duration: 2.seconds,
                ),



                const SizedBox(
                  height: 20,
                ),

                const Text(
                  "SensiBuddy",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    Colors.black87,
                  ),
                )
                    .animate()
                    .fadeIn(),

                const SizedBox(
                  height: 15,
                ),

                Text(
                  message,
                  textAlign:
                  TextAlign.center,
                  style:
                  const TextStyle(
                    fontSize: 18,
                    color:
                    Colors.black54,
                  ),
                )
                    .animate()
                    .fadeIn(),

                const SizedBox(
                  height: 40,
                ),

                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                  child:
                  LinearProgressIndicator(
                    value:
                    progress,
                    minHeight: 10,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                Column(
                  children: [

                    Text(
                      "${(progress * 100).toInt()}%",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Loading...",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),

                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}