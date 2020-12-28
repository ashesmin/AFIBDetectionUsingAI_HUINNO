function [retval] = fCheckNoiseData(output_dir, filename, ecg_std_mean, cutting_size, noise_ratio)

filename = strcat(output_dir, filename);
f = csvread(filename);

std_position = cutting_size * 2 + 2;
ecg_std = f(std_position);

if ecg_std > ecg_std_mean * noise_ratio
    retval = 1;
else
    retval = 0;
end
end

