import numpy as np
import csv
import os
import random

TRAIN_DATA_NUM = 3000
TEST_DATA_NUM = 600

NUM_CLASSES = 3
INPUT_SHAPE = 9000


def ecg_train_input():
    AFIB_TRAIN_DIR = "D:\\ecg\\DataSet\\train\\afib\\"
    SINUS_TRAIN_DIR = "D:\\ecg\\DataSet\\train\\sinus\\"
    NOISE_TRAIN_DIR = "D:\\ecg\\DataSet\\train\\noise\\"
    
    afib_train_filenames = os.listdir(AFIB_TRAIN_DIR)
    sinus_train_filenames = os.listdir(SINUS_TRAIN_DIR)
    noise_train_filenames = os.listdir(NOISE_TRAIN_DIR)

    random.shuffle(afib_train_filenames)
    random.shuffle(sinus_train_filenames)
    random.shuffle(noise_train_filenames)
    
    ecgs = np.empty((TRAIN_DATA_NUM * NUM_CLASSES, INPUT_SHAPE, 1))
    labels = np.random.randint(2, size=(TRAIN_DATA_NUM * NUM_CLASSES,1))
    
    for i in range(0,TRAIN_DATA_NUM):
        with open(AFIB_TRAIN_DIR + afib_train_filenames[i], 'r') as f:
            reader = csv.reader(f)
            data = list(reader)
            for j in range(0,INPUT_SHAPE):
                ecgs[i][j] = float(data[j][1])
            labels[i][0] = 0
    for i in range(0,TRAIN_DATA_NUM):
        with open(SINUS_TRAIN_DIR + sinus_train_filenames[i], 'r') as f:
            reader = csv.reader(f)
            data = list(reader)
            for j in range(0,INPUT_SHAPE):
                ecgs[i+TRAIN_DATA_NUM][j] = float(data[j][1])
            labels[i+TRAIN_DATA_NUM][0] = 1
    for i in range(0,TRAIN_DATA_NUM):
        with open(NOISE_TRAIN_DIR + noise_train_filenames[i], 'r') as f:
            reader = csv.reader(f)
            data = list(reader)
            for j in range(0,INPUT_SHAPE):
                ecgs[i+TRAIN_DATA_NUM*2][j] = float(data[j][1])
            labels[i+TRAIN_DATA_NUM*2][0] = 2    
    return ecgs, labels        

def ecg_test_input():
    AFIB_TEST_DIR = "D:\\ecg\\DataSet\\test\\afib\\"
    SINUS_TEST_DIR = "D:\\ecg\\DataSet\\test\\sinus\\"
    NOISE_TEST_DIR = "D:\\ecg\\DataSet\\test\\noise\\"

    afib_test_filenames = os.listdir(AFIB_TEST_DIR)
    sinus_test_filenames = os.listdir(SINUS_TEST_DIR)
    noise_test_filenames = os.listdir(NOISE_TEST_DIR)

    random.shuffle(afib_test_filenames)
    random.shuffle(sinus_test_filenames)
    random.shuffle(noise_test_filenames)

    ecgs = np.empty((TEST_DATA_NUM * NUM_CLASSES, INPUT_SHAPE, 1))
    labels = np.random.randint(2, size=(TEST_DATA_NUM * NUM_CLASSES,1))
    
    for i in range(0,TEST_DATA_NUM):
        with open(AFIB_TEST_DIR + afib_test_filenames[i], 'r') as f:
            reader = csv.reader(f)
            data = list(reader)
            for j in range(0,INPUT_SHAPE):
                ecgs[i][j] = float(data[j][1])
            labels[i][0] = 0
    for i in range(0,TEST_DATA_NUM):  
        with open(SINUS_TEST_DIR + sinus_test_filenames[i], 'r') as f:
            reader = csv.reader(f)
            data = list(reader)
            for j in range(0,INPUT_SHAPE):
                ecgs[i+TEST_DATA_NUM][j] = float(data[j][1])
            labels[i+TEST_DATA_NUM][0] = 1
    for i in range(0,TEST_DATA_NUM):  
        with open(NOISE_TEST_DIR + noise_test_filenames[i], 'r') as f:
            reader = csv.reader(f)
            data = list(reader)
            for j in range(0,INPUT_SHAPE):
                ecgs[i+TEST_DATA_NUM*2][j] = float(data[j][1])
            labels[i+TEST_DATA_NUM*2][0] = 2
    return ecgs, labels


def ecg_test_input_dir(directory):
    AFIB_TEST_DIR = directory + "\\afib\\"
    SINUS_TEST_DIR = directory + "\\sinus\\"
    NOISE_TEST_DIR = directory + "\\noise\\"

    afib_test_filenames = os.listdir(AFIB_TEST_DIR)
    sinus_test_filenames = os.listdir(SINUS_TEST_DIR)
    noise_test_filenames = os.listdir(NOISE_TEST_DIR)

    random.shuffle(afib_test_filenames)
    random.shuffle(sinus_test_filenames)
    random.shuffle(noise_test_filenames)

    afib_len = len(afib_test_filenames)
    sinus_len = len(sinus_test_filenames)
    noise_len = len(noise_test_filenames)
    total_len = afib_len+sinus_len+noise_len
    print(str(afib_len) + " " +str(sinus_len) + " " + str(noise_len) + " " +str(total_len))

    ecgs = np.empty((total_len, INPUT_SHAPE, 1))
    labels = np.random.randint(2, size=(total_len,1))
    
    for i in range(0,afib_len):
        with open(AFIB_TEST_DIR + afib_test_filenames[i], 'r') as f:
            reader = csv.reader(f)
            data = list(reader)
            for j in range(0,INPUT_SHAPE):
                ecgs[i][j] = float(data[j][1])
            labels[i][0] = 0
    for i in range(0,sinus_len):  
        with open(SINUS_TEST_DIR + sinus_test_filenames[i], 'r') as f:
            reader = csv.reader(f)
            data = list(reader)
            for j in range(0,INPUT_SHAPE):
                ecgs[i+afib_len][j] = float(data[j][1])
            labels[i+afib_len][0] = 1
    for i in range(0,noise_len):  
        with open(NOISE_TEST_DIR + noise_test_filenames[i], 'r') as f:
            reader = csv.reader(f)
            data = list(reader)
            for j in range(0,INPUT_SHAPE):
                ecgs[i+afib_len+noise_len][j] = float(data[j][1])
            labels[i+afib_len+noise_len][0] = 2
    return ecgs, labels    