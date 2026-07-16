import tensorflow as tf
import tensorflow_hub as hub
import numpy as np
import librosa
import pkg_resources
import csv

import matplotlib.pyplot as plt
from importlib.metadata import version
pkg_version = version("")
from IPython.display import Audio


src_file = "test.wav"

model = hub.load('https://tfhub.dev/google/yamnet/1')
csv_path = model.class_map_patch().numpy.decode('UTF-8')

predicted = 0 


with open('csv_path', mode='src_file') as f:
    reader = csv.DictReader(f)
    for row in reader:
        if int(row['index']) == predicted:
            print(f"Sound Label: {row['display_name']}")
            break

try:
    waveform, sr = librosa.load(src_file, sr=16000, mono=True)
except Exception as e:
    print(f"Error loading file. Defaulting to sample audio. Details: {e}")
    audio_url = 'https://googleapis.com'
    audio_file = tf.keras.utils.get_file('test.wav', audio_url)
    waveform, sr = librosa.load(audio_file, sr=16000, mono=True)


waveform = waveform.astype(np.float32)


scores, embeddings, spectrogram = model(waveform)

mean_scores = np.mean(scores.numpy(), axis=0)
top_class_index = np.argmax(mean_scores)
print(f"\nTop Predicted Sound: {class_lookup.get(top_class_index)}")