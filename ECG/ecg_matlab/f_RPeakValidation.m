function [peakIndex] = f_RPeakValidation(ecgDataSet, peakIndex, defPeakThreshold, defSampleRate)
    % Noraml QRS Interval = 0.06~0.10ms
    defRealPeakFindIndexCount = defSampleRate / 20;        % Min QRS Interval = 50ms
    defSearchIndexCount = defSampleRate / 50;                          % 20ms Search
    
    defMaxOppositeHittingCount = 2;
    debugPeakTime = peakIndex / 300;

    %defRealPeakFindIndexCount = 15;
    %defSearchIndexCount = 20;               % Noraml QRS Interval = 0.06~0.10ms
    
    
    defAmplitudeValidationDistance = defSearchIndexCount;
    
%     if (defPeakThreshold > 7500)
%         defAmplitudeValidationValue = 100;
%     else
%         defAmplitudeValidationValue = 20;
%     end

    defAmplitudeValidationValue = defPeakThreshold / 750;
    %defAmplitudeValidationValue = defPeakThreshold / 100;
    
    if (defAmplitudeValidationValue > 200)
        defAmplitudeValidationValue = 200;
    end
    
    result = 0;

    
    %% Real Peak Finding
    tempPeakIndex = peakIndex;
    
    if (peakIndex > defRealPeakFindIndexCount)
        startIndex = peakIndex - defRealPeakFindIndexCount;
    else
        startIndex = 1;
    end
    
    for i =  startIndex: 1 : peakIndex + defRealPeakFindIndexCount
        if (ecgDataSet(i, 2) > ecgDataSet(tempPeakIndex, 2))
            tempPeakIndex = i;
        end
    end
    
    peakIndex = tempPeakIndex;
    
    %% Peak validation     
    if (peakIndex > defSearchIndexCount)
        startIndex = peakIndex - defSearchIndexCount;
    else
        startIndex = 1;
    end
    hit = 0;
    for i = startIndex : 1 : peakIndex
        if (ecgDataSet(i, 2) > ecgDataSet(peakIndex, 2))
            result = 1;
            break;
        end
        if (ecgDataSet(i, 3) < 0)
            hit = hit + 1;
        else 
            hit = 0;
        end
        if (hit > defMaxOppositeHittingCount)
            result = 2;
            break;
        end
    end
    hit = 0;
    for i = peakIndex + 1 : 1 : peakIndex + defSearchIndexCount
        if (ecgDataSet(i, 2) > ecgDataSet(peakIndex, 2))
            result = 3;
            break;
        end
        if (ecgDataSet(i, 3) > 0)
            hit = hit + 1;
        else 
            hit = 0;
        end
        if (hit > defMaxOppositeHittingCount)
            result = 4;
            break;
        end
    end
    
    %% Amplitude validation
    if (peakIndex > defAmplitudeValidationDistance)
        startIndex = peakIndex - defAmplitudeValidationDistance;
    else
        startIndex = 1;
    end
    if (ecgDataSet(peakIndex, 2) - ecgDataSet(startIndex, 2) < defAmplitudeValidationValue || ...
        ecgDataSet(peakIndex, 2) - ecgDataSet(peakIndex + defAmplitudeValidationDistance, 2) < defAmplitudeValidationValue)
            result = 5;
    end

    if (result ~= 0)
        peakIndex = 0;
    else
        value=0;
    end
   
end