function [ecg_std_mean] = fEcgNoiseStdCalculator(input_dir, random_number, cutting_size)

filenames = dir(input_dir);
filenames_len = length(filenames);

% Shuffle vector
filenames = filenames(3:filenames_len);
filenames = filenames(randperm(length(filenames)));

std_vector = zeros(random_number, 1);

for i=1:random_number
    filename = strcat(input_dir, filenames(i).name);
    f = csvread(filename);
    std_position = cutting_size*2 + 2;
    std_vector(i) = f(std_position);
end

ecg_std_mean = mean(std_vector);

end

