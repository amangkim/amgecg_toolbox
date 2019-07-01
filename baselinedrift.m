function [Adjusted_ECG] = baselinedrift(sfq, ECG_data, DispOptn)
% ECG baseline drift correction
%
% Usage:
%   Adjusted_Dat = baselinedrift(sfq, ECG_data, DispOpn)
% Output:
%	Ajusted_ECG : Adjusted ECG signals
% Input:
%      sfq      : Given sampling frequency [Hz]
%   ECG_data    : Original ECG data to be adjusted [mV]
%   DispOpn      : Display Option [Off (0) or On (1)]
% Note:
%   - Required Matlab file(s): polyfit
%   - Baseline adjustment by using Polynomial Curve Fitting
%   - Ploting the comparison between Orignal and Adjusted data
%   - Default order of coefficient (cof) = 10
%	
% Made by Amang Kim [v0.2 || 1/9/2019]
% Package of amgecg (Amang ECG) Toolbox [Rel Ver. 0.6 || 3/3/2019]


f=sfq;
d0=ECG_data(:);

%sig_len=length(d0);
[stm, stm_len]=stmgen(f,0,d0);

%stm=stm(1:length(stm)-1);
%stm_len=length(stm);


%---------------------------Polynomial curve fitting


cof = 10; %----- Default order of coefficient

%size(stm)
%size(d0)

[p,s,mu] = polyfit(stm,d0,cof);
f_y = polyval(p,stm,[],mu);
d1 = d0 - f_y;
disp(['Generating the adjust signal by using Polynomial curve fitting with ' num2str(cof) ' orders.....']);

Adjusted_ECG = d1;
%---------------------------------------------------


if DispOptn==1 %-----------------------------------
    figure
    
    subplot(2,1,1);
    hold on
    plot(stm, d0);
    plot(stm, f_y, 'r');
    title ('Original (Time)');
    hold off
    
    subplot(2,1,2);
    hold on
    plot(stm, d1);
    plot(stm, zeros(length(stm)),'r');
    title ('Basline Drifted');

end %----------------------------------------------


end

