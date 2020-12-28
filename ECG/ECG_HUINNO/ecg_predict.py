import keras
from keras.models import Sequential
from keras.layers.core import Dense, Dropout, Flatten
from keras.layers.convolutional import Conv1D, MaxPooling1D, ZeroPadding1D
from keras.layers.normalization import BatchNormalization
import keras.backend as K
from keras import optimizers

from keras.callbacks import TensorBoard
from keras.callbacks import ModelCheckpoint

from keras.layers import BatchNormalization
from keras.models import load_model

import ecg_input

import numpy as np
import os
import csv
import os
import random

model = load_model('ecg.h5')

INPUT_SHAPE = 9000

AFIB_TEST_DIR = "D:\\ecg\\DataSet\\test\\afib\\"
ecgs = np.empty((1, INPUT_SHAPE, 1))

afib_test_filenames = os.listdir(AFIB_TEST_DIR)

with open(AFIB_TEST_DIR + afib_test_filenames[0], 'r') as f:
    reader = csv.reader(f)
    data = list(reader)
    for j in range(0,INPUT_SHAPE):
        ecgs[0][j] = float(data[j][1])


result = model.predict(ecgs)

print(result)

K.clear_session()