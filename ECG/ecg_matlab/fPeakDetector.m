%FPEAKDETECTOR.M
% [PeakLoc] = fPeakDetector(InpData, L);

% Given an input vector this function returns all the
% peak locations

function [PeakTroughLoc] = fPeakDetector(InpData, L, PeakTrough)
if nargin<3,
    PeakTrough = 'Peak';
end
PeakTroughLoc = [];

[r c]  = size(InpData);
if r == 1,
    InpData = InpData(:);
    [r c]  = size(InpData);
end
PeakLoc = [];
count = 0;
if strcmpi(PeakTrough, 'PEAK')
    
    for ij = L+1:r-L
        if ( 	InpData(ij)>=max(InpData(ij-L:ij-1)) && ...
                InpData(ij)>=max(InpData(ij+1:ij+L))	)            
            count  = count +1;
            if ij == 3209,
               % ij
            end
            PeakTroughLoc(count) = ij;
            if count > 1,
                if InpData(ij) == InpData(PeakTroughLoc(count-1)),
                    count = count -1;
                end
            end
        end
    end
else
    % find troughs in signal
    for ij = L+1:r-L
        if ( 	InpData(ij)<= min(InpData(ij-L:ij-1)) && ...
                InpData(ij)<=min(InpData(ij+1:ij+L))	)
            count  = count +1;
            PeakTroughLoc(count) = ij;
            if count > 1,
                if InpData(ij) == InpData(PeakTroughLoc(count-1)),
                    count = count -1;
                end
            end
        end
    end
end

% Create a a column vector
if ~isempty(PeakTroughLoc ),
    PeakTroughLoc = PeakTroughLoc(1:count);
    PeakTroughLoc = PeakTroughLoc(:);
else 
    PeakTroughLoc = [];
end
