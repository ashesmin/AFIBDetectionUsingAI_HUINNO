% fSegmentCritNLEO.M
%Author: Rajeev Agarwal
%Date: June 4, 2013
%[Gseg_crit] = fSegmentCritNLEO(Data, Step,WL)
% inp == the conditioned input data 
% step == number of steps to skip in moving the slidign windows
% WL == size of the sliding window for the reference and the test

function [Gnleo, Q] = fSegmentCritNLEO(inp, StepSize, WL, Alpha)

[rsz csz] = size(inp);
% NONLINEAR ENERGY OPERATOR
% Implement Nonlinear Energy Operator

for ij = 4:rsz
    Q(ij) = inp(ij-1)*inp(ij-2) - inp(ij)*inp(ij-3);
end

% Filter to remove the AC component from the
% output of NL OP.
Qf = filter([1 -1], [1 -Alpha],  Q);
Qdc = Q - Qf;

% Side by side sliding window
for ir = WL:StepSize:rsz-WL
    xsec1 = Qdc(ir-WL+1:ir);
    xsec2 = Qdc(ir+1:ir+WL);
    x1(ir) = mean(xsec1);
    x2(ir) = mean(xsec2);
end

% Final segment. crit.
Gnleo = abs(x1 - x2)';
Gnleo(rsz) = 0;


