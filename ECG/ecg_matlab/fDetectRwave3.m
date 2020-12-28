% fDetectRwave2.m
% Rajeev Agarwal
% Sept 22, 2016
% Given the EKG, Samling rate and the ppgVallye Locations tis function detects
% R-wave from the EKG
% Revision : Jan 31, 2017
% Modified the function to address several issues.
% 1. Input now is the raw acquired ECG waveform
% 2. Address delays in the detection point due to prefiltering
% 3. C

function [Rwave] = fDetectRwave3(DataInECG, Fs, DBG)
Rwave = [];

% Preprocessing: Filter the ECG signal 
% if the input ECG is not filtered then apply preprocessing before
% detecting QRSs (TBD). Can check the energy in the band of interest
% compared to total energy to verify preprocessing need

% Apply preprocessing. New preprocessing by applying a DC filter
DataECG = lFilterDC(DataInECG, 0.9, 'zero');
DataECG = fFilterLPF(DataECG, 2*20/Fs, 3, 'IIR', 'zero');

% Change the pre

% Compute the NLEO output for the ECG signal
[GnleoECG, NleoECG] =fSegmentCritNLEO(DataECG, 2*Fs, Fs, 0.9);
%[GnleoECG, NleoECGAbs] =fSegmentCritNLEO(abs(DataECG), 2*Fs, Fs, 0.9);

% Level 1 Detection
% PeakDetector to find all the peaks corresponding to the R-waves 
%  from the NLEO output of the ECG signal 
Reset = 0;
L = 0.2; L = fix(L*Fs + 0.5);
Rwave = fPeakDetector(NleoECG, L);
RwaveTmp1 = Rwave;


for iDbg = 1:1,
    if DBG,
        figure(96);clf
        h(1)  =  subplot(311);
        plot(DataInECG); hold on
        stem(Rwave, DataInECG(Rwave), 'g');
        h(2) = subplot(312);
        plot(DataECG); hold on;
        K = max(DataECG)/max(NleoECG);
        plot(K*NleoECG, 'r');
        stem(Rwave, K*NleoPkAmp, 'g');
        h(3) = subplot(313);
        plot(abs(DataECG)); hold on;
        K = max(DataECG)/max(NleoECGAbs);
        plot(K*NleoECGAbs, 'g');
        linkaxes(h, 'x');
    end
