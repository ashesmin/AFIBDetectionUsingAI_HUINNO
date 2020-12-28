
# coding: utf-8

# In[1]:


import keras
from keras.models import Sequential
import keras.backend as K
from keras import optimizers

from keras.models import load_model

import ecg_input

import numpy as np

import os
import csv


# In[2]:


model = load_model('./accu_73.33/ecg.h5')


# In[25]:


def filter_visualization(kernel_size, filter_size):
    tmp = []
    tmp_filter = np.zeros((filter_size,kernel_size))
    first_layer_weights = model.layers[0].get_weights()
    
    for i in range(0, filter_size):
        tmp2 = [0 for _ in range(kernel_size)]
        for j in range(0, kernel_size):
            tmp2[j] = str(first_layer_weights[0][j][0][i].item())
        tmp.append(tmp2)
    
    return tmp

filters = filter_visualization(11,48)
f_write = open('./accu_73.33/filters.csv', 'w', newline='')
csvWriter = csv.writer(f_write)
csvWriter.writerows(filters)
f_write.close()    

