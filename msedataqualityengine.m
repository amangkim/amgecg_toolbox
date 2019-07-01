function [Structed_DQ_Set] = msedataqualityengine(varargin)
% Engine for evaluating the ECG data quality
%
% Usage:
%	[Structed_DataQuality_Set (SDQS)] = dataqualityengine(DBpath, FileRecord, SampleTime, SliceTime, SigmaLevel)
%
% Output: SDQS
%   SDQS.DBPath         :   ECG DB path
%   SDQS.Freq           :   Sampling Frequency
%   SDQS.SampleTime     :	[0 SampleTime];
%   SDQS.SliceTime  	:	[0 SliceTime];
%   SDQS.NumofSlice     :   Number of Slice 
%   SDQS.NumberofRecord :	Number of Record (Samples);
%   SDQS.FileRecord 	:   FileRecord;
%   SDQS.MAER           :   Mean of MAER for each record;
%   SDQS.APR            :   Accuracy Percentatage within Range;
%   SDQS.APU            :   APR per UCL;
%   SDQS.UCL            :   Upper Control Limits;
%
% Input:
%   DBpath      :  Path of ECG database (either local or webDB) ['String']
%   FileRecord  :  The set of file names to be trained [1 x N]
%   SampleTime  :  Sampling Time [sec] [1 x 1]
%   SliceTime   :  Time for slice (template size) [1 x 1]
%   SigmaLevel 	:  Sigma Level for Range Control
%
% Note:
%   - Original file: refgentime
%   - Required Matlab file(s): ECGslice_time, loadecgamg, baselinedrift, noiseadjust, Rpeakfind
%   - SampleSize = length (FileRecord)
%   - The reference is generated in the time domain
%   - Adding the accuracy rate of RMSER 
%   - Updating the reference ECG set structure
%   - Sigma level for the input parameter
%   - The data quality based on MSE (Mean Square Error)
%	
% Made by Amang Kim [v0.4a || 3/3/2019]

%-----------------------------
%(DBpath, FileRecord, SampleTime, SliceTime, SigmaLevel)
inputs={'DBpath', 'FileRecord', 'SampleTime', 'SliceTime', 'SigmaLevel'};
SigmaLevel = 3;
SliceTime = 1;
SampleTime = 20;

for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end

%----------------------------



%----------------------------------
SamplePath = DBpath;
StartTime = 0;
EndTime = SampleTime; 	% Sample time for generating [Sec]
NumofId = length(FileRecord);
%----------------------------------

PeakRatio = 0.6;

%----------------------------------

%---------------- Initial Output Setup (old)
ref_dat=[];         % Reference Matrix
TrainRMSE=[];       % RSME 
BaseF=[];
ID_str0=[];
pre_idx=0;

minRMSER = [];
maxRMSER = [];

PDFSet =[];

%------------------------ Initial Output Setup
FileRecord =FileRecord;
MSEBar = [];
APR = [];
UCL = [];
APU = [];
LCL = [];
%--------------------------------------------



for i1=1:NumofId %-----------------------------------------------

    DB0_Idx = FileRecord(i1);
    DB0_str = num2str(DB0_Idx);
    SampleName=[SamplePath DB0_str '.mat'];
    disp (['Training the data of [' DB0_str ']...........']);
        
    [d0, sfq] = loadecgamg(SampleName,StartTime,EndTime,0);
    
    d1 = ecgpreprocess(sfq, d0, [1 1 1], 0);    
    
    TS = timeslicedecg(SliceTime, d1, sfq);
    dm = TS.SlicedData;
    TestingECG = TS.MeanPlot;
    WindowTime = TS.SliceWindow(2); 
    stm = stmgen(sfq,WindowTime);
    cut_end_idx_r=length(stm);
    
    [mse0, SE00] = mseamg(dm, TestingECG);
    %[mse0, SE00] = maer(dm, TestingECG);
    %[maer0, AER00] = ;
    

%sC3 = rangecontrolmulti(mse0);
sC3 = rangecontrol(SE00);
%-----------------------------
MSE0 = mean (mse0);
APR0 = sC3.APR;
UCL0 = mean(sC3.UCL);
LCL0 = mean(sC3.LCL);

MSEBar = [MSEBar MSE0];
APR = [APR APR0];
UCL = [UCL UCL0];
LCL = [LCL LCL0];
APU = [APU APR0/UCL0];
%-----------------------------

end %----------------------------------------------------- 

%------------------------------------------------
SDQS.DBPath = SamplePath;
SDQS.Freq = sfq;
SDQS.SampleTime = [0 SampleTime];
SDQS.SliceTime = [0 SliceTime];
SDQS.NumofSlice = TS.NumberofSlice; 
SDQS.NumberofRecord= NumofId;
SDQS.FileRecord = FileRecord;
SDQS.SigmaLevel = SigmaLevel;
SDQS.MSE = MSEBar;
SDQS.min_mean_Max_MSE_APR = [min(APR) mean(APR) max(APR)];
SDQS.min_mean_Max_MSE_APU = [min(APU) mean(APU) max(APU)];
SDQS.min_mean_Max_MSE_UCL = [min(UCL) mean(UCL) max(UCL)];

SDQS.FullReport = [FileRecord(:) APR(:) APU(:) UCL(:)];
%------------------------------------------------


Structed_DQ_Set = SDQS;


end % © 2019 GitHub, Inc.