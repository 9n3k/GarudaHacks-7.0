import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool hasWalk = false;

  String duration = "-";
  String warnings = "0";
  String result = "Good";
  String feedback = "Start your first safety walk.";

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    animationController.forward();

    loadLastWalk();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<void> loadLastWalk() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getString("lastWalk");

    if (saved == null) return;

    final data = jsonDecode(saved);

    setState(() {
      hasWalk = true;

      duration = data["duration"] ?? "-";

      warnings = (data["warnings"] ?? 0).toString();

      result = data["result"] ?? "Good";

      feedback = data["message"] ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAF8),

      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 25, 22, 120),

              child: Column(
                children: [
                  heroSection(),

                  systemCard(),

                  lastWalkCard(),

                  safetyCard(),
                ],
              ),
            ),

            startButton(),
          ],
        ),
      ),
    );
  }

  Widget heroSection() {
    return FadeTransition(
      opacity: animationController,

      child: Column(
        children: [
          Container(
            height: 90,

            width: 90,

            decoration: BoxDecoration(
              color: const Color(0xff197A43),

              borderRadius: BorderRadius.circular(25),

              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: .2),

                  blurRadius: 25,

                  offset: const Offset(0, 10),
                ),
              ],
            ),

            child: const Center(
              child: Text("🏍️", style: TextStyle(fontSize: 45)),
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            "WaspadaOjol",

            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 5),

          const Text(
            "Stay Alert, Stay Alive",

            style: TextStyle(
              color: Color(0xff197A43),

              fontSize: 17,

              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "🤖 AI Powered Pedestrian Safety",

            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget systemCard() {
    return appCard(
      "⚡ SYSTEM STATUS",

      Column(
        children: [
          statusTile("🛣️", "Street Mode", "Ready", Colors.green),

          statusTile("🎙️", "AI Audio Monitoring", "Standby", Colors.orange),

          statusTile("🧠", "YAMNet Detection", "Connected", Colors.blue),
        ],
      ),
    );
  }

  Widget statusTile(String icon, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 25)),

          const SizedBox(width: 15),

          Expanded(
            child: Text(
              title,

              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),

            decoration: BoxDecoration(
              color: color.withValues(alpha: .15),

              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              value,

              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget appCard(String title, Widget child) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(top: 18),

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(25),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),

            blurRadius: 25,

            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: const TextStyle(
              color: Colors.grey,

              letterSpacing: 2,

              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }

  Widget lastWalkCard() {
    return appCard("🚶 LAST WALK", hasWalk ? walkData() : emptyWalk());
  }

  Widget emptyWalk() {
    return Column(
      children: [
        const Text("🗺️", style: TextStyle(fontSize: 45)),

        const SizedBox(height: 12),

        const Text(
          "No walk recorded",

          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        const Text(
          "Start Street Mode to create your first safety report.",

          textAlign: TextAlign.center,

          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget walkData() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: [
            statBox(duration, "Duration"),

            statBox(warnings, "Warnings"),

            statBox(result, "Result"),
          ],
        ),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            color: const Color(0xfffff5d6),

            borderRadius: BorderRadius.circular(15),
          ),

          child: Text(
            feedback,

            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Color(0xff996f00),

              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget statBox(String value, String label) {
    return Column(
      children: [
        Text(
          value,

          style: const TextStyle(
            fontSize: 22,

            fontWeight: FontWeight.w900,

            color: Color(0xff197A43),
          ),
        ),

        const SizedBox(height: 5),

        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget safetyCard() {
    return appCard(
      "🛡️ SAFETY SYSTEM",

      Column(
        children: [
          safetyItem(
            "📳",

            "Haptic Warning",

            "Strong vibration when danger is detected",
          ),

          safetyItem(
            "🔊",

            "Audio Alert",

            "AI warning through voice notification",
          ),

          safetyItem(
            "🔒",

            "Privacy Protection",

            "Microphone only works during Street Mode",
          ),
        ],
      ),
    );
  }

  Widget safetyItem(String icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 5),

                Text(description, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget startButton() {
    return Positioned(
      bottom: 18,

      left: 18,

      right: 18,

      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.pushNamed(context, "/streetmode");

          if (result == true) {
            loadLastWalk();
          }
        },

        child: Container(
          height: 70,

          decoration: BoxDecoration(
            color: const Color(0xffF7CE4A),

            borderRadius: BorderRadius.circular(25),

            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: .35),

                blurRadius: 30,

                offset: const Offset(0, 12),
              ),
            ],
          ),

          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Text("🚶", style: TextStyle(fontSize: 32)),

              SizedBox(width: 10),

              Text(
                "START STREET MODE",

                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
