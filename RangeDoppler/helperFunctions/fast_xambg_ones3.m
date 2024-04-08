function xambg=fast_xambg_ones3(ref,srv,nlag,nf,fs)
%% create range-doppler map from two signals

% input parameters:
%   ref,srv    input
%   nlag:      maximum lag between signals (samples)
%   nf  :      number of doppler bins to compute(should be power of 2)
%Returns:
%   xambg: (nf, nlag+1) matrix containing cross-ambiguity surface

if(size(ref)~=size(srv))
    print('oops');
    pause();
    
end

ndecim=floor(fs/nf);
% lpFilt = designfilt('lowpassfir', 'FilterOrder', 8, 'CutoffFrequency', ...
%                     512, 'PassbandRipple', 1, 'StopbandAttenuation', ...
%                     60, 'SampleRate', 1525);
% xambg=complex(double(zeros(nf,nlag+1,1)));
% maxlen = max(length(ref), length(srv));
% srv(end+1:maxlen)=0;
s2c=conj(srv);

% precompute FIR filter for decimation (all ones filter)

%dtaps= ones(1,ndecim+1);
  w = flattopwin(10*ndecim+1).';
%  w = hann(10*ndecim+1).';
 %w1=hamming(64,'symmetric');
% dfilt=fir1(10*ndecim,1./ndecim,w);
j=0;
%hpfilt=designfilt('highpassfir','FilterOrder',10,'StopbandFrequency',300,'SampleRate',fs);
for k=(-nlag+1:1)
    sd= circshift(s2c,k).*ref;
%     temp=resample(sd,1,ndecim,w).';
    temp=decimate(sd,ndecim,'fir').';
    %temp2=filter(lpFilt,temp);
    xambg(:,k+nlag,1)=temp(1:nf);
end

% xambg=lowpass(fftshift(fft(xambg,512,1),1),300,fs,'Steepness',0.5);
xambg=fftshift(fft(xambg,nf,1),1);

end
