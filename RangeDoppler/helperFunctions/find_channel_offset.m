function os=find_channel_offset(s1,s2,ndec)
%% check why uses lag
nl=25000;
B1=decimate(s1,ndec);
B2=decimate(s2,ndec);
[acor,xc]=xcorr(B1,B2,nl);
[~,max_value]=max(abs(acor));
os=(xc(max_value))*ndec;
% figure()
% plot(1:length(acor),abs(acor))
end