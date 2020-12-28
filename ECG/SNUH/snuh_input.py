import numpy as np
import csv
import os
import random

NUM_CLASSES = 2
INPUT_SHAPE = 2000

def snuh_train_input():
    NORMAL_TRAIN_DIR = "D:\\SNUH\\Dataset\\train\\normal\\"
    ABNORMAL_TRAIN_DIR = "D:\\SNUH\\Dataset\\train\\abnormal\\"
    
    normal_train_filenames = os.listdir(NORMAL_TRAIN_DIR)
    abnormal_train_filenames = os.listdir(ABNORMAL_TRAIN_DIR)

    normal_train_length = len(normal_train_filenames)
    abnormal_train_length = len(abnormal_train_filenames)
    t_length = normal_train_length + abnormal_train_length
    #random.shuffle(normal_train_filenames)
    #random.shuffle(abnormal_train_filenames)
    
    ecgs = np.array([]).reshape(0,INPUT_SHAPE)
    labels = np.array([], dtype=np.int32).reshape(0,1)

    for i in range(0,normal_train_length):
        with open(NORMAL_TRAIN_DIR + normal_train_filenames[i], 'r') as f:
            reader = csv.reader(f)
            data = np.asarray(list(reader)).reshape(INPUT_SHAPE)
            ecgs = np.vstack([ecgs, data])
            labels = np.vstack([labels, [0]])
    for i in range(0,abnormal_train_length):
        with open(ABNORMAL_TRAIN_DIR + abnormal_train_filenames[i], 'r') as f:
            reader = csv.reader(f)
            data = np.asarray(list(reader)).reshape(INPUT_SHAPE)
            ecgs = np.vstack([ecgs, data])
            labels = np.vstack([labels, [0]])

    return ecgs, labels        

def snuh_test_input():
    NORMAL_TEST_DIR = "D:\\SNUH\\Dataset\\test\\normal\\"
    ABNORMAL_TEST_DIR = "D:\\SNUH\\Dataset\\test\\abnormal\\"

    normal_test_filenames = os.listdir(NORMAL_TEST_DIR)
    abnormal_test_filenames = os.listdir(ABNORMAL_TEST_DIR)

    normal_test_length = len(normal_test_filenames)
    abnormal_test_length = len(abnormal_test_filenames)

    #random.shuffle(normal_test_filenames)
    #random.shuffle(abnormal_test_filenames)

    ecgs = np.array([]).reshape(0,INPUT_SHAPE)
    labels = np.array([], dtype=np.int32).reshape(0,1)

    for i in range(0,normal_test_length):
        with open(NORMAL_TEST_DIR + normal_test_filenames[i], 'r') as f:
            reader = csv.reader(f)
            data = np.asarray(list(reader)).reshape(INPUT_SHAPE)
            ecgs = np.vstack([ecgs, data])
            labels = np.vstack([labels, [0]])
    for i in range(0,abnormal_test_length):
        with open(ABNORMAL_TEST_DIR + abnormal_test_filenames[i], 'r') as f:
            reader = csv.reader(f)
            data = np.asarray(list(reader)).reshape(INPUT_SHAPE)
            ecgs = np.vstack([ecgs, data])
            labels = np.vstack([labels, [0]])

    return ecgs, labels