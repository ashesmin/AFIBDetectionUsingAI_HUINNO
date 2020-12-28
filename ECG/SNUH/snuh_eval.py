import keras
from keras.models import Sequential
import keras.backend as K

from keras.models import load_model
from keras.layers import RNN
from keras.layers import LSTM
from keras.layers import Dense, Embedding

import snuh_input

import numpy as np

n_classes = 2

model = load_model('./snuh.hdf5')

test_ecgs, test_labels = snuh_input.snuh_test_input()
one_hot_test_labels = keras.utils.to_categorical(test_labels, num_classes=n_classes)

result = model.evaluate(test_ecgs, one_hot_test_labels, batch_size=256, verbose=1)

print(result)

K.clear_session()
