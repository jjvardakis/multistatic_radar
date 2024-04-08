figure()
%% plane_data: x_pl,y_pl,alt
% range
R=zeros(size(plane_x,1),1);
RR=zeros(size(plane_x,1),1);
pl=[plane_x plane_y plane_z];

v=[x_speed;y_speed;z_speed];
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
plot(linspace(0,71,size(R,1)),R(:,1))
title("Malaxa")
xlabel("Time (sec)")
ylabel("Bistatic range (m)")
legend('NN','SN','ADSB')
subplot(2,1,2)
plot(linspace(5,65,size(hist_kf_out_nn{2},2)),hist_kf_out_nn{2}(1,:))
hold on
plot(linspace(5,65,size(hist_kf_out_sn{2},2)),hist_kf_out_sn{2}(1,:))
hold on
plot(linspace(0,71,size(R,1)),R(:,2))
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
plot(linspace(0,71,size(R,1)),-1/lamda(1)*RR(:,1))
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
plot(linspace(0,71,size(R,1)),-1/lamda(2)*RR(:,2))
legend("experimental","actual")
title("Skloka")
xlabel("Time (sec)")
ylabel("Frequency (Hz)")
legend('NN','SN','ADSB')
