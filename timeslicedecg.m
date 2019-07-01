function [TrainedStruct] = timeslicedecg(varargin)
% Slicing the ECG signal based on the slice time for using ML training
%
% Usage:
%	[Structred_Reference (SR)] = timesliceddecg(SliceTime, ECG_data, SampleFreq, CustFilter, DisplayOption)
% Output: 
%   SR.SampleFreq       : Sampling Frequency
%   SR.SliceWindow      : [StartTime EndTime]
%   SR.NumberofSlice    : Number of slicing
%   SR.SlicedData       : [MxN]-Matrix for N sliced samples
% Input:
%   SliceTime [sec]:    Time for slicing the data [sec]
%   ECG_data:           ECG data from ML training
%   SampleFreq:         Sampling frequency of ECG data
%   CustFilter:          Off (0) or Custnomized filter
%   Display Option:     [0 (Off), 1 (2D-plot), 3(3D-plot)]
% 
% Note:
%   - Original m-code: ecgsigsliceonly
%   - Required Matlab file(s): ECGtrainRegression, customfilter
%   - Adding the plotting feature
%   - Supporting 3D Plot option
%   - Revising the start index
%   - Allow the multiple input arguments
%	
% Made by Amang Kim [v0.1 || 2/23/2019]

%------------------------------------
inputs={'SliceTime', 'Sig_data', 'SampleFreq', 'DisplayOption'};
DisplayOption = 0;
SliceTime = 0;

for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end
%------------------------------------

if SliceTime == 0 
    SliceTime = 0.6;
end

d1=Sig_data;
f=SampleFreq;
a=Rpeakfind(0.6, f, d1);

stm = stmgen(f, 0, d1);
stm_len=length(stm);

WindowTime=[0:1/f:SliceTime];
win_slot=length(WindowTime);


dat4train=[];
Data4ML = [];
la=length(a(:,1));

slice_sq =[];
dat3D =[];

%--------------- Find the time index for the time window
cut_end_idx=find(abs(stm-SliceTime)<0.0001);
if isempty(cut_end_idx)
    cut_end_idx=mean(find(abs(stm-SliceTime)<0.01));
end
%--------- Adjusting the end of the signal
while a(la,2)+cut_end_idx >=length(d1)    
    la=la-1;    
end
%--------------------------------------------------------

slice_sq =[];

for i2=1:la %-----------------------------------------------------------------------------------
    st_idx=a(i2,2);
    if st_idx <=0
        st_idx =1;
    end
    
    dataidx=[st_idx:st_idx+win_slot-1];
    %dataidx(:)
    slicetime=WindowTime;
    slicedata=d1(dataidx);
    slicedata_w=slicedata;
       
	Data4ML = [Data4ML slicedata_w(:)];
    dat4train=[dat4train; [slicetime(:) slicedata_w(:)]];
    
    slice_sq =[slice_sq i2];
    
               
end	%-----------------------------------------------------------------------------------

MeanPlot = mean(Data4ML,2);

%---------------Diplay Option is ON
if DisplayOption==1
	figure;
    hold on
    grid on
    title('Regression Plot (2D)');
    xlabel('window time (s)');
    ylabel('ECG amplitude (mV or V)');
    plot(slicetime, Data4ML(:,1:la));
    plot(slicetime, MeanPlot, 'k.');
    hold off    
end


%---------------- 3D Display Option
if DisplayOption==3
    
    figure
    hold on
    grid on
    title('Regression Plot (3D)');
    xlabel(['Sliced Samples (' num2str(la) ')']);
    zlabel('ECG amplitude (mV or V)');
    ylabel('Window Time (sec)');
    surf (slice_sq, WindowTime, Data4ML);
    grid off
    hold off
    
end
%----------------------------------

%---------------------------------------
S.SampleFreq = f;
S.SliceWindow = [slicetime(1) slicetime(length(slicetime))];
S.NumberofSlice = la;
S.MeanPlot = mean(Data4ML,2);
S.SlicedData = Data4ML;
S.MLSet4Matlab = dat4train;
S.RPeakIndex = a(:,2);

TrainedStruct=S;
%---------------------------------------

end