function [ecg_data, sfq, time_sq] = loadecgamg(varargin)
% Usage:
%    [ecg_data, sfq, time_sq] = loadecgamg(filename, st_sec, ed_sec, DispOptn)
% Output:
%   ecg_data    : ECG data sequence
%      sfq       : Sampling Frequency
%   time_sq     : Sampling time sequence
% Input: 
%   Stucted ECG data 
%       Data.time
%       Data.ECG_data
%       Dara.freq
%   Start Time (>=0)
%   End Time (>StartTime)
%       [StartTime, EndTime]==[0,0] : Whole size of sequence
%   DispOptn: Display option for ploting
%
% Note:
%   - Original File: load_ecg_wo_flip
%   - The function is designed for the specific structure 
%   - The ECG data structure is desgined by Amang Kim
%   - Output has been rearranged
%   - Adjusting the end time if it is not applicable
% 
% Made by Amang Kim [v1.1 | 3/3/2019]
% Package of amgecg (Amang ECG) Toolbox [Rel. Ver. 0.6 || 3/3/2019]


%(filename, st_sec, ed_sec, DispOptn)

%-----------------------------
inputs={'filename', 'st_sec', 'ed_sec', 'DispOptn'};
DispOptn = 0;
st_sec = 0;
ed_sec = 0;

for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end
%-----------------------------

RECORD = filename;

data=load(RECORD);
sfq = data.freq;
d0=data.ECG_data;

[t,sig_ed]=stmgen(sfq,0,d0);


%sig_ed = floor(length(d0+1)/sfq);
%sig_ed = t(length(t));

if ed_sec <=0
    ed_sec=sig_ed;
else
    ed_sec = min (sig_ed, ed_sec);
end

disp(['Loading the record of ',RECORD,' between ',num2str(st_sec),' [sec] and ',num2str(ed_sec),' [sec]....']);
disp(['Finding the frequency is ',num2str(sfq),' [Hz] ......']);

%just a safety measure
if sfq == 0
  sfq = 1;
end

st_idx=min(find(abs(t-st_sec)<0.001));

if t(length(t))<ed_sec
    ed_idx=length(d0)-1;
else
    %ed_idx=find(t==ed_sec);
    ed_idx=min(find(abs(t-ed_sec)<0.001));    
end

if isempty(st_idx) 
    st_idx=1;
end

if isempty(ed_idx) || t(ed_idx)> ed_sec
    ed_sec = ed_sec-st_sec;
    t1=[0:1/sfq:ed_sec];
    ed_idx=length(t1);
    t=t1';    
end
disp(['Starting time is revised from ' num2str(t(st_idx)) ' [sec] to ' num2str(t(ed_idx)) ' [sec]...........']);


% --------------- len=(ed_idx-st_idx)+1;

ecg_data0=d0(st_idx:ed_idx);
time_sq0=t(st_idx:ed_idx);

if DispOptn == 1
    figure
    hold on
    title(['ECG signal from ' num2str(t(st_idx)) ' [sec] to ' num2str(t(ed_idx)) ' [sec].....']);
    xlabel('time (s)');
    ylabel('ECG amplitude (mV or V)');
    grid on
    plot(t, d0);
    hold off

end


ecg_data=ecg_data0(:);
time_sq=time_sq0(:);


end

