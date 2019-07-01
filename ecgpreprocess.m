function [RevisedSig, Freq] = ecgpreprocess(Freq, Signal, PrOptn, DispOptn)
% Package for the pre-process for ECG signal authetification
% Usage:
%   [RevisedSig, Freq] = ecgpreprocess(Freq, Signal, PrOptn, DispOptn)
% Output:
%   RevisedSig  : Revised Signal
%   Freq        : Same as the original signal
% Input:
%   Freq        : Sampling frequency of the signal (should be aligned with the signal
%   Signal      : Signal data fore revised
%   PrOptn       : Options for ECG pre-process [Baseline Flip NoiseAdj]
%                 (0: OFF, 1: ON)   [1 0 0]: Basline ON, [0 0 1]: Noise Adjustment 
%   DispOptn    : Display option for signal adjustment [1:ON, 0:OFF]
%
% Note:
%   - Original file: prepropack
%   - Required Matlab file(s): baselinedrift, noiseadjust, pseudoflip
% 	- The set up of slicing is same as the setup of RefDBFreq
%   - RefDBFreq: Reference DataBase in Frequency Domain by ML
%   - Reference DB structure is designed by Amang Kim
%   
% Sponsored by Center on Cyber Physical Secuirty, KU
% Made by Amang Kim [v0.5 || 2/12/2019]


d0=Signal(:);
sfq = Freq;


%---------------------------------------------
d1 = d0;

if PrOptn (1) == 1
    d01 = baselinedrift(sfq,d0,DispOptn);
    d1 = d01;
end

if PrOptn (2) == 1
    d02 = pseudoflip(sfq, d1, DispOptn);
    d1 = d02;
end

if PrOptn (3)== 1
    d03 = enhancednoiseadjust(sfq, d1, DispOptn);    
    d1 = d03;
end



%---------------------------------------------

RevisedSig = d1;
Freq = sfq;

end

