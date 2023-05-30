function [RevisedData, SampleTime, Freq] = sfqchanger(SourceFreq, OrignalSig, TargetFreq, DispOptn)
% Changing the sampling frequency of the signal
%
% Usage:
%    [RevisedData, SampleTime, Freq] = sfqchanger(SourceFreq, SourceSig, TargetFreq, DispOptn)
% Output:
%   RevisedData	: Revised signal after sampling frequency change
%   SampleTime  : Sampling time sequence aligned with the signal data
%   Freq        : Sample as the target frequency to change
% Input: 
%   SourceFreq  : Known frequency of the ECG data
%   SourcelSig 	: Original Signal to change the frequency
%   TargetFreq  : Target smapling frequency
%   DispOptn    : Ploting the comparison graphes between two signals
%
% Note:
%   - Required Matlab file(s): stmgen
%   - Source frequency must be aligned with the input signal
%   - Sampling time will start on 0 second 
%   - DispOptn: Display option for ploting [0 - Off, 1 - On]
%   - Changing to high frequency may occur the memory issue of your system
%
% Made by Amang Kim [v0.7 || 1/23/2019]


sfq0 = SourceFreq;
ecg0=OrignalSig;

[stm0, t0_ed]=stmgen(sfq0, 0, ecg0);
t0_sz=length(ecg0);

idx_b=[];
idx_0=[];
base_ref=[];

%------------ Target ECG data
sfq1=TargetFreq;
stm1 = stmgen(sfq1,t0_ed,0);
t1_sz=length(stm1);
ecg1=[];

%------------ Base (lcm) ECG data
sfq_b=lcm(sfq0,sfq1);
stm_b = stmgen(sfq_b, t0_ed, 0);
t_b_sz =length(stm_b);
ecg_b=zeros(t_b_sz,1);
%--------------------------------


[idx_0 idx_b]=find(abs(stm0(:)-stm_b(:)')<0.5/sfq0);

ecg_b([idx_b])=ecg0([idx_0]);

base_ref = [base_ref; [idx_b ecg_b(idx_b)] ];
base_len = length(idx_b);

for i=1:base_len-1
    st_idx=idx_b(i);
    ed_idx=idx_b(i+1);
    idx_num = ed_idx - st_idx -1;
    
    for j=1:idx_num
        ecg_b(st_idx+j)= ecg_b(st_idx)+(ecg_b(ed_idx)-ecg_b(st_idx))*(j/(idx_num+1));               
    end    
    
end


[idx_1 idx_bb]=find(abs(stm1'-stm_b)<0.5/sfq_b);
ecg1=ecg_b([idx_1]);

%------------ Return Value
Freq = sfq1;
SampleTime = stm1(:);
RevisedData =ecg1(:);
%-------------------------

%----- Comaprison Graph (Optional)
%figure
%hold on
%plot(stm0,ecg0);
%plot(stm1, ecg1);
%plot(stm_b,ecg_b);
%legend ('Original', 'Revised' , 'LCM');
%hold off
%----------------------

if DispOptn==1 %--------------------------------------------    
    figure
    
    subplot(2,1,1);
    plot(stm0, ecg0);
    title (['Original Signal(' num2str(sfq0) ' [Hz]), Size =' num2str(t0_sz-1)]);

    subplot(2,1,2);
    plot(stm1, ecg1, 'r');
    title (['Revised Signal (' num2str(sfq1) ' [Hz]), Size =' num2str(t1_sz-1)]); 
    
    %-------------------Demonstration Purpose
    figure
    hold on
    plot(stm_b, ecg_b, 'g');
    plot(stm0, ecg0, 'b');
    plot(stm1, ecg1, 'r');
    title (['Revised Signal (' num2str(sfq1) ' [Hz]), Size =' num2str(t1_sz-1)]); 
    hold off

end %------------------------------------------------------


end

