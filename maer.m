function [MAER, AbsRange] = maer(varargin)
% Providing Mean Absolute Error Rate (MAER) based on the reference data
% Usage:
%	[MAER AbsRange] = maer(OriginalData, ReferenceData, PDF)
% Output:
% 	MAER 			: The value of the MAER
% 	AbsRange      	: Absolute distance between data and the reference
% Input:
% 	OriginalData 	: Original data set for MAER
% 	ReferenceData	: Reference data (i.e., mean) from the OriginalData
%   PDF             : Probability Distribution Filter
%
% Note:
%   - Original file: rmser
%   - Required Matlab file(s): mean
%   - The size of data are aligned with the smaller one if these are different
%
% Made by Amang Kim [v0.4b Draft|| 2/18/2019]


inputs={'OriginalData', 'ReferenceData', 'PDF'};
PDF = [];

for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end

[lo, m] = size(OriginalData);
lr = length(ReferenceData);
validx = [];

epsilon = 1e-6;

if lo ~= lr
	disp(['The length of data has been aligned to [' num2str(datalen) '] ......']); 
end

datalen = min(lo, lr);

if isempty(PDF)
    PDF = 1/datalen*ones(datalen,1);
end

y0 = OriginalData(1:datalen,1:m);
y_hat = ReferenceData(1:datalen,1);


sigma = abs(y0-y_hat);
y_hat(y_hat==0) = epsilon;
%s3C = rangecontrol(sigma);
%validx1 = s3C.Idx';
%validx2 = find(y_hat~=0)';
%validx = sortedshorten([validx1 validx2]);


%ErrRate = abs(sigma(validx)./y_hat((validx)));
ErrRate = abs(sigma./y_hat);
apr = sum(PDF);
MAER = sum(ErrRate)/apr;

AbsRange = ErrRate(:);
%AbsRange = ErrRate;

end
