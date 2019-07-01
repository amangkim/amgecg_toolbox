function [Sig, offset] = pseudoflip(sfq, Sig_data, DispOptn)
% Return the flipped signal and offset for flipping status
%
% Usage:
%	[ECG_sig,offset] = pseudoflip(sfq, ECG_data, DispOptn)
% Output:
%   Sig 	: Return the flipped (or original) ECG signals
%   offest  : Return either [1: Normal] or [-1: Flipped]
% Input:
%      sfq      : Given sampling frequency [Hz]
%   Sig_data    : Original ECG data to be adjusted [mV]
%   DisplayOpn  : Display Option [Off (0) or On (1)]
%
% Note:
%   - Original file: ECGflip
%   - Simplified method for flipping signal
%   - It may not accurate because it is 'pseudo'
%   - Display option is applied only if the signal is flipped
%   - Ploting the comparison between Orignal and Flipped data
%   - Revise for determine the baseline and flipping values
%	
% Made by Amang Kim [v0.9 | 2/3/2019]


f=sfq;
d0=Sig_data;

sig_len=length(d0);
[stm, stm_end]=stmgen(f,0,d0);

% ---------------- Checking for flipping signals -------
st_idx=1;                           % Check the peak beginning of the signal
ed_idx=floor(0.2*(sig_len));        % Up to 10 frequency

d00 = d0(st_idx:ed_idx);
dp = d00(d00>=0);
dm = d00(d00<0);
%dp = d00(d00>=0.4*max(d00));
%dm = d00(d00<0.4*min(d00));


base = mean(d00);
E0_max=abs(mean(dp)+base);
E0_min=abs(mean(dm)+base);


if abs(E0_max)<=abs(E0_min)
    offset = -1;
    disp('The ECG signal has been flipped ..................');    
else
    offset = 1;
    disp('The ECG signal is NOT flipped ..................');
end
% ------------------------------------------------------
d1=offset*d0;

if DispOptn ==1 && offset == -1
%if  offset == -1
    
    figure
   
    subplot(2,1,1);
    plot(stm, d0);
    title ('Original (Time)');

    subplot(2,1,2);
    plot(stm, d1);
    title ('Flipped Signal (Time)');


end

Sig=d1;

end

