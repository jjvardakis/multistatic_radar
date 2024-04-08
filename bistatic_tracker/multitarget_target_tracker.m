close all
clc
clear all
c=physconst('LightSpeed');
temp_mat=[];
track_hist={};
parentDirectory = fileparts(cd);
addpath(genpath(parentDirectory));
addpath(parentDirectory)
addpath('/home/telecom/Desktop/passive_radar/detection')
addpath('/home/telecom/Desktop/passive_radar/misc')
addpath('/home/telecom/Desktop/passive_radar/main')
addpath('helperFunctions\')
xambg2=load("..\RangeDoppler\wf_malaxa_2.mat");
% xambg=abs(xambg.XAMBG)./mean(abs(xambg.XAMBG),'all');
xambg=abs(xambg2.XAMBG);
xambg=xambg./mean(abs(xambg),'all');

% TV settings
% Fs=8*10^6;
% CPI=.1;
% Fc=498*10^6;

% FM settings
Fs=2*10^5;
CPI=1;
Fc=106.5*10^6;

% Skloka
% baseline=9.7586e+03;

% Malaxa
baseline=7.2953e+03;

% Souda 107.3
% baseline=5.2742e+03;

range_res=physconst('LightSpeed')/(Fs);
dplr_res=1/CPI;

lambda=physconst('LightSpeed')/(Fc);
dplr_cells=size(xambg,1);
range_cells=25;
Nframes = size(xambg,3);
tracks_hist={};

% initiation logic
M=3;N=7;
gamma=16;
N_tracks=1; % number of maximum active tracks

% CFAR filtering
CF = zeros(size(xambg));
for i=1:Nframes
    CF(:,:,i) = CFAR(xambg(:,:,i), 20, 4, 3);
end
%% create track struct
active_track_num=0;
finished_track_num=0;
valid_meas=[];
measurement=[];
data = flipud(CF(:,end-range_cells:end,:));

for i=30:154
    i
    %% get measurements
    track_estimate=[];
    if(exist('tracks') )
        for k=1:size(tracks,2)
            if(~isempty(tracks{k}))
                track_estimate=[track_estimate tracks{k}.estimate];
            end
        end
    end
    [candidateRange,candidateDoppler,candidateStrength]=get_measurements(data,track_estimate,[range_res dplr_res],N_tracks,i,range_res,range_cells,baseline);
    if(length(candidateRange)>0)
        cRange=candidateRange;
        cDoppler=candidateDoppler;
        cStrength=candidateStrength;
        meas_matrix=[cRange cDoppler cStrength zeros(length(cStrength),1)];
        colorbar
        %%
        for k=1:active_track_num
            tracks{k}.assoc_cand=[];
        end

        %% categorize measurements
        j=0;
        for meas=1:size(meas_matrix,1)
            j=j+1;

            if(active_track_num<N_tracks)
                track_iters=active_track_num;
            else
                track_iters=N_tracks;
            end

            if(active_track_num>0)
                % First, the confirmed track ones
                for k=1:track_iters
                    if(tracks{k}.state==2)
                        if(early_gate_conf(tracks{k}.estimate,[meas_matrix(j,:)])) % keep only those that are within some Hz, range
                            tracks{k}.assoc_cand=[tracks{k}.assoc_cand; meas_matrix(j,:)];
                            meas_matrix(j,4)=1;
                        end
                    end
                end
                % Then, the preliminary track ones
                for k=1:track_iters
                    if(tracks{k}.state==1)
                        if(meas_matrix(j,4)==0 && early_gate_prel(tracks{k}.estimate,meas_matrix(j,:)))
                            tracks{k}.assoc_cand=[tracks{k}.assoc_cand; meas_matrix(j,:)];
                            meas_matrix(j,4)=1;
                        end
                    end
                end
            end
            % initiate new track with the measurement
            if(meas_matrix(j,4)~=1 && active_track_num<N_tracks)
                if(~exist('tracks','var'))
                    tracks=cell(1);
                    tracks{1}=initiate_track(meas_matrix(j ,:),N,lambda,CPI);
                    meas_matrix(j,4)=1;
                elseif(isempty(tracks))
                    tracks{1}=initiate_track(meas_matrix(j,:),N,lambda,CPI);
                    meas_matrix(j,4)=1;
                else
                    tracks{end+1}=initiate_track(meas_matrix(j,:),N,lambda,CPI);
                    meas_matrix(j,4)=1;
                end
                active_track_num=active_track_num+1;
            end

        end
        for k=1:active_track_num
            if(~isempty(tracks{k}.assoc_cand) )
                tracks{k}.init_vec=[tracks{k}.init_vec(2:end); 1];
            else
                if(tracks{k}.state==-1) % initiated now
                    tracks{k}.init_vec=[tracks{k}.init_vec(2:end); 1];
                else
                    tracks{k}.init_vec=[tracks{k}.init_vec(2:end); 0];
                end
            end
        end

        %% Confirmed tracks
        %  keep only measurements inside validation gate
        %  apply Kalman correction(if there is measurement) and prediction
        for k=1:N_tracks
            if(tracks{k}.state==2)
                valid_meas=[];
                measurement=[];
                if(~isempty(tracks{k}.assoc_cand))
                    valid_meas=val_gate(tracks{k}.assoc_cand,tracks{k},gamma);
                    measurement=assoc_meas(valid_meas,tracks{k},2); % 1. for NN 2. for SN 3. ...
                end
                [estimate,x_new]=kalman_filter(measurement,tracks{k},i);
                tracks{k}.kalman_state=x_new;
                tracks{k}.estimate=estimate;
            elseif(tracks{k}.state==1)
                valid_meas=[];
                measurement=[];
                if(~isempty(tracks{k}.assoc_cand))
                    valid_meas=val_gate(tracks{k}.assoc_cand,tracks{k},gamma);
                    measurement=assoc_meas(valid_meas,tracks{k},2); % 1. for NN 2. for SN 3. ...
                end
                [estimate,x_new]=kalman_filter(measurement,tracks{k},i);
                tracks{k}.kalman_state=x_new;
                tracks{k}.estimate=estimate;
            end
        end


        %% change states according to an M/N initiation logic
        for k=1:N_tracks
            if(tracks{k}.state==2)     % confirmed
                if(sum(tracks{k}.init_vec)>=M)
                    tracks{k}.state=2;
                else
                    tracks{k}.state=3;
                    finished_track_num=finished_track_num+1;
                    active_track_num=active_track_num-1;
                    track_hist{end+1}=tracks{k};
                    tracks(k)=[];
                end
            elseif(tracks{k}.state==1) % preliminary
                if(sum(tracks{k}.init_vec)>=M)
                    tracks{k}.state=2;
                elseif(sum(tracks{k}.init_vec)==0)
                    tracks{k}.state=0;
                    finished_track_num=finished_track_num+1;
                    active_track_num=active_track_num-1;
                    track_hist{end+1}= tracks{k};
                    tracks(k)=[];
                end
            else % free_ones
                if(sum(tracks{k}.init_vec)>=1)
                    tracks{k}.state=1;
                else
                    tracks{k}.state=0;
                    track_hist{end+1}=tracks{k};
                    tracks(k)=[];
                end
            end
        end
    end
    for k=1:active_track_num
        hold on
        centerRange=ceil(size(data,2))-1;
        centerDoppler=floor(size(data,1)/2);
        est=tracks{k}.kalman_state.x;
        rangeIndex=centerRange-round((est(1)-baseline)/range_res);
        dopplerIndex=round(est(3)/dplr_res)+centerDoppler;
        plot(dopplerIndex,rangeIndex,'*', 'MarkerSize',15,'MarkerEdgeColor','w');
        hold on
        rangeIndex2=centerRange-round((tracks{k}.estimate(1)-baseline)/range_res);
        dopplerIndex2=round(tracks{k}.estimate(2)/dplr_res)+centerDoppler;
        plot(dopplerIndex2,rangeIndex2,'+', 'MarkerSize', 5,'MarkerEdgeColor','g');
        if(~isempty(measurement))
            hold on
            rangeIndex1=centerRange-round((measurement(1)-baseline)/range_res);
            dopplerIndex1=round(measurement(2)/dplr_res)+centerDoppler;
            plot(dopplerIndex1,rangeIndex1,'+', 'MarkerSize', 5,'MarkerEdgeColor','r');
            if(~isempty(tracks{k}.assoc_cand))
                rangeIndex1=centerRange-round((tracks{k}.assoc_cand(:,1)-baseline)/range_res);
                dopplerIndex1=round(tracks{k}.assoc_cand(:,2)/dplr_res)+centerDoppler;
                plot(dopplerIndex1,rangeIndex1,'^', 'MarkerSize', 5,'MarkerEdgeColor','m');
            end
            legend('kalman output','measurement','kalman estimate')
        end
    end
    colorbar
    pause(0.01)
end
if(~isempty(tracks))
    track_hist{end+1}=tracks{k};
end
% track_hist=tracks(2);
save('..\bistatic_tracker\track_malaxa_011122','track_hist')


