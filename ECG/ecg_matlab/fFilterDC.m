%fFilterDC.M
% IMPLEMNT A BANDPASS DIGITAL FILETER WITH A GIVEN ORDER
% AND CUTOFF FREQUENCY
%function [Data] = f_filterbpf(Data, fc, phase)
% Data 		= input/output data
% fc			= cutoff frequency in Hz
% phase		= optional parameter, when selected to be 
%					"zero", applies a zero-phase filtering


function [Data] = fFilterDC(Data, ALPHA, PHASE)
% fc 		: 	lower upper cutoff frequency (normalized by fs/2)
% order 	:	filter order
% PHASE  : zero phase filtering or not
if (nargin == 1)
     ALPHA = 0.9;
     PHASE = 'NONZEROPHASE';
elseif nargin == 2,
     PHASE = 'NONZEROPHASE';
end

[m n] = size(Data);
if m==1 | n == 1,
     Data = Data(:);
end

% Generate filter coefficients

[rsz, csz]  = size(Data);
for ij = 1:csz
   % Filter using a cutoff frequencu of fcut Hz
   if (strcmpi(upper(PHASE), 'ZERO') )
      Data(:,ij) = filtfilt([1 -1], [1 -ALPHA], Data(:,ij));
   else
      Data(:,ij) = filter([1 -1], [1 -ALPHA], Data(:,ij));
   end
end

