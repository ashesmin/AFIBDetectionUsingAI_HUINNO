
# coding: utf-8

# In[18]:


import keras
from keras.models import Sequential
import keras.backend as K
from keras import optimizers

from keras.callbacks import TensorBoard
from keras.callbacks import ModelCheckpoint

from keras.models import load_model
from keras.layers import RNN
from keras.layers import LSTM
from keras.layers import Dense, Embedding

import snuh_input

import numpy as np

import datetime

max_features = 2000
input_shape = (2000, 1)
n_classes = 2

model = Sequential()

model.add(Embedding(max_features, 128))
model.add(LSTM(128, dropout=0.2, recurrent_dropout=0.2))
# Layer 
model.add(Dense(n_classes, activation='softmax'))

model.summary()

sgd = optimizers.SGD(lr=0.1, decay=1e-6, momentum=0.9, nesterov=True)
adam = optimizers.Adam(lr=0.001, beta_1=0.9, beta_2=0.999, epsilon=1e-08, decay=0.0)
adadelta = optimizers.adadelta()
model.compile(loss=keras.losses.categorical_crossentropy, optimizer=adam, metrics=['accuracy'])

# generate ecg data
train_ecgs, train_labels = snuh_input.snuh_train_input()
one_hot_train_labels = keras.utils.to_categorical(train_labels, num_classes=n_classes)

tensorboard = TensorBoard(log_dir='./logs', histogram_freq=0, batch_size=256, write_graph=True, write_grads=True, write_images=False, embeddings_freq=0, embeddings_layer_names=None, embeddings_metadata=None)
checkpointer = ModelCheckpoint(filepath='./snuh.hdf5', verbose=1, save_best_only=True)
model.fit(train_ecgs, one_hot_train_labels, validation_split=0.2, epochs=1000, batch_size=256, callbacks=[tensorboard, checkpointer])

# model.summary()

# evaluate model
test_ecgs, test_labels = snuh_input.snuh_test_input()
one_hot_test_labels = keras.utils.to_categorical(test_labels, num_classes=n_classes)

result = model.evaluate(test_ecgs, one_hot_test_labels, batch_size=256, verbose=1)

print(result)

now = datetime.datetime.now()
nowDatetime = now.strftime('_%Y%m%d_%H%M%S')

model.save('snuh'+ nowDatetime +'.h5')
#del model
#model = load_model('ecg.h5')

K.clear_session()

