clc
clear all
close all
inputSampleRate=8000000;            % Sample rate
c=physconst('LightSpeed');                           % speed of light
channelFreq=106e6;                 % station frequency
% range_res=c/(8e6);
addpath('E:\pass_radar\Copy_2_of_tracker')
rng default
lamda=c/channelFreq;CPI=1;
dplr_res=1/CPI;
sequential=1;
positions

tx=[tx_x,tx_y,tx_z];
rx=[rx1_x,rx1_y,rx1_z;
    rx2_x,rx2_y,rx2_z;
    rx3_x,rx3_y,rx3_z;];
track=cell(size(rx,1),1);
str_tx=["malaxa","skloka","souda"];
for rx_index=1:length(str_tx)
    temp=sprintf('E:/pass_radar/fm_working_tracker/track_%s_051022.mat', str_tx(rx_index));
    track{rx_index}=load(temp,'track_hist');
    hist_kf_out{rx_index}=[];
    for k=1:size(track{rx_index}.track_hist,2)
        hist_kf_out{rx_index}=[hist_kf_out{rx_index} track{rx_index}.track_hist{k}.kalman_state.hist_kf_out];
    end
end

edit_tracker_data

plot_ellipses
% initiation logic
M=4;N=5;N_tracks=1; % number of maximum active tracks
active_track_num=0;
finished_track_num=0;
valid_meas=[];
meas_3d=[];

