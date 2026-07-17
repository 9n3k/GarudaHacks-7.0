import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  final AudioRecorder recorder = AudioRecorder();

  StreamSubscription<Uint8List>? subscription;

  Future<bool> requestPermission() async {
    var status = await Permission.microphone.request();

    return status.isGranted;
  }

  Future<void> startListening(Function(Float32List audio) onAudio) async {
    bool allowed = await requestPermission();

    if (!allowed) {
      print("Microphone permission denied");
      return;
    }

    final stream = await recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );

    List<int> buffer = [];

    subscription = stream.listen((data) {
      buffer.addAll(data);

      // PCM16:
      // 16000 samples/sec
      // YAMNet needs 0.975 sec

      if (buffer.length >= 31200) {
        Uint8List bytes = Uint8List.fromList(buffer.sublist(0, 31200));

        buffer.clear();

        Float32List audio = convertPCM16(bytes);

        onAudio(audio);
      }
    });
  }

  Float32List convertPCM16(Uint8List bytes) {
    Float32List result = Float32List(bytes.length ~/ 2);

    ByteData data = ByteData.view(bytes.buffer);

    for (int i = 0; i < result.length; i++) {
      int value = data.getInt16(i * 2, Endian.little);

      result[i] = value / 32768.0;
    }

    return result;
  }

  Future<void> stopListening() async {
    await subscription?.cancel();

    await recorder.stop();
  }
}
