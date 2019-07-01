function [Rpeak_Mat] = Rpeakfind(varargin)
%[Rpeak_Mat] = Rpeakfind(PeakLevel, sfq, ECG_dat, DisplayOption)
% Gives the R-peak index and values from ECG data
% Usage:
%        [Ann_Mat]= Rpeakfind(Level, freq, Local_ECG_dat, DispOptn)
% Ouput:
%         [Rpeak_Mat] (2xN Array) = [Value of Peak, Index of Peak]
% Input:
%   Level    :  Peak ratio
%    sfq     :  Sampling frequency
%   sig_dat  :  Gathered ECG data (1xN Data)
%	DispOptn :  Display Option [0 (Off), 1 (On)]
%
% Note:
%   - Original Matlab file: Rpeakdect
%   - Adding for ploting the signal (with grid on)
%
% Made by Amang Kim [v0.91 || 1/17/2019]

%(Level, sfq, sig_dat, DispOptn)
%------------------------------------
inputs={'Level', 'sfq', 'sig_dat', 'DispOptn'};
DispOptn = 0;
Level = 0.65;
for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end
%------------------------------------


d0=sig_dat;
[stm, stm_ed] = stmgen(sfq,0,d0);
sig_len=length(stm);

PeakLevel=Level;

NoiseRatio = 0.2;
ConfidentLevel = 1-NoiseRatio; % This value indicates that how much the signal is clean

MinofPeak=floor(stm_ed*ConfidentLevel);
MaxofPeak=(5/3)*stm_ed; % Average beat rate for normal person is 60 - 100 [BPM]


Rpeak_Mat=[];
RR_Peak=0;
ECG_Idx=0;
ECG_len=length(d0);

a_idx=find(d0>=PeakLevel*max(d0));
a_d=d0(a_idx);
Threshold=mode(a_d);

Adj_Idx=0;

RR_peak=floor(sfq/2);
Loop_len=floor(ECG_len/RR_peak);

for i=1:Loop_len
    [R_peak ECG_Idx]=max(sig_dat((i-1)*RR_peak+1:(i)*RR_peak));
    if (ECG_Idx>0)                             %Avioid error in case of the index value is zero
        if(R_peak>=Threshold)
            Adj_Idx=ECG_Idx+(i-1)*RR_peak-1;
            Rpeak_Mat=[Rpeak_Mat; [R_peak Adj_Idx]];
            %pause;            
        end
    end
end

[a_m a_n]=size(Rpeak_Mat);
    %pause;
 if (a_m<MinofPeak)
    disp(['The number of R-peaks (' num2str(a_m) ') which is smaller than the threshold (' num2str(MinofPeak) ').......'])
    %pause;
    Peak_Rev=PeakLevel*0.9;
    Rpeak_Mat=Rpeakfind(Peak_Rev, sfq, sig_dat,0);
 end
 disp(['Finding total ' num2str(a_m) ' R-peaks on the signal........']);
 if DispOptn == 1
     figure
     hold on
     title (['Ploting ECG with R-R Peaks (' num2str(a_m) ')']);
     xlabel('sampling time (s)');
     ylabel('ECG amplitude (mV or V)');
     %grid on
     plot (stm,d0);
     plot(stm(Rpeak_Mat(:,2)+1), d0(Rpeak_Mat(:,2)+1), 'm*');
     %grid off
     hold off 
 end
 return;
 
end


