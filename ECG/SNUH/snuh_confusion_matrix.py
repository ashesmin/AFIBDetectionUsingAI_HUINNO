
# coding: utf-8

# In[1]:


import keras
from keras.models import Sequential
import keras.backend as K
from keras import optimizers

from keras.models import load_model

import ecg_input

import numpy as np


# In[2]:


model = load_model('./accu_73.96/ecg.h5')

test_ecgs, test_labels = ecg_input.ecg_test_input_dir('E:\\ecg\\test')
result = model.predict(test_ecgs)


# In[ ]:


confusion_matrix = np.zeros((3,3))

for i in range(0,len(result)):
    y_true = test_labels[i][0]
    y_pred = np.argmax(result[i])
    
    confusion_matrix[y_true][y_pred] += 1
    
print(confusion_matrix)

