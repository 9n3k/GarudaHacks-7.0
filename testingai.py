import tensorflow as tf
import tensorflow_hub as hub
import numpy as np
import csv

import matplotlib.pyplot as plt
from IPython.display import Audio
from scipy.io import wavfile

src_file = "test.wav"

model = hub.load('https://tfhub.dev/google/yamnet/1')

