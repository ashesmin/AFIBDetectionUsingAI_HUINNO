clear;

raw_dir = 'D:\ecg_matlab\ecg\';
cutted_dir = 'D:\ecg_matlab\ecg_cutted\';
classified_dir = 'D:\ecg_matlab\ecg_classified\';
sample_rate = 300;
window_size = sample_rate*5;
cutting_size = sample_rate*30;
threshold_multiplier = 2;
random_number = 4000;
afib_ratio = 1;
noise_ratio = 1.5;

fEcgCutter(raw_dir, cutted_dir, window_size, cutting_size);
ecg_std_mean = fEcgNoiseStdCalculator(cutted_dir, random_number, cutting_size);

filenames = dir(cutted_dir);
filenames_len = length(filenames);

% filenames(1) = .
% filenames(2) = ..
% filenames(3) 부터 실제 파일 이름
for i = 3:filenames_len
    if fCheckNoiseData(cutted_dir, filenames(i).name, ecg_std_mean, cutting_size, noise_ratio)
        fMoveNoiseData(cutted_dir, classified_dir, filenames(i).name);
    elseif fCheckAfibData(cutted_dir, filenames(i).name, sample_rate, afib_ratio)
        fMoveAfibData(cutted_dir, classified_dir, filenames(i).name);
    else
        fMoveSinusData(cutted_dir, classified_dir, filenames(i).name);
    end
end