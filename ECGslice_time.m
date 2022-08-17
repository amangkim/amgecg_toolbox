function [TrainedStruct] = ECGslice_time(SliceTime, ECG_data, SampleFreq, CustFilter, DisplayOption)
% Generating the regference ECG signal by using ML
%
% Usage:
%	[Structred_Reference (SR)] = ECGslice_time(SliceTime, ECG_data, SampleFreq, FilterID, DisplayOption)
% Output: 
%   SR.SampleFreq:      Sampling Frequency
%   SR.NumberofSlice:   Number of slicing
%   SR.SliceWindow:     Sampling Time sequence
%   SR.RefData:         Base ECG data for the reference
%   SR.TrainData:       [[Time ECG]; Nx2] Training data
%   SR.RefFcn:          Regression Function with the time variables
% Input:
%   SliceTime [sec]:    Time for slicing the data [sec]
%   ECG_data:           ECG data from ML training
%   SampleFreq:         Sampling frequency of ECG data
%   Filter ID:          Off (0) or ID# of applying the filter
%   Display Option:     [0 (Off), 1 (2D-plot), 3(3D-plot)]
%
% Note:
%   - Required Matlab file(s): ECGtrainRegression
%   - Adding the plotting feature
%   - Supporting 3D Plot option
%   - MSE of the data is included (SR.MSE)
%   - Revising the start index
%	
% Made by Amang Kim [v0.51 || 7/31/2022]


d1=ECG_data;
f=SampleFreq;
a=Rpeakfind(0.8, f, d1,0);

stm = stmgen(f, 0, d1);
stm_len=length(stm);

WindowTime=[0:1/f:SliceTime];
win_slot=length(WindowTime);

dat4train=[];
la=length(a(:,1));

slice_sq =[];
dat3D =[];

%--------------- Find the time index for the time window
cut_end_idx=find(abs(stm-SliceTime)<0.0001);
if isempty(cut_end_idx)
    cut_end_idx=mean(find(abs(stm-SliceTime)<0.001));
end
%--------- Adjusting the end of the signal
while a(la,2)+cut_end_idx >=length(d1)
    la=la-1;
end
%--------------------------------------------------------

%---------------Diplay Option is ON
if DisplayOption==1
	figure;
    hold on
    grid on
    title('Machine Learning Plot');
    xlabel('window time (s)');
    ylabel('ECG amplitude (mV or V)');    
end
%----------------------------------


for i2=1:la %-----------------------------------------------------------------------------------
    st_idx=a(i2,2);
    if st_idx <=0
        st_idx =1;
    end
    
    dataidx=[st_idx:st_idx+win_slot-1];
    slicetime=WindowTime;
    slicedata=d1(dataidx);

    %--------------------- Applying the customized filter
    if CustFilter ==0
        slicedata_w=slicedata;        
        %datasliced_w=weibullfilter(dataframed(:));
    else
        slicedata_w=usefilter(CustFilter, slicedata(:));
    end
    %----------------------------------------------------
       
	dat4train=[dat4train;[slicetime(:) slicedata_w(:)]];
    
    %---------------Diplay Option is ON
    if DisplayOption==1
        plot(slicetime, slicedata_w,'Color',[i2/(la*1.0003) i2/(la*1.01) i2/(la*1.05)]);
    end
    if DisplayOption == 3
        slice_sq =[slice_sq i2];
        dat3D(:,i2) = slicedata_w(:);
    end
    %----------------------------------
               
end	%-----------------------------------------------------------------------------------


%--------------------- Regression Model
[RefModel, RMSE_bar]= ECGtrainRegression(dat4train);
ref_plot=RefModel.predictFcn(slicetime(:));
MSE0 = RMSE_bar^2;
%--------------------------------------

%---------------Diplay Option is ON
if DisplayOption==1
    plot(WindowTime,ref_plot,'r.-');
    hold off
end
%---------------- 3D Display Option
if DisplayOption==3
    dat3D(:,la+1) = ref_plot(:);
    slice_sq =[slice_sq la+1];
    
    figure
    hold on
    %xlabel(['sliced samples (' num2str(la) ')']);
    grid on 
    xlabel('sliced samples');
    zlabel('ECG amplitude (mV or V)');
    %ylabel(['Window Time (' num2str (WindowTime) '[sec])']);
    ylabel('Window Time (sec)');
    surf (slice_sq, WindowTime, dat3D);
    grid off
    hold off
    %mesh(dat3D);
end
%----------------------------------

%---------------------------------------
S.SampleFreq = f;
S.NumberofSlice = la;
S.SliceWindow = slicetime;
S.RefData = ref_plot;
S.TrainData = dat4train;
S.RefFcn = RefModel.predictFcn;
S.MSE = MSE0; 

TrainedStruct=S;
%---------------------------------------

end