end
%*******************************************************************
% LEVEL 2 detection
% Remove all detections with too high NLEO Value (clear artifacts)
% USe statistics to isolate only the high amplidude peaks then use
% 5 to 95 percentile to reject the very high amplidude (spike noise
% detections).
if 0
    PRC99 = prctile(log10(NleoECG(Rwave)), 99.9);
    Index = log10(NleoECG(Rwave)) > PRC99;
    Rwave(Index) = [];
    NleoPkAmp(Index) = [];
    
    % Histogram of Rwave amplitude
    NleoPkAmp = log10(NleoECG(Rwave));
    [V, X] = hist(NleoPkAmp, 100);
    V = V/sum(V);
    
    % Find peaks in the NLEO PDF
    Pk = fPeakDetector(V, 3);
    
    % Find the threshold to separate the R wave from T-wave and other lower
    % amplitude peaks (i.e. P wave etc)
    [VMax, PkMax] = max(V(Pk));
    XMax = X(Pk(PkMax(1)));
    Pk2 = Pk; Pk2(PkMax) = [];
    [VMax2, PkMax2]  = max(V(Pk2));
    XMax2 = X(Pk2(PkMax2));
    Thresh = XMax2 +  (XMax-XMax2)/2;
    
    % Remove all detections that correspond too low amplidude (i.e., possbily
    % the T-wave detections
    RwaveTmp2 = Rwave(NleoPkAmp >= Thresh);
    % Figure 97
    for iDbg = 1:1,
        if DBG,
            figure(97); clf
            h97(1) = subplot(411);
            stem(Rwave, log10(NleoECG(Rwave))); hold on;
            stem(RwaveTmp2, log10(NleoECG(RwaveTmp2)), 'g');
            ylabel('NLEO QRS Peak')
            
            subplot(412);
            bar(X, V); hold on
            hline = plot(X, V, 'y', 'LineWidth', 2);
            v = axis;
            stem(X(Pk), V(Pk), 'r')
            stem(Thresh, v(4), 'g');
            ylabel('Rwave Amp PDF')
            
            
            subplot(413);
            bar(X, V); hold on
            hline = plot(X, V, 'y', 'LineWidth', 2);
            v = axis;
            stem(X(Pk), V(Pk), 'r')
            stem(Thresh, v(4), 'g');
            ylabel('Rwave Amp PDF')
            
            h97(2) = subplot(414);
            plot(DataECG); hold on
            plot(RwaveTmp2, DataECG(RwaveTmp2), '.k');
            ylabel('ECG')
            
            linkaxes(h97, 'x')
        end
    end
else
    % New idea use 5x below and 5x aboove the main peak in the NLEO amp
    % histogram. This assumes that no T-waves are detected. Contrary to the
    % previous idea
    
    % Histogram of NLEO peak amp
    NleoPkAmp = log10(NleoECG(Rwave));
    [V, X] = hist(NleoPkAmp, 100);
    %Vsmooth = fMeanBoxCar(V, 5,1);
    
    V = V/sum(V);

    % Find peaks in the NLEO PDF
    Pk = fPeakDetector(V, 1);

    % Find the main mode of the hist (i.e average peak amp)
    [VMax, PkMax] = max(V(Pk));
    XMax = X(Pk(PkMax(1))); VMax = VMax(1);
    
    % Low/Hi Amp thresh as 5 times the above an below the average of PDF
    ThreshLo = XMax - log10(5);
    ThreshHi = XMax + log10(5);
    
    %Figure 98
    if DBG, 
       figure(98); clf
       bar(X, V); hold on
       plot(X, V, 'y', 'LineWidth', 2);
       stem(X(Pk), VMax*ones(1,length(Pk)), 'r');
       stem([ThreshLo ThreshHi], VMax*[1 1], 'g', 'LineWidth', 2);
    end
    
    % Reject all detection not with the thresholds
    RwaveTmp2 = Rwave(NleoPkAmp >= ThreshLo & NleoPkAmp <= ThreshHi);
end
Rwave = RwaveTmp2;
% Figure 99
for iDbg = 1:1
    if DBG,
     figure(99); clf
     ax3(1) = subplot(211); plot(DataECG, 'g'); hold on
     plot(RwaveTmp2, DataECG(RwaveTmp2), 'g*'); v = axis;
     ylabel('ECG')
     ax3(2) = subplot(212); plot(NleoECG); hold on
     plot(RwaveTmp2, NleoECG(RwaveTmp2), 'm*'); v = axis;
     ylabel('NLEO (R-waves)')
     linkaxes(ax3, 'x');
    end
end

% ******************************
% LEVEL 3 detections 
% Try looking at the NLEO output to left and right (if < 0.20 of left and
% right averages then not valid)??
for iDbg = 1:1
if DBG,
    K = max(DataECG)/max(NleoECG);
    figure(3); plot(K*NleoECG, 'g'); hold on
    plot(DataECG);
    stem(Rwave, NleoECG(Rwave), '.k');
end
end

RlocTmp3 = Rwave;
Count = 0;
for iI = 3:length(Rwave)-2
     X = Rwave([iI-2 iI-1 iI iI+1 iI+2]);
     Bkgd  = mean(NleoECG(X([ 1 2 4 5])));
     if NleoECG(Rwave(iI)) < 0.2*Bkgd | NleoECG(Rwave(iI)) > 2*Bkgd ,
         if DBG,
             clc
             [iI  NleoECG(Rwave(iI)) 0.2*Bkgd Bkgd 2*Bkgd  ];
             [Rwave(iI)<0.2*Bkgd Rwave(iI)<1.2*Bkgd];
             xlim([X(1)-50,  X(end)+50]);
             pause
         end
         Count = Count +1;
         RlocTmp3(iI) = 0;
     end
end
RlocTmp3 = Rwave(Rwave>0);
Rwave = RlocTmp3;

%  display first level R-wave detections on the NLEO and ECG signals
% Figure 99
for iDbg = 1:1
    if (DBG)
     figure(99); clf
     ax1(1) = subplot(311);
     plot(DataECG); hold on; axis tight; vecg = axis;
     plot(Rwave, DataECG(Rwave), '*k')
     ax1(2) = subplot(312);
     plot(GnleoECG);
     ax1(3) = subplot(313); cla
     plot(NleoECG); hold on;
     plot(Rwave, NleoECG(Rwave),  '*k')
     linkaxes(ax1, 'x');
    end
end


%*****************************************************
% LEVEL 4 Template Detections
%  Validate each QRS detection with a temlate approach
N = 15; % number of beats in the template
twin =0.1;  % +/- seconds around the QRS detection for template generation
% Template the initital  gnerated based on the first N beats
[TemplateQRS, MeanHR, QRSArray] = lTemplateQRS(DataECG, twin, Rwave, 1, N, Fs);

Count = 0;
% Loop on beats 
T = fix(twin*Fs+0.5);
RwaveTmp4 = Rwave;
for iI = 1:length(Rwave)
     
     St = Rwave(iI)-T; 
     En = Rwave(iI)+T; 
     CandQRS = DataECG(St:En); 
     QPeak = fPeakDetector(CandQRS, 10);
     
     % Estimate the similarity between the current QRS a(CandQRS) and the
     % current QRS template
     %Rtmp = corrcoef(TemplateQRS, CandQRS); R(iI) = Rtmp(1,2);
     [Rtmp, Lag] = xcorr(TemplateQRS, CandQRS);
     [~, I] = max(Rtmp);
     % Shift the CandQRS such that the correlation with the template is
     % maximized. 
     Delay = Lag(I(1));
     if Delay < 0,
        CandQRS = CandQRS(abs(Delay)+1:end);
        CandQRS(length(TemplateQRS)) = 0;
     elseif Delay > 0, 
         CandQRS = [zeros(Delay, 1); CandQRS];
         CandQRS = CandQRS(1:length(TemplateQRS));
     end
     CandQRS = CandQRS(1:length(TemplateQRS));
     
     R(iI) = max(xcorr(TemplateQRS, CandQRS));
     Xtmp = corrcoef(TemplateQRS, CandQRS);  Rcoef(iI) = (Xtmp(1,2));
     %if R(iI) > 0.5 | Rcoef(iI) > 0.5,
     if  Rcoef(iI) > 0.5 & ~isempty(QPeak),
         Count  = 0;
         QRSArray(:,1) = [];
         QRSArray(:,N) = CandQRS;
         TemplateQRS = mean(QRSArray, 2);
         
         % Correct the Beat location of each beat (i.e. make sure that the
         % R-wave is detected and nto the the S wave.
         [MaxVal, Ind] = max(CandQRS(QPeak));
         RwaveTmp4(iI) = Rwave(iI) + (QPeak(Ind(1))-T-1) ;
         
     else
         RwaveTmp4(iI) = 0;
         Count = Count +1;
         [iI  Count R(iI)];
         %pause(2);
     end
     
     if DBG
          figure(101); clf
          plot(QRSArray); hold on;
          plot(TemplateQRS, '*k'); 
          plot(CandQRS, 'r.');
          title([' Count = ' num2str(Count)  ';    I = ' num2str(iI)  ';    Corrcoef = ' num2str(Rcoef(iI))]);
     end
     
     % Reset template
     if Count>5 & iI>N,
          [TemplateQRS, MeanHR, QRSArray] = lTemplateQRS(DataECG, twin, RlocTmp3, iI-N, iI,  Fs);
          Count = 0;
          Reset = Reset  +1;
     end
     % remove all non detected beats from current list of Rloc
end
RwaveTmp4 = Rwave(Rwave>0);

% Eliminate R-R that are too short
% RR= diff([0; Rwave]);
% RlocTmp = Rwave;
% Count = 0;
% for iBt = 2:length(Rwave)-1
%      % check to see if there is a significant disparity between two
%      % consectutive RRs
%      if RR(iBt)/RR(iBt-1) < 0.75,
%           if DataECG(Rwave(iBt)) < 0.5*DataECG(Rwave(iBt-1))  ...
%               & DataECG(Rwave(iBt)) < 0.5*DataECG(Rwave(iBt+1)) ,
%                RlocTmp(iBt) = 0;
%                Count = Count + 1;
%           else
%                %RlocTmp(iBt+1)  = 0;
%           end
%      end
% end

% Template based fine tuning
for iDbg = 1:1
    if DBG
        figure(102);
        axx(1) = subplot(311);
        plot(DataECG); hold on;
        plot(Rwave, DataECG(Rwave),  '*g'); hold on
        plot(RlocTmp4(RlocTmp4>0), DataECG(RlocTmp4(RlocTmp4>0)), 'ok');
        ylabel('ECG')
        axx(2) = subplot(312); cla
        plot(Rwave(RlocTmp4>0), R(RlocTmp4>0)  );; hold on
        plot(Rwave(RlocTmp4>0), Rcoef(RlocTmp4>0)  );; hold on
        ylabel('CC (template) + xcorr)')
        axx(3) = subplot(313);
        plot(NleoECG); hold on
        plot(Rwave, NleoECG(Rwave), '*g')
        ylabel('NLeo')
        linkaxes(axx, 'x')
    end
end
Rwave = RwaveTmp4;



% ****************************
%DataECG, twin, Rloc, 1,N,  FsBio
function [TemplateQRS, MeanHR,  QRSArray] = lTemplateQRS(DataECG, twin, Rloc, BeatStart, BeatEnd, Fs)
TemplateQRS = [];
Count = 0;
for iI = BeatStart: BeatEnd
    if 1  %Rloc(iI),
        St = Rloc(iI)-fix(twin*Fs+0.5);
        En = Rloc(iI)+fix(twin*Fs+0.5);
        Count = Count  +1;
        QRSArray(:,Count) = DataECG(St:En);
    end
end
TemplateQRS = mean(QRSArray, 2);
MeanHR = mean(diff(Rloc(BeatStart:BeatEnd)));
%TemplateQRS = TemplateQRS/std(TemplateQRS);

% DC Filter
function [Data] = lFilterDC(Data, ALPHA, PHASE)
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

