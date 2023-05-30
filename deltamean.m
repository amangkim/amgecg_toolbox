function [meandelta,deltaset] = deltamean(n1_data)
% Calculating the Mean of the gap between data
%
% Usage:
%	[meandelta,deltaset] =  deltamean(Data)
%
% Output: 
%   meandelta   : Mean of data gap
%   deltaset    : The set of collecting gap between data
%
% Input:
%   Data        : Single lined data ([1xN] or [Nx1] data)
%
% Made by Amang Kim [v0.2 || 4/17/2019]
% Package of amgecg (Amang ECG) Toolbox [Rel Ver. 0.6 || 4/18/2019]



d0 = n1_data(:);

data_len = length(n1_data);
set_len = data_len-1;

delta = [];

for i = 1:set_len
    dk = d0(i+1);
    dk_1 = d0(i);
    delta0 = dk-(dk_1-1);
    
    delta = [delta delta0];
    
end


meandelta = mean(delta);
deltaset = delta;
end

