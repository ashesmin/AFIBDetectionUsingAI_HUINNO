import os
import random
import shutil
import numpy as np

SOURCE_DATA_DIR = "K:\\HUINNO\\ecg_matlab\\ecg_classified_10\\"
TARGET_DATA_DIR = "K:\\HUINNO\\ecg_matlab\\CNN_keras\\DataSet\\ecg_classified_10\\"

TRAIN_DATA_NUM = 1000
TEST_DATA_NUM = 200

TRAIN_DATA_NAMES = ["data_003", "data_005", "data_006", "data_007", "data_008", "data_009", "data_011", "data_012", "data_013", "data_014", "data_015"]
TEST_DATA_NAMES = ["data_001", "data_002", "data_010"]

def check_file_name(filename, idx, string):
	if filename[:idx] == string:
		return True
	else:
		return False

def check_train_data(filename):
	for name in TRAIN_DATA_NAMES:
		if check_file_name(filename, 8, name):
			return True
	return False

def check_test_data(filename):
	for name in TEST_DATA_NAMES:
		if check_file_name(filename, 8, name):
			return True
	return False

def cal_cnts(filenames):
	file_cnts = np.zeros(15)

	for filename in filenames:
		if check_file_name(filename, 8, "data_001"):
			file_cnts[0] = file_cnts[0] + 1
		elif check_file_name(filename, 8, "data_002"):
			file_cnts[1] = file_cnts[1] + 1
		elif check_file_name(filename, 8, "data_003"):
			file_cnts[2] = file_cnts[2] + 1
		elif check_file_name(filename, 8, "data_004"):
			file_cnts[3] = file_cnts[3] + 1
		elif check_file_name(filename, 8, "data_005"):
			file_cnts[4] = file_cnts[4] + 1
		elif check_file_name(filename, 8, "data_006"):
			file_cnts[5] = file_cnts[5] + 1
		elif check_file_name(filename, 8, "data_007"):
			file_cnts[6] = file_cnts[6] + 1
		elif check_file_name(filename, 8, "data_008"):
			file_cnts[7] = file_cnts[7] + 1
		elif check_file_name(filename, 8, "data_009"):
			file_cnts[8] = file_cnts[8] + 1
		elif check_file_name(filename, 8, "data_010"):
			file_cnts[9] = file_cnts[9] + 1
		elif check_file_name(filename, 8, "data_011"):
			file_cnts[10] = file_cnts[10] + 1		
		elif check_file_name(filename, 8, "data_012"):
			file_cnts[11] = file_cnts[11] + 1
		elif check_file_name(filename, 8, "data_013"):
			file_cnts[12] = file_cnts[12] + 1
		elif check_file_name(filename, 8, "data_014"):
			file_cnts[13] = file_cnts[13] + 1
		elif check_file_name(filename, 8, "data_015"):
			file_cnts[14] = file_cnts[14] + 1

	return file_cnts

noise_filenames = os.listdir(SOURCE_DATA_DIR + "noise\\")
afib_filenames = os.listdir(SOURCE_DATA_DIR + "afib\\")
sinus_filenames = os.listdir(SOURCE_DATA_DIR + "sinus\\")

noise_cnts = cal_cnts(noise_filenames)
afib_cnts = cal_cnts(afib_filenames)
sinus_cnts = cal_cnts(sinus_filenames)

###################  파일 개수를 확인하기 위함.
#print(noise_cnts)
#print(afib_cnts)
#print(sinus_cnts)

#print(np.sum(noise_cnts))
#print(np.sum(afib_cnts))
#print(np.sum(sinus_cnts))
###################

random.shuffle(afib_filenames)
random.shuffle(sinus_filenames)
random.shuffle(noise_filenames)

test_i = 0
train_i = 0
for i in range(0, int(np.sum(noise_cnts))):
	if check_test_data(noise_filenames[i]) and test_i < TEST_DATA_NUM:
		shutil.copy2(SOURCE_DATA_DIR + "noise\\" + noise_filenames[i], TARGET_DATA_DIR + "test\\noise\\" + noise_filenames[i])
		test_i = test_i + 1
	elif check_train_data(noise_filenames[i]) and train_i < TRAIN_DATA_NUM:
		shutil.copy2(SOURCE_DATA_DIR + "noise\\" + noise_filenames[i], TARGET_DATA_DIR + "train\\noise\\" + noise_filenames[i])
		train_i = train_i + 1
	elif test_i >= TEST_DATA_NUM and train_i >= TRAIN_DATA_NUM:
		break

test_i = 0
train_i = 0
for i in range(0, int(np.sum(afib_cnts))):
	if check_test_data(afib_filenames[i]) and test_i < TEST_DATA_NUM:
		shutil.copy2(SOURCE_DATA_DIR + "afib\\" + afib_filenames[i], TARGET_DATA_DIR + "test\\afib\\" + afib_filenames[i])
		test_i = test_i + 1
	elif check_train_data(afib_filenames[i]) and train_i < TRAIN_DATA_NUM:
		shutil.copy2(SOURCE_DATA_DIR + "afib\\" + afib_filenames[i], TARGET_DATA_DIR + "train\\afib\\" + afib_filenames[i])
		train_i = train_i + 1
	elif test_i >= TEST_DATA_NUM and train_i >= TRAIN_DATA_NUM:
		break

test_i = 0
train_i = 0
for i in range(0, int(np.sum(sinus_cnts))):
	if check_test_data(sinus_filenames[i]) and test_i < TEST_DATA_NUM:
		shutil.copy2(SOURCE_DATA_DIR + "sinus\\" + sinus_filenames[i], TARGET_DATA_DIR + "test\\sinus\\" + sinus_filenames[i])
		test_i = test_i + 1
	elif check_train_data(sinus_filenames[i]) and train_i < TRAIN_DATA_NUM:
		shutil.copy2(SOURCE_DATA_DIR + "sinus\\" + sinus_filenames[i], TARGET_DATA_DIR + "train\\sinus\\" + sinus_filenames[i])
		train_i = train_i + 1
	elif test_i >= TEST_DATA_NUM and train_i >= TRAIN_DATA_NUM:
		break

