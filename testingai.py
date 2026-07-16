import numpy as np
import tensorflow as tf
import tensorflow_hub as hub
import librosa
import pandas as pd


print("please wait")

model = hub.load("https://tfhub.dev/google/yamnet/1")

print("Yamnet loaded!")

audio, sr = librosa.load(
    "test.wav",
    sr = 16000
)

rms = np.sqrt(np.mean(audio**2))
print(f"Audio Loudness: {rms:.4f}")

scores, embeddings, spectrogram = model(audio)
class_map = pd.read_csv("yamnet_class_map.csv")
scores_mean = scores.numpy().mean(axis=0)

weights = {
    "Vehicle": 1.0,
    "Motor vehicle (road)": 1.0,
    "Motorcycle": 1.0,
    "Car": 0.8,
    "Car passing by": 1.2,
    "Truck": 1.0,
    "Bus": 0.8,
    "Traffic noise, roadway noise": 0.3,
    "Vehicle horn, car horn, honking": 0.8,
}

vehicle_classes = 0
detected = []
print("Vehicle related sounds")

for i, label in enumerate(class_map["display_name"]):
    if label in weights:
        confidence = float(scores_mean[i])

        if confidence > 0.05:
            detected.append((label, confidence))
            vehicle_classes += confidence * weights[label]

detected.sort(key=lambda x: x[1], reverse=True)


threat_score = 0
threat_score += min(rms * 100, 20)

if vehicle_classes >= 3:
    threat_score += 15
elif vehicle_classes == 2:
    threat_score += 10
elif vehicle_classes == 1:
    threat_score += 5

    if any(label == "Vehicle horn, car horn, honking" for label, _ in detected):
        threat_score += 15

print("Detected Sounds")
for label, conf in detected:
    print(f"{label:<35}{conf*100:.1f}%")


print("")
print(f"Threat score: {threat_score:.1f}/100")
print("")

if threat_score >= 70:
    print("ALERT")
    print("INCOMING VEHICLE")
elif threat_score >= 40:
    print("WARNING")
    print("VEHICLE NEARBY, CHECK SURROUNDINGS!")
else:
    print("SAFE")
    print("No vehicle treat detected yet.")