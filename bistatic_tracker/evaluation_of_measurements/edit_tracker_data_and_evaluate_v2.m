figure()
%% plane_data: x_pl,y_pl,alt
% range
R=zeros(size(plane_x,1),1);
RR=zeros(size(plane_x,1),1);
pl=[plane_x plane_y plane_z];

% 1665503458,2022-10-11T15:50:58Z,EWG63X,"35.545101,24.107159",1950,165,290
% 1665503465,2022-10-11T15:51:05Z,EWG63X,"35.546768,24.101543",2050,172,290
% 1665503470,2022-10-11T15:51:10Z,EWG63X,"35.548508,24.095993",2175,179,290
% 1665503477,2022-10-11T15:51:17Z,EWG63X,"35.55064,24.089102",2300,188,290
% 1665503482,2022-10-11T15:51:22Z,EWG63X,"35.552261,24.083862",2400,194,291
% 1665503489,2022-10-11T15:51:29Z,EWG63X,"35.554367,24.077168",2500,204,290
% 1665503495,2022-10-11T15:51:35Z,EWG63X,"35.556656,24.069729",2600,214,291
% 1665503501,2022-10-11T15:51:41Z,EWG63X,"35.558853,24.062634",2725,223,290
% 1665503507,2022-10-11T15:51:47Z,EWG63X,"35.561005,24.05571",2975,226,290
% 1665503514,2022-10-11T15:51:54Z,EWG63X,"35.563705,24.047928",3375,225,294
% 1665503516,2022-10-11T15:51:56Z,EWG63X,"35.565262,24.044724",3550,224,299
% 1665503519,2022-10-11T15:51:59Z,EWG63X,"35.567047,24.041748",3700,225,305
% 1665503523,2022-10-11T15:52:03Z,EWG63X,"35.56926,24.038729",3875,226,311
% 1665503525,2022-10-11T15:52:05Z,EWG63X,"35.571487,24.036369",4025,227,318
% 1665503529,2022-10-11T15:52:09Z,EWG63X,"35.574383,24.033878",4200,227,324
v=[x_speed,y_speed,z_speed].';
for k=1:size(rx,1)
    R(:,k)=vecnorm(pl-rx(k,:),2,2)+vecnorm(pl,2,2); % range
end
for k=1:size(rx,1)
        RR(:,k)=diag((pl-rx(k,:))*v)./vecnorm(pl-rx(k,:),2,2)...
                +diag(pl*v)./vecnorm(pl,2,2); % velocity
end

subplot(2,1,1)
plot(linspace(5,65,size(hist_kf_out_nn{1},2)),hist_kf_out_nn{1}(1,:))
hold on
plot(linspace(5,65,size(hist_kf_out_sn{1},2)),hist_kf_out_sn{1}(1,:))
hold on
plot([0 7 12 19 24 31 37 43 49 56 58 61 65 67 71 ],R(:,1))
title("Malaxa")
xlabel("Time (sec)")
ylabel("Bistatic range (m)")
legend('NN','SN','ADSB')
subplot(2,1,2)
plot(linspace(5,65,size(hist_kf_out_nn{2},2)),hist_kf_out_nn{2}(1,:))
hold on
plot(linspace(5,65,size(hist_kf_out_sn{2},2)),hist_kf_out_sn{2}(1,:))
hold on
plot([0 7 12 19 24 31 37 43 49 56 58 61 65 67 71 ],R(:,2))
title("Skloka")
xlabel("Time (sec)")
ylabel("Bistatic range (m)")
legend('NN','SN','ADSB')


figure
subplot(2,1,1)
plot(linspace(5,65,size(hist_kf_out_nn{1},2)),hist_kf_out_nn{1}(3,:))
hold on
plot(linspace(5,65,size(hist_kf_out_sn{1},2)),hist_kf_out_sn{1}(3,:))
hold on
plot([0 7 12 19 24 31 37 43 49 56 58 61 65 67 71 ],-1/lamda(1)*RR(:,1))
legend("experimental","actual")
title("Malaxa")
xlabel("Time (sec)")
ylabel("Frequency (Hz)")
legend('NN','SN','ADSB')
subplot(2,1,2)
plot(linspace(5,65,size(hist_kf_out_nn{2},2)),hist_kf_out_nn{2}(3,:))
hold on
plot(linspace(5,65,size(hist_kf_out_sn{1},2)),hist_kf_out_sn{1}(3,:))
hold on
plot([0 7 12 19 24 31 37 43 49 56 58 61 65 67 71 ],-1/lamda(2)*RR(:,2))
legend("experimental","actual")
title("Skloka")
xlabel("Time (sec)")
ylabel("Frequency (Hz)")
legend('NN','SN','ADSB')
