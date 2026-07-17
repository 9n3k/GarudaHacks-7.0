import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:vibration/vibration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

import 'denied.dart';
import 'warning.dart';
import 'yamnet_service.dart';

class StreetMode extends StatefulWidget {
  const StreetMode({super.key});

  @override
  State<StreetMode> createState() => _StreetModeState();
}

class _StreetModeState extends State<StreetMode> {
  // ==========================
  // VARIABLES
  // ==========================

  Timer? timer;

  StreamSubscription<Uint8List>? audioSubscription;

  int seconds = 0;

  int warningCount = 0;

  bool micActive = false;

  bool warningActive = false;

  bool modelReady = false;

  String status = "✅ Safe";

  final AudioRecorder recorder = AudioRecorder();

  final AudioPlayer player = AudioPlayer();

  final YamnetService yamnet = YamnetService();

  List<int> audioBuffer = [];

  // detection stability

  int dangerHits = 0;

  DateTime? lastWarningTime;

  // ==========================
  // START
  // ==========================

  @override
  void initState() {
    super.initState();

    Future<void> startSession() async {
      startTimer();

      try {
        await yamnet.loadModel();

        modelReady = true;

        debugPrint("YAMNet loaded");
      } catch (e) {
        debugPrint("Model error: $e");
      }

      bool allowed = await activateMicrophone();

      if (!allowed) {
        return;
      }
    }

    startSession();
  }

  Future<void> testCarAudio() async {
    debugPrint("DIRECT TEST WARNING");

    await player.play(AssetSource("approachingcar.wav"));

    await Future.delayed(const Duration(milliseconds: 500));

    lastWarningTime = null; // remove cooldown

    await triggerWarning();
  }

