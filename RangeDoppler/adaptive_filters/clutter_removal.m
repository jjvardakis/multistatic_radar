 function y=clutter_removal(s1,s2,nlag,Fs,dbins)
% Clutter removal with least squares filter
% 
% Parameters:
% s1: reference signal
% s2: surveilance signal
% nlag:length of least squares filter 
% Fs: input signal sample frequency
% dbins: list of doppler bins to do filtering on (default 0)
% 
% returns: y (surveillance signal with static echoes removed)

y=s2;
for k=1:length(dbins)
    ds=dbins(k);
    if(ds==0)
        M=LS_Filter(s1,y,nlag, 1);
    else
        s1s=frequency_shift(s1,ds,Fs);
        y= LS_Filter(s1s,y,nlag,.1);
    end
end
end