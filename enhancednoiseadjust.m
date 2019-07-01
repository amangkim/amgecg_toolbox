function [Ajusted_ECG] = enhancednoiseadjust(sfq, ECG_data, Display)
% Deliver the adjusted signals after noise frequency removing automatically
%
% Usage:
%	[Ajusted_ECG] = enhancednoiseadjust(sfq, ECG_data, DisplayOpn)
% Output:
%	Ajusted_ECG : Adjusted ECG signals
% Input:
%      sfq      : Given sampling frequency [Hz]
%   ECG_data    : Original ECG data to be adjusted [mV]
%   DisplayOpn  : Display Option [Off (0) or On (1)]
%
% Note:
%   - Original file: noiseadjust
%   - Required Matlab file(s): fft, ifft
%   - Reomve the noise frequency by using FFT
%   - Ploting the comparison between Orignal and Adjusted data
%   - Default cutoff ratio is 300 (times)
%   - Adding PLI remover (50/60 Hz) and Low Frequency range
%   
%	
% Made by Amang Kim [v0.2 || 2/13/2019]

f=sfq;
d0=ECG_data;
CutoffRatio = 300;
PLIFreq50 = 50;
PLIFreq60 = 60;

sig_len=length(d0);
[stm, stm_end]=stmgen(f,0,d0);


%------------------------------------------------------
d0_f = fft(d0);             % Compute DFT of x
d1_f=d0_f;
m0 = abs(d0_f);             % Magnitude

%------------------------------------------------------

Cut_m=CutoffRatio*mean(m0);
fq=(0:length(d1_f)-1)*f/length(d1_f);

%--------------------------- Removing Abnomal Frequency

Lower = find(m0>Cut_m)-length(d1_f)/sfq;
Upper = find(m0>Cut_m)+length(d1_f)/sfq;



IdxSet = [ceil(Lower) floor(Upper)];
[n ndummy] = size(IdxSet);


for k = 1:n
    if Lower(k)>0 && Upper(k)<= sig_len
        d1_f([IdxSet(k,1):IdxSet(k,2)])=0;
    end        
end

lowfq0 = [find(fq>0.1 & fq <0.9) find(fq>sfq-0.9 & fq <sfq-0.1)]; % 0.5 +- 0.4
lowfq = lowfq0;

%lowfq0 = [find(fq>0 & fq <0.2) find(fq>sfq-0.2 & fq <sfq)];
%lowfq1 = [find(fq>0.8 & fq <1.2) find(fq>sfq-1.2 & fq <sfq-0.8)];
%lowfq2 = [find(fq>1.8 & fq <2.2) find(fq>sfq-2.2 & fq <sfq-1.8)];
%lowfq3 = [find(fq>2.8 & fq <3.2) find(fq>sfq-3.2 & fq <sfq-2.8)];
%lowfq = [lowfq0 lowfq1 lowfq2 lowfq3];


pli1_50 = find(fq>(PLIFreq50-0.5) & fq <(PLIFreq50+0.5));
pli2_50 = find(fq>(sfq-PLIFreq50-0.5) & fq<(sfq-PLIFreq50+0.5));

pli1_60 = find(fq>(PLIFreq60-0.5) & fq <(PLIFreq60+0.5));
pli2_60 = find(fq>(sfq-PLIFreq60-0.5) & fq<(sfq-PLIFreq60+0.5));

d1_f(lowfq) = 0;
d1_f([pli1_50 pli2_50 pli1_60 pli2_60]) = 0;
d1_f(m0<1e-6) = 0;

%-------------------------------------------------------


m1=abs(d1_f);


%------------------------------------------------------
%d1= ifft(d1_f);
d1= real(ifft(d1_f));
Ajusted_ECG=d1;

%length(d1_f)
%length(d1)
%length(stm)


if Display==1 %--------------------------------------------
    figure
    
    subplot(2,2,1);
    plot(stm, d0);
    title ('Original (Time)');

    subplot(2,2,2);
    plot(stm, d1);
    title ('Noise Removed (Time)');

    subplot(2,2,3);
    plot(fq, m0);
    title ('Original (Freq)');
    ax = gca;
    ax.YLim = [0 max(m0)];
    ax.XLim = [0 sfq+10];

    subplot(2,2,4);
    plot(fq, m1);
    title ('Noise Adjusted (Freq)');
    ax = gca;
    ax.YLim = [0 max(m0)];
    ax.XLim = [0 sfq+10];

end %------------------------------------------------------



end

