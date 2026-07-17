import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class YamnetService {
  Interpreter? interpreter;

  final List<String> labels = [];

  bool loaded = false;

  final Map<String, double> vehicleWeights = {
    "Vehicle": 1.0,
    "Motor vehicle (road)": 1.0,
    "Motorcycle": 1.2,
    "Car": 0.8,
    "Car passing by": 1.3,
    "Truck": 1.0,
    "Bus": 0.8,
    "Vehicle horn, car horn, honking": 0.8,
  };

  Future<void> loadModel() async {
    if (loaded) return;

    interpreter = await Interpreter.fromAsset("assets/yamnet.tflite");

    String csv = await rootBundle.loadString("assets/yamnet_class_map.csv");

    List<String> rows = csv.split("\n");

    for (int i = 1; i < rows.length; i++) {
      if (rows[i].trim().isEmpty) continue;

      List<String> data = rows[i].split(",");

      if (data.length > 2) {
        labels.add(data[2].replaceAll('"', '').trim());
      }
    }

    loaded = true;

    print("YAMNet loaded: ${labels.length} classes");
  }

  String detect(Float32List audio) {
    if (!loaded || interpreter == null) {
      return "SAFE";
    }

    // YAMNet input = 0.975 sec @ 16kHz

    if (audio.length < 15000) {
      return "SAFE";
    }

    try {
      var input = [audio];

      var output = List.generate(1, (_) => List.filled(521, 0.0));

      interpreter!.run(input, output);

      double dangerScore = 0;

      for (int i = 0; i < labels.length; i++) {
        String label = labels[i];

        if (!vehicleWeights.containsKey(label)) {
          continue;
        }

        double confidence = output[0][i];

        if (confidence > 0.05) {
          dangerScore += confidence * vehicleWeights[label]!;
        }
      }

      double threatLevel = (dangerScore * 40).clamp(0, 100);

      print("Vehicle threat: $threatLevel%");

      if (threatLevel >= 70) {
        return "ALERT";
      }

      if (threatLevel >= 40) {
        return "WARNING";
      }

      return "SAFE";
    } catch (e) {
      print("YAMNet error: $e");

      return "SAFE";
    }
  }

  void dispose() {
    interpreter?.close();
  }
}
