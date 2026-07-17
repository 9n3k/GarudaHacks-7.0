import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';
import 'notification_service.dart';

class WarningPage extends StatefulWidget {
  const WarningPage({super.key});

  @override
  State<WarningPage> createState() => _WarningPageState();
}

class _WarningPageState extends State<WarningPage>
    with TickerProviderStateMixin {
  final AudioPlayer player = AudioPlayer();

  late AnimationController radarController;

  bool closed = false;

  @override
  void initState() {
    super.initState();

    radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    startWarning();
  }

  Future<void> startWarning() async {
    await player.setReleaseMode(ReleaseMode.loop);

    await player.play(AssetSource("warning.mp3"));

    await activateVibration();

    await NotificationService.dangerNotification();
  }

  Future<void> activateVibration() async {
    HapticFeedback.vibrate();

    await Future.delayed(const Duration(milliseconds: 300));

    HapticFeedback.heavyImpact();

    await Future.delayed(const Duration(milliseconds: 300));

    HapticFeedback.heavyImpact();
  }

  Future<void> closeWarning() async {
    if (closed) return;

    closed = true;

    await player.stop();

    Vibration.cancel();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    radarController.dispose();

    player.dispose();

    Vibration.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff120000),

      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,

                  end: Alignment.bottomCenter,

                  colors: [Color(0xff8B0000), Color(0xff120000)],
                ),
              ),
            ),

            Positioned(
              top: 25,

              right: 25,

              child: GestureDetector(
                onTap: closeWarning,

                child: Container(
                  width: 55,

                  height: 55,

                  decoration: BoxDecoration(
                    color: Colors.white,

                    shape: BoxShape.circle,
                  ),

                  child: const Icon(Icons.close, color: Colors.red, size: 30),
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text(
                    "⚠️ WARNING",

                    style: TextStyle(
                      color: Colors.white,

                      fontSize: 38,

                      fontWeight: FontWeight.w900,

                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "VEHICLE APPROACHING",

                    style: TextStyle(
                      color: Color(0xffffd54f),

                      fontSize: 24,

                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 35),

                  radar(),

                  const SizedBox(height: 35),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),

                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: const Text(
                      "CHECK YOUR SURROUNDINGS\nAND MOVE TO SAFETY",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 18,

                        fontWeight: FontWeight.w800,

                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget radar() {
    return SizedBox(
      width: 280,

      height: 280,

      child: Stack(
        alignment: Alignment.center,

        children: [
          pulseWave(0),

          pulseWave(600),

          pulseWave(1200),

          Container(
            width: 130,

            height: 130,

            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: .25),

              shape: BoxShape.circle,
            ),

            child: const Center(
              child: Text("🚗", style: TextStyle(fontSize: 70)),
            ),
          ),
        ],
      ),
    );
  }

  Widget pulseWave(int delay) {
    return AnimatedBuilder(
      animation: radarController,

      builder: (context, child) {
        double value = (radarController.value + delay / 2000) % 1;

        return Container(
          width: 150 + value * 150,

          height: 150 + value * 150,

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            border: Border.all(
              color: Colors.red.withValues(alpha: 1 - value),

              width: 6,
            ),
          ),
        );
      },
    );
  }
}
