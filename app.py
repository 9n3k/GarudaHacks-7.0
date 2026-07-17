from flask import Flask, request, jsonify
from flask_cors import CORS


import numpy as np
import tensorflow_hub as hub
import pandas as pd
import io
print("APP VERSION: PYDUB YAMNET SERVER")
print("FILE:", __file__)

from pydub import AudioSegment

app = Flask(__name__)
CORS(app)


print("Loading YAMNet...")

model = hub.load(
    "https://tfhub.dev/google/yamnet/1"
)

class_map = pd.read_csv(
    "yamnet_class_map.csv"
)

print("YAMNet ready")


weights = {
    "Vehicle":1.0,
    "Motor vehicle (road)":1.0,
    "Motorcycle":1.0,
    "Car":0.8,
    "Car passing by":1.2,
    "Truck":1.0,
    "Bus":0.8,
    "Vehicle horn, car horn, honking":0.8
}

@app.errorhandler(Exception)
def handle_error(e):
    print("SERVER ERROR: ", e)
    return jsonify({
        "error": str(e)
    }), 500


@app.route("/detect", methods=["POST"])
def detect():
    print(" DETECT HIT ")
    try:

        audio_bytes = request.data

        print("TYPE:", request.content_type)
        print("SIZE:", len(audio_bytes))
        print("HEADER:", audio_bytes[:20])

        print("Received bytes:", len(audio_bytes))


        audio_segment = AudioSegment.from_file(
            io.BytesIO(audio_bytes),
            format="webm",
            codec="opus"
        )


        audio_segment = (
            audio_segment
            .set_frame_rate(16000)
            .set_channels(1)
        )


        audio = np.array(
            audio_segment.get_array_of_samples()
        )


        audio = audio.astype(np.float32) / 32768.0


        print("Audio ready:", audio.shape)
        scores, embeddings, spectrogram = model(audio)
        print("YAMNet finished")
        scores_mean = scores.numpy().mean(axis=0)

        vehicle_score = 0
        detected=[]


        for i,label in enumerate(class_map["display_name"]):
            if label in weights:
                confidence=float(scores_mean[i])
                if confidence > 0.05:
                    detected.append(label)
                    vehicle_score += confidence * weights[label]

        threat = min(vehicle_score * 40,100)

        if threat >= 70:
            result="ALERT"
        elif threat >=40:
            result="WARNING"
        else:
            result="SAFE"


        print(result, threat, detected)


        return jsonify({
            "result":result,
            "threat":float(threat),
            "sounds":detected
        })

    except Exception as e:

        print("!!!! ERROR !!!!")
        print(e)

        return jsonify({
            "error":str(e)
        }),500
    
app.run(
    host="0.0.0.0",
    port=5000
)