track_length=length(hist_kf_out{3});
t=0;
measurements_hist=[];tracks=[];
while(t<track_length)   % track{station}.tracks{numOfTrack}
    t=t+1
    measurements=cell(size(rx,1),1);
    meas_matrix=[];
    %% localization procedure
    % run SX method for each triplet of measurements
    % and generate localization points
    for i=1:size(rx,1)    % get all measurements at time t
        measurements{i}=[hist_kf_out{i}(1,t) hist_kf_out{i}(2,t) hist_kf_out{i}(3,t)];
    end
    measurements_hist=[measurements_hist;cell2mat(measurements)];
    % if we assume there is only one target or three measurements
    % then we perform SX directly
    [sx_plus,v_plus,sx_minus,v_minus,~,~]=SX(measurements,rx);
    if(~isnan(sx_plus))
        stem3(sx_plus(1),sx_plus(2),sx_plus(3),'x','MarkerSize',10,'LineStyle','none')
    elseif(~isnan(sx_plus))
        stem3(sx_minus(1),sx_minus(2),sx_minus(3),'x','MarkerSize',10,'LineStyle','none')
    end
    hold on
    if(~isempty(tracks))
        stem3(tracks{1}.kalman_state.x(1),tracks{1}.kalman_state.x(3),tracks{1}.kalman_state.x(5),'o','MarkerSize',10,'LineStyle','none')
    end
    % in any other case one should perform the localization
    % separately for each triplet and generate list of target points
    % filter out the negative altitudes or complex values
    if(t==1)
        if(~isnan(sx_plus))
            meas_matrix=[meas_matrix; real(sx_plus(1))  real(v_plus(1))  real(sx_plus(2))  real(v_plus(2))  real(sx_plus(3))  real(v_plus(3)) ];
            %        sx_hist(t,:)=[meas_matrix];
        elseif(~isnan(sx_minus))
            meas_matrix=[meas_matrix; sx_minus(1) v_minus(1) sx_minus(2) v_minus(2) sx_minus(3) v_minus(3) ];
            %        sx_hist(t,:)=[meas_matrix.'];
        end
    else
        meas_matrix=[tracks{end}.kalman_state.x.' ]; 
    end
    
    meas_matrix=[meas_matrix measurements{1}(1:2) measurements{2}(1:2) measurements{3}(1:2)  0];
    %% association procedure and EKF
    % if targets pre-exist the measurements will pass the ass. gate
    % prior to the update of the filter
    for k=1:active_track_num
        tracks{k}.assoc_cand=[];
    end
    j=0;
    % categorize measurements(locked, preliminary, losing lock-on)
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
                    if(early_gate_fc(tracks{k}.bistatic_values,meas_matrix(j,:),CPI,[10000000.5 100000000000000.5])) % keep only those that are within some range(maybe speed)
                        tracks{k}.assoc_cand=[tracks{k}.assoc_cand; meas_matrix(j,:)];
                        meas_matrix(j,end)=1;
                    end
                end
            end
            % Then, the preliminary track ones
            for k=1:track_iters
                if(tracks{k}.state==1)
                    if(meas_matrix(j,end)==0 && early_gate_fc(tracks{k}.bistatic_values,meas_matrix(j,:),CPI,[100000.5 10000.5]))
                        tracks{k}.assoc_cand=[tracks{k}.assoc_cand; meas_matrix(j,:)];
                        meas_matrix(j,end)=1;
                    end
                end
            end
        end
        % initiate new track with the measurement
        if(meas_matrix(j,end)~=1 && active_track_num<N_tracks)
            %             H=gen_H(meas_matrix(j,:),tx,rx);
            if(~exist('tracks','var'))
                tracks=cell(1);
                tracks{1}=initiate_track_fc(meas_matrix(j,:),N,lamda,CPI);
                meas_matrix(j,end)=1;
            else
                tracks{end+1}=initiate_track_fc(meas_matrix(j,:),N,lamda,CPI);
                meas_matrix(j,end)=1;
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
    
    
    % Confirmed tracks
    %  keep only measurements inside validation gate
    %  apply EKF(if there is measurement) and prediction
    for k=1:N_tracks
        if(tracks{k}.state==2)
            valid_meas=[];
            meas_3d=[];
            if(~isempty(tracks{k}.assoc_cand))
                if(sequential)
                    ind=0;
                    for rx_index=1:size(rx,1)
                        %                         [temp,g(rx_index,t)]=val_gate_fc(measurements{rx_index},tracks{k}.estimate,tracks{k},tx,rx(rx_index,:)); % get the corresponding bistatic measurements of the current 3d measurement
                        %                         if(~isempty(temp))
                        ind=ind+1;
                        %                             valid_meas(ind,:)=temp;
                        %                             valid_meas=tracks{k}.assoc_cand;
                        valid_meas=[tracks{k}.assoc_cand rx_index];
                        
                        meas_3d(ind,:)=assoc_meas_fc(valid_meas,tracks{k},1); % 1. for NN 2. for SN 3. ...
                        %                       measurement=valid_meas;
                        %                         else
                        
                        %                         end
                    end
                    [estimate,x_new]=kalman_filter_fc(meas_3d,tracks{k},t,tx,rx);
                    tracks{k}.kalman_state=x_new;
                    tracks{k}.estimate=estimate;
                else
                    valid_meas=val_gate_fc(measurements,tracks{k}.estimate,tracks{k},tx,rx); % get the corresponding bistatic measurements of the current 3d measurement
                    %                 valid_meas=tracks{k}.assoc_cand;
                    meas_3d=assoc_meas_fc(valid_meas,tracks{k},16); % 1. for NN 2. for SN 3. ...
                    %                 measurement=valid_meas;
                end
            end
            %             [estimate,x_new]=kalman_filter_fc(measurements,measurement,tracks{k},t,tx,rx,sequential);
            %             tracks{k}.kalman_state=x_new;
            %             tracks{k}.estimate=estimate;
        elseif(tracks{k}.state==1)
            valid_meas=[];
            meas_3d=[];
            if(~isempty(tracks{k}.assoc_cand))
                if(sequential)
                    for rx_index=1:size(rx,1)
                        valid_meas=[tracks{k}.assoc_cand rx_index];
                        %                         [temp,g(rx_index,t)]=val_gate_fc(measurements{rx_index},tracks{k}.estimate,tracks{k},tx,rx(rx_index,:),rx_index); % get the corresponding bistatic measurements of the current 3d measurement
                        if(~isempty(valid_meas))
                            meas_3d(rx_index,:)=assoc_meas_fc(valid_meas,tracks{k},rx_index); % 1. for NN 2. for SN 3. ...
                        end
                        
                    end
                    [estimate,x_new]=kalman_filter_fc(meas_3d,tracks{k},t,tx,rx);
                    tracks{k}.kalman_state=x_new;
                    tracks{k}.estimate=estimate;
                else
                    valid_meas=val_gate_fc(measurements,tracks{k}.estimate,tracks{k},tx,rx); % get the corresponding bistatic measurements of the current 3d measurement
                    %                 valid_meas=tracks{k}.assoc_cand;
                    meas_3d=assoc_meas_fc(valid_meas,tracks{k},1); % 1. for NN 2. for SN 3. ...
                    %                 measurement=valid_meas;
                end
            end
            %             [estimate,x_new]=kalman_filter_fc(measurements,measurement,tracks{k},t,tx,rx,sequential);
            %             tracks{k}.kalman_state=x_new;
            %             tracks{k}.estimate=estimate;
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
            end
        elseif(tracks{k}.state==1) % preliminary
            if(sum(tracks{k}.init_vec)>=M)
                tracks{k}.state=2;
            elseif(sum(tracks{k}.init_vec)==0)
                tracks{k}.state=0;
                finished_track_num=finished_track_num+1;
                active_track_num=active_track_num-1;
            end
        else % free_ones
            if(sum(tracks{k}.init_vec)>=1)
                tracks{k}.state=1;
            elseif(sum(tracks{k}.init_vec)==0)
                tracks{k}.state=0;
            end
        end
    end
end

hist_kf_out=tracks{1}.kalman_state.hist_kf_out;
track_length=size(hist_kf_out,1);
time_truth=[0 7 12 19 24 31 37 43 49 56 58 61 65 67 71];
t_len=length(time_truth);
figure
subplot(3,2,1)
plot([1:track_length]+4,hist_kf_out(:,1))
hold on
plot(time_truth,plane_x(1:t_len))
legend('ekf track','adsb')
ylabel('Y axis (m)')
xlabel('time (s)')
subplot(3,2,3)
plot([1:track_length]+4,hist_kf_out(:,3))
hold on
plot(time_truth,plane_y(1:t_len))
legend('ekf track','adsb')
ylabel('X axis (m)')
xlabel('time (s)')
subplot(3,2,5)
plot([1:track_length]+4,hist_kf_out(:,5))
hold on
plot(time_truth,plane_z(1:t_len))
ylabel('Z axis (m)')
xlabel('time (s)')
legend('ekf track','adsb')

subplot(3,2,2)
plot([1:track_length]+4,hist_kf_out(:,2))
hold on
plot(time_truth,x_speed(1:t_len))
legend('ekf track','adsb')
ylabel('Speed y axis (m/s)')
xlabel('time (s)')
subplot(3,2,4)
plot([1:track_length]+4,hist_kf_out(:,4))
hold on
plot(time_truth,y_speed(1:t_len))
ylabel('Speed x axis (m/s)')
xlabel('time (s)')
legend('ekf track','adsb')
subplot(3,2,6)
plot([1:track_length]+4,hist_kf_out(:,6))
hold on
plot(time_truth,z_speed(1:t_len))
legend('ekf track','adsb')
ylabel('Speed z axis (m/s)')
xlabel('time (s)')

% hold on
% plot([1:track_length],sx_hist(1:track_length,1))
% ylabel('X_axis (m)')
% legend('ekf','truth','SX^+ output')
% title('x(m)')
% subplot(3,2,3)
% plot([1:track_length],hist_kf_out(:,3))
% hold on
% % plot([1:track_length],trgt_pos_hist(1:track_length,2))
% % hold on
% % plot([1:track_length],sx_hist(1:track_length,3))
% legend('ekf','truth','SX^+ output')
% title('y(m)')
% subplot(3,2,5)
% plot([1:track_length],hist_kf_out(:,5))
% hold on
% % plot([1:track_length],trgt_pos_hist(1:track_length,3))
% % hold on
% % plot([1:track_length],sx_hist(1:track_length,5))
% legend('ekf','truth','SX^+ output')
% title('z(m)')
% subplot(3,2,2)
% plot([1:track_length],hist_kf_out(:,2))
% hold on
% % plot([1:track_length],x_speed_vec(1,1:track_length))
% % hold on
% % plot([1:track_length],sx_hist(1:track_length,2))
% legend('ekf','truth','SX^+ output')
% title('u_x(m/s)')
% subplot(3,2,4)
% plot([1:track_length],hist_kf_out(:,4))
% hold on
% % plot([1:track_length],y_speed_vec(1,1:track_length))
% % hold on
% % plot([1:track_length],sx_hist(1:track_length,4))
% legend('ekf','truth','SX^+ output')
% title('u_y(m/s)')
%
% subplot(3,2,6)
% plot([1:track_length],hist_kf_out(:,6))
% hold on
% % plot([1:track_length],z_speed_vec(1,1:track_length))
% % hold on
% % plot([1:track_length],sx_hist(1:track_length,6))
% legend('ekf','truth','SX^+ output')
% title('u_z(m/s)')
%
% figure()
%
% %
% % %% print 3D tracking(truth and measurements)
% h(1)=stem3(plane_x,plane_y,plane_z,'r','LineStyle','none')
% hold on
% h(2)=stem3(hist_kf_out(:,1),hist_kf_out(:,3),hist_kf_out(:,5),'b','LineStyle','none')
% hold on
% % h(3)=stem3(sx_hist(:,1),sx_hist(:,3),sx_hist(:,5),'y','LineStyle','none')
% % hold on
% legend('target','KF','Measurement')
% hold off
% figure
% subplot(3,2,1)
% plot([1:track_length],range_hist(1:track_length,1))
% hold on
% plot([1:track_length],measurements_hist(1:3:3*track_length,1))
% subplot(3,2,3)
% plot([1:track_length],range_hist(1:track_length,2))
% hold on
% plot([1:track_length],measurements_hist(2:3:3*track_length,1))
% subplot(3,2,5)
% plot([1:track_length],range_hist(1:track_length,3))
% hold on
% plot([1:track_length],measurements_hist(3:3:3*track_length,1))
% subplot(3,2,2)
% plot([1:track_length],V_hist(1:track_length,1))
% hold on
% plot([1:track_length],measurements_hist(1:3:3*track_length,2))
% subplot(3,2,4)
% plot([1:track_length],V_hist(1:track_length,2))
% hold on
% plot([1:track_length],measurements_hist(2:3:3*track_length,2))
% subplot(3,2,6)
% plot([1:track_length],V_hist(1:track_length,3))
% hold on
% plot([1:track_length],measurements_hist(3:3:3*track_length,2))
%
% figure()
% plot([1:reps],g)
% legend('rx1','rx2','rx3')
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
% % % plot([1:track_length],trgt_pos_hist(1:track_length,1))
% % % hold on
% % % plot([1:track_length],sx_hist(1:track_length,1))
% % legend('ekf','truth','SX^+ output')
% % title('x(m)')
% % subplot(3,2,3)
% % plot([1:track_length],hist_kf_out(:,3))
% % hold on
% % % plot([1:track_length],trgt_pos_hist(1:track_length,2))
% % % hold on
% % % plot([1:track_length],sx_hist(1:track_length,3))
% % legend('ekf','truth','SX^+ output')
% % title('y(m)')
% % subplot(3,2,5)
% % plot([1:track_length],hist_kf_out(:,5))
% % hold on
% % % plot([1:track_length],trgt_pos_hist(1:track_length,3))
% % % hold on
% % % plot([1:track_length],sx_hist(1:track_length,5))
% % legend('ekf','truth','SX^+ output')
% % title('z(m)')
% % subplot(3,2,2)
% % plot([1:track_length],hist_kf_out(:,2))
% % hold on
% % % plot([1:track_length],x_speed_vec(1,1:track_length))
% % % hold on
% % % plot([1:track_length],sx_hist(1:track_length,2))
% % legend('ekf','truth','SX^+ output')
% % title('u_x(m/s)')
% % subplot(3,2,4)
% % plot([1:track_length],hist_kf_out(:,4))
% % hold on
% % % plot([1:track_length],y_speed_vec(1,1:track_length))
% % % hold on
% % % plot([1:track_length],sx_hist(1:track_length,4))
% % legend('ekf','truth','SX^+ output')
% % title('u_y(m/s)')
% %
% % subplot(3,2,6)
% % plot([1:track_length],hist_kf_out(:,6))
% % hold on
% % % plot([1:track_length],z_speed_vec(1,1:track_length))
% % % hold on
% % % plot([1:track_length],sx_hist(1:track_length,6))
% % legend('ekf','truth','SX^+ output')
% % title('u_z(m/s)')
% %
% % figure()
% %
% % %
% % % %% print 3D tracking(truth and measurements)
% % h(1)=stem3(plane_x,plane_y,plane_z,'r','LineStyle','none')
% % hold on
% % h(2)=stem3(hist_kf_out(:,1),hist_kf_out(:,3),hist_kf_out(:,5),'b','LineStyle','none')
% % hold on
% % % h(3)=stem3(sx_hist(:,1),sx_hist(:,3),sx_hist(:,5),'y','LineStyle','none')
% % % hold on
% % legend('target','KF','Measurement')
% % hold off
% % figure
% % subplot(3,2,1)
% % plot([1:track_length],range_hist(1:track_length,1))
% % hold on
% % plot([1:track_length],measurements_hist(1:3:3*track_length,1))
% % subplot(3,2,3)
% % plot([1:track_length],range_hist(1:track_length,2))
% % hold on
% % plot([1:track_length],measurements_hist(2:3:3*track_length,1))
% % subplot(3,2,5)
% % plot([1:track_length],range_hist(1:track_length,3))
% % hold on
% % plot([1:track_length],measurements_hist(3:3:3*track_length,1))
% % subplot(3,2,2)
% % plot([1:track_length],V_hist(1:track_length,1))
% % hold on
% % plot([1:track_length],measurements_hist(1:3:3*track_length,2))
% % subplot(3,2,4)
% % plot([1:track_length],V_hist(1:track_length,2))
% % hold on
% % plot([1:track_length],measurements_hist(2:3:3*track_length,2))
% % subplot(3,2,6)
% % plot([1:track_length],V_hist(1:track_length,3))
% % hold on
% % plot([1:track_length],measurements_hist(3:3:3*track_length,2))
% %
% % figure()
% % plot([1:reps],g)
% % legend('rx1','rx2','rx3')
