
# coding: utf-8

# In[18]:


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
from keras.layers import RNN
from keras.models import load_model

import ecg_input

import numpy as np

import datetime

input_shape = (9000, 1)
n_classes = 3

model = Sequential()

# Layer 1
model.add(Conv1D(filters=48, kernel_size=11, strides=3, activation='relu', input_shape = input_shape))
#model.add(BatchNormalization())
model.add(MaxPooling1D(pool_size=3, strides=2))

# Layer 2
#model.add(ZeroPadding1D(padding=3))
model.add(Conv1D(filters=128, kernel_size=5, strides=1, activation='relu', padding='valid'))
#model.add(BatchNormalization())
model.add(MaxPooling1D(pool_size=3, strides=2))



# Layer 3
model.add(ZeroPadding1D(padding=2))
model.add(Conv1D(filters=192, kernel_size=3, strides=1, activation='relu', padding='valid'))
model.add(BatchNormalization())
model.add(MaxPooling1D(pool_size=3, strides=2))

# Layer 4
model.add(ZeroPadding1D(padding=2))
model.add(Conv1D(filters=192, kernel_size=3, strides=1, activation='relu', padding='valid'))
model.add(BatchNormalization())
model.add(MaxPooling1D(pool_size=3, strides=2))

model.add(ZeroPadding1D(padding=2))
model.add(Conv1D(filters=192, kernel_size=3, strides=1, activation='relu', padding='valid'))
model.add(BatchNormalization())

# Layer 5
model.add(Conv1D(filters=128, kernel_size=3, strides=1, activation='relu', padding='valid'))
model.add(BatchNormalization())
model.add(MaxPooling1D(pool_size=3, strides=2))

# Layer 5
model.add(Conv1D(filters=128, kernel_size=3, strides=1, activation='relu', padding='valid'))
model.add(BatchNormalization())
model.add(MaxPooling1D(pool_size=3, strides=2))

# Layer 6
model.add(Flatten())
model.add(Dense(2048, activation='relu'))
model.add(Dropout(0.5))

# Layer 7
model.add(Dense(2048, activation='relu'))
model.add(Dropout(0.5))

# Layer 8
model.add(Dense(n_classes, activation='softmax'))

model.summary()

sgd = optimizers.SGD(lr=0.1, decay=1e-6, momentum=0.9, nesterov=True)
adam = optimizers.Adam(lr=0.001, beta_1=0.9, beta_2=0.999, epsilon=1e-08, decay=0.0)
adadelta = optimizers.adadelta()
model.compile(loss=keras.losses.categorical_crossentropy, optimizer=adam, metrics=['accuracy'])

# generate ecg data
train_ecgs, train_labels = ecg_input.ecg_train_input()
one_hot_train_labels = keras.utils.to_categorical(train_labels, num_classes=n_classes)

tensorboard = TensorBoard(log_dir='./logs', histogram_freq=0, batch_size=256, write_graph=True, write_grads=True, write_images=False, embeddings_freq=0, embeddings_layer_names=None, embeddings_metadata=None)
checkpointer = ModelCheckpoint(filepath='./ecg.hdf5', verbose=1, save_best_only=True)
model.fit(train_ecgs, one_hot_train_labels, validation_split=0.2, epochs=1000, batch_size=256, callbacks=[tensorboard, checkpointer])

# model.summary()

# evaluate model
test_ecgs, test_labels = ecg_input.ecg_test_input()
one_hot_test_labels = keras.utils.to_categorical(test_labels, num_classes=n_classes)

result = model.evaluate(test_ecgs, one_hot_test_labels, batch_size=256, verbose=1)

print(result)

now = datetime.datetime.now()
nowDatetime = now.strftime('_%Y%m%d_%H%M%S')

model.save('ecg'+ nowDatetime +'.h5')
#del model
#model = load_model('ecg.h5')

K.clear_session()

