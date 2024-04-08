function [estimate,x_new]=kalman_filter(measurement,track,rep)
%% kalman update
% measurement: new one
% lastMeasurement: previous one
currentState=track.kalman_state;
% currentState: kalman struct containing current filter state
x=currentState.x; % state estimate vector
P=currentState.P; % state estimate covariance matrix
F1=currentState.F1; % state transition model 
F2=currentState.F2; % state transition model 
H=currentState.H; %  measurement matrix
Q=currentState.Q; % process noise covariance matrix
R=currentState.R; % measurement noise covariance matrix
S=currentState.S; % innovation covariance matrix
hist_meas=currentState.hist_meas;
hist_kf_est=currentState.hist_kf_est;
hist_kf_out=currentState.hist_kf_out;

% predict
x
x=F1*x;
x
hist_kf_est=[hist_kf_est x];
P=F2*P*F2.'+Q;
S=H*P*H.'+R;

if(isempty(measurement)) % use previous prediction only
    x=x;
    fprintf('no measurement on rep = %d',rep);
    hist_meas=[hist_meas zeros(2,1)];

else
    hist_meas=[hist_meas measurement(1:2).'];
    K=P*H.'/S;
    % update
    P=P-K*H*P;
    x=x+K*(measurement(1:2).'-H*x);
    track.range=measurement(1);
    track.doppler=measurement(2);
end
hist_kf_out=[hist_kf_out x];

x_new.x=x; % state estimate vector
x_new.P=P; % state estimate covariance matrix
x_new.F1=F1; % state transition model 
x_new.F2=F2; % state transition model 
x_new.H=H; %  measurement matrix
x_new.Q=Q; % process noise covariance matrix
x_new.R=R; % measurement noise covariance matrix
x_new.S=S; % innovation covariance matrix
x_new.hist_kf_out=hist_kf_out;
x_new.hist_kf_est=hist_kf_est;
x_new.hist_meas=hist_meas;


estimate=H*F1*x;
if(isempty(measurement)) % use previous prediction only
    track.range=track.estimate(1);
    track.doppler=track.estimate(2);
end
track.kalman_state=x_new;

