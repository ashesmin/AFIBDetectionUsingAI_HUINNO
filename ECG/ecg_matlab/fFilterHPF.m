%fFILTERHPF.M
% IMPLEMNT A BANDPASS DIGITAL FILETER WITH A GIVEN ORDER
% AND CUTOFF FREQUENCY
%function [Data] = f_filterhpf(Data, fc, order, phase)
% Data 		= input/output data
% fc			= cutoff frequency in Hz
% order		= filter order
% phase		= optional parameter, when selected to be 
%					"zero", applies a zero-phase filtering


function [Data] = fFilterHPF(Data, fc, order, FILTTYPE, PHASE)
% fc 		: 	lower upper cutoff frequency (normalized by fs/2)
% order 	:	filter order
% PHASE  : zero phase filtering or not
if (nargin ==3)
   FILTTYPE = 'IIR';
   PHASE = 'NONZEROPHASE';
elseif (nargin ==4)
   PHASE = 'NONZEROPHASE';
end

[m n] = size(Data);
if m==1 | n == 1,
    Data = Data(:);
    end


if max(fc) >= 1,
   disp('The cutoff frequency fc must be normalized to 0.0 < fc < 1.0')
   disp('where 1.0 corresponds to half the samplinfe rate, i.e.,')
end  

% Generate filter coefficients
if (strcmp(upper(FILTTYPE), 'FIR'))
   B= fir1(order, fc, 'high');
   A = 1;
else
   [B, A] = butter(order,fc, 'high');
end

[rsz csz]  = size(Data);
for ij = 1:csz
   % Filter using a cutoff frequencu of fcut Hz
   if (strcmp(upper(PHASE), 'ZERO') )
      Data(:,ij) = filtfilt(B ,A, Data(:,ij));
   else
      Data(:,ij) = filter(B ,A, Data(:,ij));
   end
end

