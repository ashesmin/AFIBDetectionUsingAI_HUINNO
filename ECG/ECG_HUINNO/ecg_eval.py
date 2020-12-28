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

n_classes = 3

model = load_model('./accu_73.96/ecg.h5')


test_ecgs, test_labels = ecg_input.ecg_test_input()
one_hot_test_labels = keras.utils.to_categorical(test_labels, num_classes=n_classes)

result = model.evaluate(test_ecgs, one_hot_test_labels, batch_size=256, verbose=1)

print(result)


K.clear_session()
