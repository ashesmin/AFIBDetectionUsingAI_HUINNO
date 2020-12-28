function [] = fEcgCutter(input_dir, output_dir, window_size, cutting_time)

filenames = dir(input_dir);
filenames_len = length(filenames);

% filenames(1) = .
% filenames(2) = ..
% filenames(3) 부터 실제 파일 이름
for i=3:filenames_len
    filename = strcat(input_dir, filenames(i).name);
    f = csvread(filename);
    disp(filename);
    
    j = 1;
    while j + cutting_time - 1 < length(f)
        filename_cutter = split(filenames(i).name,'.');
        cutter_step = ceil(j/window_size);
        output_file = strcat(output_dir, filename_cutter(1));
        output_file = strcat(output_file, '_');
        output_file = strcat(output_file, int2str(cutter_step));
        output_file = strcat(output_file, '.');
        output_file = strcat(output_file, filename_cutter(2));
        
        f_cutted = f(j:j + cutting_time - 1);
        f_cutted = reshape(f_cutted, cutting_time, 1);
        f_cutted_mean = mean(f_cutted);
        
        f_base_shifted = f_cutted - f_cutted_mean;
        f_base_shifted = reshape(f_base_shifted, cutting_time, 1);
        f_base_shifted_std = std(f_base_shifted);
        
        f_param = zeros(cutting_time, 1);
        f_param(1) = f_cutted_mean;
        f_param(2) = f_base_shifted_std;
        
        f_saved = [f_cutted , f_base_shifted, f_param];
        
        csvwrite(string(output_file), f_saved);
        j = j + window_size;
    end
end
end

