
function [ppgDataSet, slopeValueArray, slopeIndexArray, patArray] = f_PpgPeakDetector(ppgOriginalDataSet, defSampleRate, rrIndexArray, rrCount, defPPGDirection, defFilterSetting)
    if (defFilterSetting == 1)
        ppg_fir = fir1(30, [0.5/(defSampleRate/2), 5/(defSampleRate/2)], 'bandpass'); 
        %ppg_fir = fir1(1000, [20/(defSampleRate/2)], 'low'); 
    else
        ppg_fir = fir1(1000, [0.5/(defSampleRate/2), 5/(defSampleRate/2)], 'bandpass'); 
    end
    
    ppgDataSet(:,1) = ppgOriginalDataSet;
    ppgDataSet(:,2) = filtfilt(ppg_fir, 1, ppgDataSet(:,1));
    %ppgDataSet(:,2) = fFilterBPF(ppgDataSet(:,1), [0.5/150 5/150], 2);
    
    ppgDataSet(:,3) = vertcat(0, diff(ppgDataSet(:,2)));
    for i = 3:length(ppgDataSet)
        ppgDataSet(i,4) = ppgDataSet(i,3) - ppgDataSet(i-1,3);
    end
    for i = 4:length(ppgDataSet)
        ppgDataSet(i,5) = ppgDataSet(i,4) - ppgDataSet(i-1,4);
    end
    
%     ppgDataSet(:,7) = filtfilt(ppg_fir2, 1, ppgDataSet(:,2));
%     ppgDataSet(:,8) = filtfilt(ppg_fir2, 1, ppgDataSet(:,1));
    
    %% PPG Variable  
    if (defPPGDirection == 1)
        maxPPG1stValue = 9999;
        maxPPG2ndValue = 9999;
    else
        maxPPG1stValue = -9999;
        maxPPG2ndValue = -9999;
    end
    
    maxPPG1stIndex = 0;
    maxPPG2ndIndex = 0;
    
    peak1stStart = 0;
    peak1stEnd = 0;
    
    peak2ndStart = 0;
    peak2ndEnd = 0;
    
    ppgMaxSlopeIndex = zeros(rrCount, 1);
    ppgMaxSlopeValue = zeros(rrCount, 1);
    
    % PPG window size decide variable define
    % defPPGWindowMax = 0.5;
    
    % PPG 4th derivation direction decide counter
    % defPPGDirectionCounter = 20;
    
    %% PPG PeakDetect
    for ppgCount = 1:rrCount
        %% Finding derivation of PPG's 1st Peak point
        searchingStartPoint = rrIndexArray(ppgCount);
        
        if (ppgCount ~= rrCount)
            searchingEndPoint = rrIndexArray(ppgCount+1);
        else 
            searchingEndPoint = length(ppgDataSet);
        end
        
        %% Finding 1st minimum peak
        for index = searchingStartPoint:searchingEndPoint
            if (defPPGDirection == 1)
                if (maxPPG1stValue > ppgDataSet(index, 4))
                    maxPPG1stValue = ppgDataSet(index, 4);
                    maxPPG1stIndex = index;
                end
            else
                if (maxPPG1stValue < ppgDataSet(index, 4))
                    maxPPG1stValue = ppgDataSet(index, 4);
                    maxPPG1stIndex = index;
                end
            end
        end
        
        %% Finding 1st maximum peak START point
%         counter = 0;
        
        for index = maxPPG1stIndex:-1:searchingStartPoint
            if (defPPGDirection == 1)
                if (ppgDataSet(index, 5) > 0)
                    peak1stStart = index;
                    break;
                end
            else
                if (ppgDataSet(index, 5) < 0)
                    peak1stStart = index;
                    break;
                end                
            end
        end
        
         % Fail to find start point
        if (peak1stStart == 0)
            peak1stStart = searchingStartPoint;
        end
        
        %% Finding 1st maximum peak END point
