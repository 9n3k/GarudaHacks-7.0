import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:csv/csv.dart';

class YamnetService {
  Interpreter? interpreter;

  final List<String> labels = [];

  bool loaded = false;

  final Map<String, double> weights = {
    "Vehicle": 1.0,
    "Motor vehicle (road)": 1.0,
    "Motorcycle": 1.0,
    "Car": 0.8,
    "Car passing by": 1.2,
    "Truck": 1.0,
    "Bus": 0.8,
    "Traffic noise, roadway noise": 0.3,
    "Vehicle horn, car horn, honking": 0.8,
  };

  Future<void> loadModel() async {
    if (loaded) return;

    interpreter = await Interpreter.fromAsset("assets/models/yamnet.tflite");

    String csv = await rootBundle.loadString(
      "assets/models/yamnet_class_map.csv",
    );

    var rows = const CsvToListConverter().convert(csv);

    for (int i = 1; i < rows.length; i++) {
      labels.add(rows[i][2].toString());
    }

    loaded = true;

    print("YAMNet loaded");
  }

  // ==========================
  // RUN WAV FILE
  // ==========================

  Future<String> detectWav(String path) async {
    ByteData bytes = await rootBundle.load(path);

    Uint8List wav = bytes.buffer.asUint8List();

    // Skip WAV header (usually 44 bytes)

    Uint8List pcmBytes = wav.sublist(44);

    Float32List audio = Float32List(pcmBytes.length ~/ 2);

    ByteData pcm = ByteData.sublistView(pcmBytes);

    for (int i = 0; i < audio.length; i++) {
      int sample = pcm.getInt16(i * 2, Endian.little);

      audio[i] = sample / 32768.0;
    }

    return detect(audio);
  }

  String detect(Float32List audio) {
    if (!loaded || interpreter == null) {
      return "SAFE";
    }

    Float32List inputAudio = prepareAudio(audio);

    var input = [inputAudio];

    var output = [List<double>.filled(521, 0)];

    interpreter!.run(input, output);

    double sum = 0;

    for (double x in audio) {
      sum += x * x;
    }

    double rms = sqrt(sum / audio.length);

    double vehicleScore = 0;

    int vehicleClasses = 0;

    List<MapEntry<String, double>> detected = [];

    for (int i = 0; i < labels.length; i++) {
      String label = labels[i];

      if (weights.containsKey(label)) {
        double confidence = output[0][i];

        if (confidence > 0.05) {
          detected.add(MapEntry(label, confidence));

          vehicleScore += confidence * weights[label]!;

          vehicleClasses++;

          print("$label ${(confidence * 100).toStringAsFixed(1)}%");
        }
      }
    }

    double threat = 0;

    threat += (vehicleScore * 40).clamp(0, 50);

    threat += (rms * 100).clamp(0, 20);

    if (vehicleClasses >= 3) {
      threat += 15;
    } else if (vehicleClasses == 2) {
      threat += 10;
    } else if (vehicleClasses == 1) {
      threat += 5;
    }

    if (detected.any((x) => x.key == "Vehicle horn, car horn, honking")) {
      threat += 15;
    }

    print("----------------");
    print("Vehicle score $vehicleScore");
    print("RMS $rms");
    print("Threat $threat");

    if (threat >= 30) {
      return "ALERT";
    }

    if (threat >= 15) {
      return "WARNING";
    }

    return "SAFE";
  }

  Float32List prepareAudio(Float32List audio) {
    const samples = 15600;

    Float32List result = Float32List(samples);

    int length = min(audio.length, samples);

    result.setRange(0, length, audio.sublist(0, length));

    return result;
  }

  void dispose() {
    interpreter?.close();
  }
}
