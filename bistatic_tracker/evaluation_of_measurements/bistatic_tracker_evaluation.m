% clc
clear all
close all
inputSampleRate=5000000;            % Sample rate
c=physconst('LightSpeed');                           % speed of light
channelFreq=[98.2e6;94.9e6];           % station frequency

addpath '..\bistatic_tracker\helperFunctions'
rng default
lamda=c./channelFreq;
CPI=1;
reps=60;
dplr_res=1/CPI;
range_res=c/(2e5);
sequential=1;
positions

tx=[tx_x,tx_y,tx_z];
rx=[rx1_x,rx1_y,rx1_z;
    rx3_x,rx3_y,rx3_z];

track=cell(size(rx,1),1);
str_tx=["malaxa","skloka"];



for rx_index=1:length(str_tx)
    temp=sprintf('F:/pass_radar/fm_working_tracker/track_%s_nn.mat', str_tx(rx_index));
    track{rx_index}=load(temp,'track_hist');
    hist_kf_out_nn{rx_index}=[];
    for k=1:size(track{rx_index}.track_hist,2)
        hist_kf_out_nn{rx_index}=[hist_kf_out_nn{rx_index} track{rx_index}.track_hist{k}.kalman_state.hist_kf_out];
    end
    temp=sprintf('F:/pass_radar/fm_working_tracker/track_%s_sn.mat', str_tx(rx_index));
    track{rx_index}=load(temp,'track_hist');
    hist_kf_out_sn{rx_index}=[];
    for k=1:size(track{rx_index}.track_hist,2)
        hist_kf_out_sn{rx_index}=[hist_kf_out_sn{rx_index} track{rx_index}.track_hist{k}.kalman_state.hist_kf_out];
    end
end

edit_tracker_data_and_evaluate