  // ==========================
  // TIMER
  // ==========================

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        seconds++;
      });
    });
  }

  // ==========================
  // MICROPHONE
  // ==========================

  Future<bool> activateMicrophone() async {
    PermissionStatus permission = await Permission.microphone.request();

    if (!permission.isGranted) {
      if (mounted) {
        Navigator.pushReplacement(
          context,

          MaterialPageRoute(builder: (_) => const DeniedPage()),
        );
      }

      return false;
    }

    setState(() {
      micActive = true;
    });

    await startMicrophoneStream();

    return true;
  }

  Future<void> startMicrophoneStream() async {
    final stream = await recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,

        sampleRate: 16000,

        numChannels: 1,
      ),
    );

    audioSubscription = stream.listen((data) {
      audioBuffer.addAll(data);

      // YAMNet:
      // 16000 samples
      // PCM16 = 32000 bytes

      if (audioBuffer.length >= 32000) {
        processAudio();

        // 50% overlap

        audioBuffer = audioBuffer.sublist(16000);
      }
    });
  }

  // ==========================
  // YAMNET
  // ==========================
  void processAudio() {
    if (!modelReady) {
      return;
    }

    try {
      Float32List audio = convertPCM(audioBuffer);

      String result = yamnet.detect(audio);

      debugPrint("YAMNet result: $result");

      // TEMP DEMO MODE
      if (result == "ALERT" || result == "WARNING") {
        triggerWarning();
      }
    } catch (e) {
      debugPrint("YAMNet processing error: $e");
    }
  }
  // Require 2 consecutive detections

  Future<void> testYamnet() async {
    debugPrint("TEST AUDIO START");

    ByteData data = await rootBundle.load("assets/approachingcar.wav");

    Uint8List bytes = data.buffer.asUint8List();

    List<int> pcmBytes = bytes.sublist(44);

    Float32List audio = convertPCM(pcmBytes);

    String result = yamnet.detect(audio);

    debugPrint("TEST RESULT: $result");

    if (result == "ALERT" || result == "WARNING") {
      triggerWarning();
    }
  }

  Float32List convertPCM(List<int> data) {
    Float32List audio = Float32List(data.length ~/ 2);

    ByteData bytes = ByteData.sublistView(Uint8List.fromList(data));

    for (int i = 0; i < audio.length; i++) {
      int sample = bytes.getInt16(i * 2, Endian.little);

      audio[i] = sample / 32768.0;
    }

    return audio;
  }

  // ==========================
  // WARNING
  // ==========================

  Future<void> triggerWarning() async {
    if (lastWarningTime != null) {
      if (DateTime.now().difference(lastWarningTime!).inSeconds < 5) {
        return;
      }
    }

    lastWarningTime = DateTime.now();

    if (!mounted) {
      return;
    }

    setState(() {
      warningActive = true;

      warningCount++;

      status = "⚠️ Warning";
    });

    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 1500, 300, 1500]);
    }

    await player.play(AssetSource("warning.mp3"));

    if (mounted) {
      await Navigator.push(
        context,

        MaterialPageRoute(builder: (_) => const WarningPage()),
      );

      if (mounted) {
        setState(() {
          warningActive = false;

          status = "✅ Safe";
        });
      }
    }
  }

  Widget header() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: const BoxDecoration(
        color: Color(0xff197A43),

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Text("🏍️", style: TextStyle(fontSize: 35)),

              const SizedBox(width: 12),

              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "WaspadaOjol",

                    style: TextStyle(
                      color: Colors.white,

                      fontSize: 24,

                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  Text(
                    "STREET MODE",

                    style: TextStyle(
                      color: Colors.white70,

                      letterSpacing: 3,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              IconButton(
                onPressed: stopSession,

                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Text(
            warningActive
                ? "🔴 VEHICLE THREAT DETECTED"
                : "🟢 AI IS MONITORING AUDIO",

            style: TextStyle(
              color: warningActive ? Colors.redAccent : Colors.white,

              fontWeight: FontWeight.w900,

              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // STOP SESSION
  // ==========================

  Future<void> stopSession() async {
    timer?.cancel();

    await audioSubscription?.cancel();

    if (await recorder.isRecording()) {
      await recorder.stop();
    }

    await player.stop();

    await saveSession();

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  // ==========================
  // SAVE SESSION
  // ==========================

  Future<void> saveSession() async {
    final prefs = await SharedPreferences.getInstance();

    String result;

    String message;

    if (warningCount == 0) {
      result = "Good";

      message = "Nicely done! You stayed aware!";
    } else if (warningCount <= 3) {
      result = "Okay";

      message = "Decent walk. Stay sharper next time!";
    } else {
      result = "Bad";

      message = "Many warnings detected.";
    }

    Map<String, dynamic> session = {
      "duration": "${seconds ~/ 60}m ${seconds % 60}s",

      "warnings": warningCount,

      "result": result,

      "message": message,

      "date": DateTime.now().toString(),
    };

    await prefs.setString("lastWalk", jsonEncode(session));

    debugPrint("Saved session: $session");
  }

  Widget scanningCard() {
    return Container(
      margin: const EdgeInsets.all(22),

      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(25),
      ),

      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),

            width: 100,

            height: 100,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: warningActive ? Colors.red : const Color(0xff197A43),
            ),

            child: Center(
              child: Text(
                warningActive ? "⚠️" : "🎙️",

                style: const TextStyle(fontSize: 45),
              ),
            ),
          ),

          const SizedBox(height: 25),

          Text(
            warningActive ? "DANGER DETECTED" : "SYSTEM SCANNING",

            style: TextStyle(
              color: warningActive ? Colors.red : const Color(0xff197A43),

              fontSize: 20,

              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              const Text("🎙️", style: TextStyle(fontSize: 25)),

              const SizedBox(width: 12),

              const Text(
                "Microphone",

                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const Spacer(),

              Text(
                micActive ? "LIVE" : "OFF",

                style: TextStyle(
                  color: micActive ? Colors.green : Colors.red,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================
  // UI
  // ==========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCFCFA),

      body: SafeArea(
        child: Column(
          children: [
            header(),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [scanningCard(), sessionCard(), testButton()],
                ),
              ),
            ),

            stopButton(),
          ],
        ),
      ),
    );
  }

  Widget sessionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(25),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [
          stat("⏱️", "${seconds}s", "TIME"),

          stat("⚠️", "$warningCount", "WARNINGS"),

          stat("📡", status, "STATUS"),
        ],
      ),
    );
  }

  Widget stat(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 25)),

        const SizedBox(height: 6),

        Text(
          value,

          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),

        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget testButton() {
    return GestureDetector(
      onTap: testCarAudio,

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 22),

        height: 60,

        decoration: BoxDecoration(
          color: Colors.orange,

          borderRadius: BorderRadius.circular(20),
        ),

        child: const Center(
          child: Text(
            "🚗 TEST CAR AUDIO",

            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget stopButton() {
    return GestureDetector(
      onTap: stopSession,

      child: Container(
        margin: const EdgeInsets.all(22),

        height: 70,

        width: double.infinity,

        decoration: BoxDecoration(
          color: const Color(0xffEF3030),

          borderRadius: BorderRadius.circular(25),
        ),

        child: const Center(
          child: Text(
            "🛑 STOP & SAVE SESSION",

            style: TextStyle(
              color: Colors.white,

              fontSize: 19,

              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();

    audioSubscription?.cancel();

    recorder.dispose();

    player.dispose();

    yamnet.dispose();

    super.dispose();
  }
}
