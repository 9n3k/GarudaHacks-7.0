import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class DeniedPage extends StatelessWidget {
  const DeniedPage({super.key});

  Future<void> retryMicrophone(BuildContext context) async {
    PermissionStatus permission = await Permission.microphone.status;

    // Request popup
    if (!permission.isGranted) {
      permission = await Permission.microphone.request();
    }

    if (permission.isGranted) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, "/streetmode");
      }
    } else if (permission.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Microphone permission is required for AI vehicle detection.",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCFCFA),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),

            child: Column(
              children: [
                const SizedBox(height: 20),

                // ICON
                Container(
                  width: 115,

                  height: 115,

                  decoration: BoxDecoration(
                    color: const Color(0xffffeeee),

                    borderRadius: BorderRadius.circular(35),
                  ),

                  child: const Center(
                    child: Text("🎙️", style: TextStyle(fontSize: 60)),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  "Microphone\nAccess Needed",

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 32,

                    height: 1.1,

                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "WaspadaOjol uses AI audio detection to recognize approaching vehicles and provide instant safety warnings.",

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.grey,

                    fontSize: 15,

                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                // SYSTEM CARD
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(28),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .07),

                        blurRadius: 20,

                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Row(
                        children: [
                          Text("🛡️", style: TextStyle(fontSize: 25)),

                          SizedBox(width: 10),

                          Text(
                            "AI Safety System",

                            style: TextStyle(
                              fontSize: 18,

                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      feature("🚗", "Detect nearby vehicle sounds"),

                      feature("🤖", "Analyze audio with YAMNet AI"),

                      feature("🔊", "Play instant danger warnings"),

                      feature("📳", "Provide vibration alerts"),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ALLOW BUTTON
                GestureDetector(
                  onTap: () {
                    retryMicrophone(context);
                  },

                  child: Container(
                    width: double.infinity,

                    padding: const EdgeInsets.symmetric(vertical: 18),

                    decoration: BoxDecoration(
                      color: const Color(0xff197A43),

                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: const Text(
                      "🎙️ Enable Microphone",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 18,

                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // BACK BUTTON
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },

                  child: Container(
                    width: double.infinity,

                    padding: const EdgeInsets.symmetric(vertical: 18),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(22),

                      border: Border.all(color: Colors.grey.shade300),
                    ),

                    child: const Text(
                      "← Back Home",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 16,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget feature(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,

              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