%         counter = 0;
        
        for index = maxPPG1stIndex+1:searchingEndPoint
            if (defPPGDirection == 1)
                if (ppgDataSet(index, 5) < 0)
                    peak1stEnd = index;
                    break;
                end
            else
                if (ppgDataSet(index, 5) > 0)
                    peak1stEnd = index;
                    break;
                end
            end
        end
        
         % Fail to find end point
        if (peak1stEnd == 0)
            peak1stEnd = searchingEndPoint;
        end

        %% Finding 2nd maximum peak
        for index = searchingStartPoint:searchingEndPoint
            if (defPPGDirection == 1)
                if (maxPPG2ndValue > ppgDataSet(index, 4) && (index < peak1stStart || index > peak1stEnd))
                    maxPPG2ndValue = ppgDataSet(index, 4);
                    maxPPG2ndIndex = index;
                end
            else
                if (maxPPG2ndValue < ppgDataSet(index, 4) && (index < peak1stStart || index > peak1stEnd))
                    maxPPG2ndValue = ppgDataSet(index, 4);
                    maxPPG2ndIndex = index;
                end
            end
        end
        
        if (maxPPG2ndIndex == 0)
            maxPPG2ndIndex = searchingEndPoint; % END OF DATA
        end
        
        defPATmin = defSampleRate * 0.15;    % Define range of 2nd derivation of ppg peak
        defPATmax = defSampleRate * 0.35;    % Define range of 2nd derivation of ppg peak
        pat1stIndexCheck = 0;
        pat2ndIndexCheck = 0;

        if (defPATmin <= (maxPPG1stIndex - searchingStartPoint) && (maxPPG1stIndex - searchingStartPoint) <= defPATmax)
            pat1stIndexCheck = 1;
        end
        if (defPATmin <= (maxPPG2ndIndex - searchingStartPoint) && (maxPPG2ndIndex - searchingStartPoint) <= defPATmax)
            pat2ndIndexCheck = 1;
        end
        
        searchStop = 0;
        
        if (pat1stIndexCheck == 1 && pat2ndIndexCheck == 1)
            if (maxPPG1stIndex < maxPPG2ndIndex)
                searchingStartPoint = maxPPG1stIndex;
            else
                searchingStartPoint = maxPPG2ndIndex;
            end
        
        elseif (pat1stIndexCheck == 1 && pat2ndIndexCheck == 0)
            searchingStartPoint = maxPPG1stIndex;
            
        elseif (pat1stIndexCheck == 0 && pat2ndIndexCheck == 1)
            searchingStartPoint = maxPPG2ndIndex;
            
        else%if (pat1stIndexCheck == 0 && pat2ndIndexCheck == 0)
            %searchingStartPoint = rrIndexArray(ppgCount-1);
            searchStop = 1;
        end
        
        if (searchStop ~= 1)
            for index = searchingStartPoint:searchingEndPoint
                if (defPPGDirection == 1)
                    if (ppgDataSet(index, 4) > 0)
                        ppgMaxSlopeIndex(ppgCount, 1) = index - 1;
                        ppgMaxSlopeValue(ppgCount, 1) = ppgDataSet(index - 1, 3); 
                        break;
                    end
                else
                    if (ppgDataSet(index, 4) < 0)
                        ppgMaxSlopeIndex(ppgCount, 1) = index - 1;
                        ppgMaxSlopeValue(ppgCount, 1) = ppgDataSet(index - 1, 3); 
                        break;
                    end
                end
            end
        else
            if (defPPGDirection == 1)
                minPpgValue = 9999;
            else
                minPpgValue = -9999;
            end
            
            tempIndex = 0;
            for index = searchingStartPoint:searchingEndPoint
                if (defPPGDirection == 1)
                    if (ppgDataSet(index, 3) < minPpgValue)
                        minPpgValue = ppgDataSet(index, 3);
                        tempIndex = index;
                    end
                else
                    if (ppgDataSet(index, 3) > minPpgValue)
                        minPpgValue = ppgDataSet(index, 3);
                        tempIndex = index;
                    end
                end
            end
            ppgMaxSlopeIndex(ppgCount, 1) = tempIndex;
            ppgMaxSlopeValue(ppgCount, 1) = ppgDataSet(tempIndex, 3); 
        end

        if (ppgMaxSlopeIndex(ppgCount, 1) == 0)
            ppgMaxSlopeIndex(ppgCount, 1) = 0;
            ppgMaxSlopeValue(ppgCount, 1) = 30000; 
%             if (ppgCount + 2 < rrCount)
%                 ppgDataSet(rrIndexArray(ppgCount+2)-1, 6) = 30000;
%             else
%                 
%             end
            ppgDataSet(searchingEndPoint-1, 6) = 30000;
        else
            ppgDataSet(ppgMaxSlopeIndex(ppgCount), 6) = 30000;
        end
                
        if (defPPGDirection == 1)
            maxPPG1stValue = 9999;
            maxPPG2ndValue = 9999;
        else
            maxPPG1stValue = -9999;
            maxPPG2ndValue = -9999;
        end
        
        maxPPG1stIndex = 0;
        maxPPG2ndIndex = 0;
        
        peak1stStart = 0;   
        peak1stEnd = 0;

        
    end
     %% Slope Index Extract
    slopeIndexArray = zeros(rrCount, 1);
    slopeValueArray = zeros(rrCount, 1);
    slopeCount = 1;
    for i=1:length(ppgDataSet)
       if ppgDataSet(i,6) == 30000
           slopeIndexArray(slopeCount, 1) = i;
           slopeValueArray(slopeCount, 1) = ppgDataSet(slopeIndexArray(slopeCount, 1), 3);
           slopeCount = slopeCount + 1;
       end
    end
    
    %% Calculate PAT
    patArray = zeros(rrCount, 1);
    for i = 1:rrCount
        patArray(i, 1) = slopeIndexArray(i, 1) - rrIndexArray(i, 1);
    end
end