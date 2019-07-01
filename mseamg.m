function varargout = mseamg(varargin)
% Providing Mean Squeare Error and Square Error Array
% Usage:
%	[MSE SqError] = mseamg(Dataset1, Dataset2, PDF)
% Output:
% 	MSE         : The value of the MSE
% 	SqureError 	: [1xN] Square Error Array
% Input:
% 	Data1  & 2 	: Datasets to compare
%
% Note:
%   - Original file: rmser
%   - Required Matlab file(s): mean
%   - The size of data are aligned with the smaller one if these are different
%
% Made by Amang Kim [v0.4 draft|| 2/23/2019]


inputs={'Data1', 'Data2', 'PDF'};
outputs={'MSE0', 'SE'};

PDF = [];
MSE0=[];
SE=[];

for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end

[lo, m] = size(Data1);
lr = length(Data2);
datalen = min(lo, lr);
if lo ~= lr
	disp(['The length of data has been aligned to [' num2str(datalen) '] ......']); 
end

if isempty(PDF)
    PDF = 1/datalen*ones(datalen,1);
end

y0 = Data1(1:datalen,1:m);
y1 = Data2(1:datalen);

d0 = y0;
d1 = y1;

apr = sum(PDF);
sigma = (d0-d1).^2;
d2 = sigma.*PDF;

mse0 = sum(d2);

SE = sigma(:);
%SE = sigma;
MSE0 = mse0/apr;


for n=1:nargout
    eval(['varargout{n}=' outputs{n} ';'])
end
end

