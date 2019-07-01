function [filteredsig, stm] = slicedmeanfilter(varargin)
% Providing the Weighted Distrbution filter based on the MSE between two signal
% Usage:
%    [filteredsig, filterpdf] = slicedmeanfilter(ECGdata, Freq, SliceTime, DispOptn)
% Output:
%   filterpdf   : Probability Distribution of Time Sliced Signal [m x 1]
%   filteredsig : The PDF filtered sliced signal [m x 1]
%   filterapr : APR of the probability distribution (PDF) filter
% Input:
%   SlicedSig  : Timesliced (ECG) Signal Data [m x 1] Matrix
%   RefSig     : Reference (mean) signal [m x 1]
% Note:
%   - Draft phases
%
% Made by Amang Kim [v0.1 || 2/22/2019]

%-----------------------------
inputs={'ECGdata', 'SampleFreq', 'SliceTime', 'DispOptn'};
DispOptn = 0;
SliceTime = 1;
SampleFreq = 400;

for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end

%-----------------------------

d0 = ECGdata;
sfq = SampleFreq;
d1= d0;


TS = timeslicedecg(SliceTime, d0, sfq, 0);
SData = TS.SlicedData;
[siglen, m] = size(SData);

MeanPlot = TS.MeanPlot;
validx = TS.RPeakIndex;
ld = TS.NumberofSlice;
%ld = length(validx);

for i = 1:ld
    d1([validx(i):validx(i)+siglen-1]) = MeanPlot(1:siglen);
end

stmsq = stmgen(sfq,0,d0);
%length(d1)

filteredsig = d1;
stm = stmsq;

if DispOptn == 1
    
	figure
    
    subplot(2,1,1);
    hold on
    grid on
    plot(stm, d0);
    title ('Original');
    hold off
    
    subplot(2,1,2);
    hold on
    grid on
    title ('SMD Filtered');
    plot(stm, d1);
    hold off

end


end