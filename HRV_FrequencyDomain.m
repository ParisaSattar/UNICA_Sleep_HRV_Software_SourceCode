function [aVLF, aLF, aHF, nLF,nHF,lfhf]=HRV_FrequencyDomain(RpkLoction,RR_intervals,fs)
global Pxx F

RR_index = (RpkLoction(1:end-1)-1)/fs;
% Calculating time for RR intervals data interpolation 
Fs_new=4;
time=RR_index(1):1/Fs_new:RR_index(end);
time=time';
% Interpolating RR intervals for frequency domain analysis
RR_intervals=((RR_intervals)/fs)*1000;
RR_intervals_Interpolated = interp1(RR_index,RR_intervals,time,'spline');
RR_intervals_Interpolated=detrend(RR_intervals_Interpolated,'linear');
RR_intervals_Interpolated=RR_intervals_Interpolated-mean(RR_intervals_Interpolated); %detrend is necessary to otain the trend 

%for pwelch
%w=length(RR_intervals_Interpolated)/2;
w=length(RR_intervals_Interpolated)/2;
%nfft = max(length(RR_intervals_Interpolated),2^nextpow2(length(w)));
nfft=512;
noverlap = round(w/2);
[Pxx, F]=pwelch(RR_intervals_Interpolated,w,noverlap,nfft,Fs_new);


% Defining band frequency
VLF = [0.0033 0.04];
LF = [0.046 0.158];
HF = [0.158 0.400];


% find the indexes corresponding to the VLF, LF, and HF bands
iVLF= (F>=VLF(1)) & (F<=VLF(2));
iLF = (F>=LF(1)) & (F<=LF(2));
iHF = (F>=HF(1)) & (F<=HF(2));
 
% % calculate power, within the freq bands (ms^2)
aVLF=trapz(F(iVLF),Pxx(iVLF));
aLF=trapz(F(iLF),Pxx(iLF));
aHF=trapz(F(iHF),Pxx(iHF));
aTotal=trapz(F,Pxx); % try this one
%aTotal=aVLF+aLF+aHF;   

% %calculate power relative to the total power (%)
pVLF=(aVLF/aTotal)*100;
pLF=(aLF/aTotal)*100;
pHF=(aHF/aTotal)*100;

% %calculate normalized areas (relative to HF+LF, n.u.)
nLF=aLF/(aTotal-aVLF);
nHF=aHF/(aTotal-aVLF);
%nulfhf=nLF/nHF;

% %calculate LF/HF ratio
lfhf =nLF/nHF;
% plfhf =pLF/pHF;
% vlflf =aVLF/aLF;
RR_intervals=(RR_intervals*fs)/1000;
end