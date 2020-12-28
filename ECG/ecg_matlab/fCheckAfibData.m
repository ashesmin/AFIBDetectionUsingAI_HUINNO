function [retval] = fCheckAfibData(output_dir, filename, sample_rate, afib_ratio)

filename = strcat(output_dir,filename);
f = csvread(filename);

filter_setting = 1;
threshold_multiplier = 3;

[ecgDataSet, rrIntervalArray, rrIndexArray, hrArray, rrCount] = f_EcgPeakDetector(f, sample_rate, threshold_multiplier, filter_setting);

retval = 0;
for j = 1:length(rrIntervalArray)-1
    one_of_ten = rrIntervalArray(j) / 10 * afib_ratio;
    diff_between_interval = rrIntervalArray(j+1)-rrIntervalArray(j);

    if(one_of_ten < diff_between_interval)
        retval = 1;
    end
end
end

