parentDirectory = fileparts(cd);
addpath(genpath(parentDirectory));
clear all
close all
clc
%% Input options
blocksize=200000;
inputSampleRate=8000000;
inputCenterFreq= 104000000;
channelFreq= 106500000;
channelBW= 200000;
d=40;
M=64;
range_cells=25;
doppler_cells=512;
CPI=blocksize/(inputSampleRate/d);
freq_res=1/CPI;
%% Processing options
freq_shift=channelFreq-inputCenterFreq;
chunk_length=blocksize*2*d; %(CPI samples)*(decimate(10))*(2 floats/complex)
Fs=inputSampleRate;
fid1=fopen('lime_50db_104_8M_n14_obs.dat');
fid2=fopen('lime_45db_104_8M_n14_ref.dat');
start=1;
stop=100;
Fs_dec=Fs/d;
%lms and nlms and bnlms

w=complex(zeros(M,1));

% % fbnlms
w=complex(zeros(2*M,1));
u=complex(zeros(M,1));
% %
fseek(fid1,(start-1)*chunk_length*4,-1);
fseek(fid2,(start-1)*chunk_length*4,-1);
% % bnlms
% w=complex(zeros(M,1));
% u=complex(zeros(M,1));
ref_st=complex(zeros(M,1));
% XAMBG=complex(zeros(doppler_cells,range_cells,stop));
elapsed=0;
b=complex(zeros(1,blocksize));
rep = 0;
while 1
    rep = rep+1
    ftell(fid1)
    srv_dat1 = loadFile(fid1,(rep-1)*chunk_length+1,chunk_length).';
    ref_dat1 = loadFile(fid2,(rep-1)*chunk_length+1,chunk_length).';
    if size(ref_dat1,2)~=chunk_length/2
        save('wf.mat','XAMBG');
        break
    end
    % srv_dat1=srv_dat((rep-1)*chunk_length+1:(rep)*chunk_length,1);
    % ref_dat1=ref_dat((rep-1)*chunk_length+1:(rep)*chunk_length,1);
    
    %% Channel preprocessing
    % shift
    if( freq_shift~=0)
        ref_dat2=ref_dat1.*exp(-1i*2*pi*freq_shift*(1:length(srv_dat1))/Fs);
        srv_dat2=srv_dat1.*exp(-1i*2*pi*freq_shift*(1:length(ref_dat1))/Fs);
    end
    % decimate
    ref=decimate(ref_dat2,d);
    srv=decimate(srv_dat2,d);
    %% Channel offset compensation
%     s2o2=offset_compensation(ref,srv,1);
    % s2o2=offset_compensation(ref,s2o,1);
    
    %% filters
    
    tic;
    %  [SRV_CLEANzED,w]=bnlms(ref,s2o2,1024,1024,.2,.0005,w);
    [SRV_CLEANED,w,u]=fbnlms(ref,srv,M,M,0.05,0.9,w,u);
%         [SRV_CLEANED,w,ref_st]=nlms(ref,s2o2,M,.08,.0002,w,ref_st);
    %         [SRV_CLEANED,xhx]=clutter_removal(ref,s2o2,128,Fs_dec,[0]);
%             [A,beta]=clutter_removal(ref,srv,1014,Fs_dec,[0]);
        % ls_bins=[0 repelem([1:2],2)];
        % ls_bins(3:2:end)=-ls_bins(3:2:end);
        % SRV_CLEANED=clutter_removal(ref,srv,120,Fs_dec,ls_bins*freq_res);
    %                  [SRV_CLEANED,w,u]=fbnlms(ref,SRV_CLEANED,M,M,0.05,0.99,w,u);
    
    ii=1;
    % M(:,:)=A;
    % b(:,:)=beta;
    ii=ii+1;
    elapsed=elapsed+toc;
    %% Cross-ambiguity function
    % XAMBG(:,:,rep)=fast_xambg_ones(ref,SRV_CLEANED,300,512,Fs_dec);
    XAMBG(:,:,rep)=fast_xambg_ones3(ref,SRV_CLEANED,range_cells,doppler_cells,blocksize);
    %     energies(rep-start+1)=sum(sum((abs(XAMBG(:,:,rep).^2))));
    %     w_vect(:,rep)=w;
    %     energies(rep-start+1)
end

%% storing data
%    xam4=load('xambg7_wf_140720_350.mat');
% % %
%    XAMBG(:,:,1:start-1)=xam4.XAMBG(:,:,1:start-1);
%%
%
% $$e^{\pi i} + 1 = 0$$
%
% save('variables_M_b.mat','M','b');
save('wf_malaxa_2.mat','XAMBG');
% save('wf_nrgy_40','energies')