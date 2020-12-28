
function [ecgDataSet, rrIntervalArray, rrIndexArray, hrArray, rrCount] = f_EcgPeakDetector(ecgOriginalDataSet, defSampleRate, defThresholdMultiplier, defFilterSetting)
     %% ECG Variable
    defAdditionalCount = defSampleRate / 10;   % Get 100ms data for ecg peak detect
    defPeakDistance = defSampleRate / 4;      % Minimum distance 250ms = subject HR is less than 240
    defSignalChangePlus = 5;
    defSignalChangeMinus = -5;
    
    maxPointIndex = 0;
    maxPointValue = 0;
    maxCount = 0;
    peakIndex = 0;
    beforePeakIndex = -defPeakDistance;
    
    lowPeakDetect = 0;
    
    vaulue = 0;   

    if (defFilterSetting == 1)
        ecg_fir = fir1(30, [50/(defSampleRate/2), 70/(defSampleRate/2)], 'stop');
    else
        ecg_fir = fir1(30, [5/(defSampleRate/2), 20/(defSampleRate/2)], 'bandpass');
    end
    
    ecgDataSet(:,1) = ecgOriginalDataSet(:,1);
    ecgDataSet(:,2) = filtfilt(ecg_fir, 1, ecgDataSet(:,1));
    ecgDataSet(:,3) = vertcat(0, diff(ecgDataSet(:,2)));
    
    ecgDataSet(:,4) = ecgDataSet(:,3).^2;

    for i = 15:length(ecgDataSet)
        ecgDataSet(i,5) = sum(ecgDataSet(i-14:i,4));
    end
    
    defPeakThreshold = mean(ecgDataSet(:,5)) * defThresholdMultiplier;
    
    %% ECG Peak Detect
    for indexOfDataSet = 1:length(ecgDataSet) 
        if (ecgDataSet(indexOfDataSet, 5) >= defPeakThreshold)
            if (maxPointValue < ecgDataSet(indexOfDataSet, 5))
                maxPointValue = ecgDataSet(indexOfDataSet, 5);
                maxPointIndex = indexOfDataSet;
            end
        end
        %% Peak canididate found
        if (maxPointIndex ~= 0 && (maxPointIndex + defAdditionalCount < indexOfDataSet)) 
            %% Near peak rejection
            if (maxPointIndex >= beforePeakIndex + defPeakDistance)
                if (ecgDataSet(maxPointIndex, 3) < 0)
                    if (beforePeakIndex < 0)
                        beforePeakIndex = 1;
                    end
                    for peakSearchIndex = maxPointIndex:-1:beforePeakIndex % left searching
                        if (ecgDataSet(peakSearchIndex, 3) > defSignalChangePlus) % diffrential sign - to +
                            peakIndex = f_RPeakValidation(ecgDataSet, peakSearchIndex, defPeakThreshold, defSampleRate);
                            break;
                        end
                    end
                    if (peakIndex == 0)
                        value = 1;
                        % Fail to peak finding
                    end
                else
                    for peakSearchIndex = maxPointIndex:indexOfDataSet % right searching
                        if (ecgDataSet(maxPointIndex, 3) > defSignalChangeMinus) % diffrential sign + to -
                            peakIndex = f_RPeakValidation(ecgDataSet, peakSearchIndex, defPeakThreshold, defSampleRate);
                            break;
                        end
                    end
                    if (peakIndex == 0)
                        % Fail to peak finding
                        % left searching
                        if (beforePeakIndex < 0)
                            beforePeakIndex = 1;
                        end
                        for peakSearchIndex = maxPointIndex:-1:beforePeakIndex % left searching
                            if (~lowPeakDetect)
                                if (ecgDataSet(peakSearchIndex, 3) < defSignalChangeMinus) % diffrential sign - to +
                                    lowPeakDetect = 1;
                                end
                            else
                                if (ecgDataSet(peakSearchIndex, 3) > defSignalChangePlus) % diffrential sign + to -
                                    lowPeakDetect = 0;
                                    peakIndex = f_RPeakValidation(ecgDataSet, peakSearchIndex, defPeakThreshold, defSampleRate);
                                    break;
                                end
                            end
                        end
                        if (peakIndex == 0)
                            value = 1;
                            % Fail to peak finding
                        end
                    end
                end
            end
            
            if (peakIndex ~= 0)
                ecgDataSet(peakIndex, 6) = 4096;
                beforePeakIndex = peakIndex;
                peakIndex = 0;
            else 
                value = 1;
            end
            
            maxPointIndex = 0;
            maxPointValue = 0;
        end
    end
    
    %% RR Index Extract
    rrIndexArray = zeros(sum(ecgDataSet(:,6))/4096, 1);
    rrCount = 0;
    for i=1:length(ecgDataSet)
       if ecgDataSet(i,6) == 4096
           rrCount = rrCount + 1;
           rrIndexArray(rrCount, 1) = i;
       end
    end
    
    %% Calculate RR Interval & Heart rate
    rrIntervalArray = diff(rrIndexArray);
    hrArray = (300*60)./rrIntervalArray;
    rrCount = rrCount - 1;
%     rrIntervalArray = zeros(rrCount, 1);
%     hrArray = zeros(rrCount, 1);
%     rrIntervalArray(1) = rrIndexArray(1);
%     hrArray(1) = (60 * defSampleRate) / rrIntervalArray(1); % HR = (60 * SAMPLE_RATE)  / RR_Interval
%     for i = 2:rrCount
%         rrIntervalArray(i, 1) = rrIndexArray(i, 1) - rrIndexArray(i-1, 1);
%         hrArray(i, 1) = (60 * defSampleRate) / rrIntervalArray(i, 1);
%     end
%     
%     ecgDataSet(:,3) = vertcat(0, diff(ecgDataSet(:,2)));
%     rrIntervalArray(i, 2) = vertcat(0, diff(rrIntervalArray(i, 1)));
end