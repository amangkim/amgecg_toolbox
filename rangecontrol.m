function [RChart] = rangecontrol(varargin)
% Generating the upper conotol unit and the valid index of [ld x 1]-R_data
%
% Usage:
%	[RChart (RC)] = rangecontrol(R_data, SigmaLevel, DispOptn)
%
% Output: RC
%   RC.UCL      : Upper Control Limit of R(or s) chart
%   RC.LCL      : Lower Contron Limit of R (or s) chart
%   RC.Idx      : Valid Index when the R is within the control limit;
%   RC.R_bar    : Mean of variances
%	RC.APR      : Accuracy Percentage within Ranges 
% Input:
%   R_data      : Variance measure (s, R or RR (Range Rate) ) [ld x 1]
%   SigmaLevel  : Sigma level of the control level (3 or 6)
%   DispOptn    : 1(On)-Show the graph 0-Off
% Note:
%   - Original m-code : sControl.m (v0.4)
%   - The analysis based on SPC (Normal distribution)
%   - If the ratio of valid data is less than 50 % will give the WARNING
%   - Default Sigma Level is 3
%   - It is targeted for [m x 1]-single range data
%	
% Made by Amang Kim [v0.6 || 2/23/2019]


% rangecontrol(SigmaLevel, R_data, DispOptn)
%-----------------------------
inputs={'R_data', 'SigmaLevel', 'DispOptn'};
SigmaLevel = 3;
DispOptn = 0;
R_data = [];

for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end

%-----------------------------
if isempty(R_data)
    R_data = 0;
    pause;
end


SigmaPortion = normcdf(SigmaLevel)-0.5;
R_cent = mean(R_data);
Valid_Idx =[];
%R_cent = mode (R_data);

ld = length (R_data);

UCL = R_cent + SigmaPortion * R_cent;
LCL = max (0, R_cent - SigmaPortion * R_cent);

%Valid_Idx = find (R_data<= UCL & R_data>=LCL);
Valid_Idx = find (R_data<= UCL);

if DispOptn == 1
    UCL_L = UCL * ones(1,ld);
    LCL_L = LCL * ones(1,ld);
    figure
    ax = gca;
    ax.YLim = [0 1.5*UCL];
    hold on
    title(['Range Chart (UCL= ' num2str(UCL) ', LCL= ' num2str(LCL) ')']);
    xlabel(['Number of Samples (' num2str(length(UCL_L)) ')']);
    ylabel('Range (Deviation)');    
    plot(UCL_L);
    plot(LCL_L);
    plot(R_data, '*');
    hold off    
end

RChart.UCL = UCL;
RChart.LCL = LCL;
RChart.Idx = Valid_Idx;
RChart.R_bar = R_cent;
RChart.APR = length(Valid_Idx)/ld;


if RChart.APR <= 0.5
    disp(['WARNING: The accuracy might not good enough for sampling processing......']);
    %[length(Valid_Idx) RChart.APR]
    %pause;
end

end

