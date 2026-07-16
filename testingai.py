import numpy as np
import tensorflow as tf
import tensorflow_hub as hub
import librosa
import pandas as pd


print("please wait")

model = hub.load("https://tfhub.dev/google/yamnet/1")

print("Yamnet loaded!")

audio, sr = librosa.load(
    "wind.wav",
    sr = 16000
)

rms = np.sqrt(np.mean(audio**2))


scores, embeddings, spectrogram = model(audio)
class_map = pd.read_csv("yamnet_class_map.csv")
scores_mean = scores.numpy().mean(axis=0)

top10 = scores_mean.argsort()[-10:][::-1]

print("\n")
print("WaspadaOjol Audio YAMNET TESTING")
print("Top 10 YAMnet Predictions")
print("\n")

for idx in top10:
    label = class_map.iloc[idx]["display_name"]
    confidence = scores_mean[idx]
    print(f"{label:<32} {confidence*100:6.1f}%")

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

vehicle_score = 0
vehicle_classes = 0
detected = []
print("\n")
print("Vehicle-Related Detected Sounds")
print("\n")

for i, label in enumerate(class_map["display_name"]):
    if label in weights:
        confidence = float(scores_mean[i])

        if confidence > 0.05:
            detected.append((label, confidence))
            vehicle_score += confidence * weights[label]
            vehicle_classes += 1

detected.sort(key=lambda x: x[1], reverse=True)


threat_score = 0
threat_score += min(vehicle_score * 40, 50)
threat_score += min(rms * 100, 20)

if vehicle_classes >= 3:
    threat_score += 15
elif vehicle_classes == 2:
    threat_score += 10
elif vehicle_classes == 1:
    threat_score += 5

if any(label == "Vehicle horn, car horn, honking" for label, _ in detected):
    threat_score += 15


for label, conf in detected:
    print(f"{label:<28}{conf*100:>6.1f}%")


print("")
print("ASSESMENT/REPORT")
print(f"Vehicle score: {vehicle_score:.3f}")
print(f"Loudness (RMS): {rms:.4f}")
print(f"Threat score: {threat_score:.1f}/100")
print("")

print("RESULTS")
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