figure()
%% plane_data: x_pl,y_pl,alt
% range
R=zeros(size(plane_x,1),1);
RR=zeros(size(plane_x,1),1);
pl=[plane_x plane_y plane_z];
pl_interp=[plane_x_interp.' plane_y_interp.' plane_z_interp.'];

v=[x_speed.',y_speed.',z_speed.'].';
v_int=[x_speed_int.',y_speed_int.',z_speed_int.'].';

for k=1:size(rx,1)
    R(:,k)=vecnorm(pl-rx(k,:),2,2)+vecnorm(pl,2,2); % range
    R_interp(:,k)=vecnorm(pl_interp-rx(k,:),2,2)+vecnorm(pl_interp,2,2); % range
end
for k=1:size(rx,1)
        RR(:,k)=diag((pl-rx(k,:))*v)./vecnorm(pl-rx(k,:),2,2)...
                +diag(pl*v)./vecnorm(pl,2,2); % velocity
        RR_interp(:,k)=diag((pl_interp-rx(k,:))*v_int)./vecnorm(pl_interp-rx(k,:),2,2)...
            +diag(pl_interp*v_int)./vecnorm(pl_interp,2,2); % velocity
end

% subplot(3,1,1)
figure
plot(linspace(60,150,size(hist_kf_out{1},2))-60,hist_kf_out{1}(1,:)*1e-3,'LineWidth',1.5)
hold on
plot(t(10:35)-60,R(10:35,1)*1e-3,'--','LineWidth',1.5)
xlim([60 150]-60)
title("Malaxa 106.5MHz")
xlabel("Time (sec)")
ylabel("Bistatic range (km)")
legend('track','true')
grid on

figure()
plot(linspace(0,112,size(hist_kf_out{1},2)),hist_kf_out{1}(1,:)*1e-3,'LineWidth',1.5)
hold on
plot(t-43-40,R(:,1)*1e-3,'--','LineWidth',1.5)
xlim([60 170]-60)
title("Malaxa 106.5MHz")
xlabel("Time (sec)")
ylabel("Bistatic range (km)")
legend('track','true')
grid on

figure()
plot(linspace(0,112,size(hist_kf_out{2},2)),hist_kf_out{2}(1,:)*1e-3,'LineWidth',1.5)
hold on
plot(t-45-40,R(:,2)*1e-3,'--','LineWidth',1.5)
xlim([60 170]-60)
title("Malaxa 106.5MHz")
xlabel("Time (sec)")
ylabel("Bistatic range (km)")
legend('track','true')
grid on

%% error calculation
figure()
plot(linspace(0,112,size(hist_kf_out{1},2)),abs(hist_kf_out{1}(1,:).' - R_interp(:,1)),'LineWidth',1.5)
xlim([60 170]-60)
title("Malaxa 106.5MHz")
xlabel("Time (sec)")
ylabel("Absolute bistatic range error(m)")
grid on


figure
% subplot(3,1,1)
plot(linspace(0,112,size(hist_kf_out{1},2)),hist_kf_out{1}(3,:),'LineWidth',1.5)
hold on
plot(t-43-40,-1/lamda*RR(:,1),'--','LineWidth',1.5)
xlim([0 110])
ylim([-100 10])
legend("experimental","actual")
title("Malaxa 106.5MHz")
xlabel("Time (sec)")
ylabel("Frequency (Hz)")
legend('track','true')
grid on

figure
% subplot(3,1,1)
plot(linspace(0,112,size(hist_kf_out{2},2)),hist_kf_out{2}(3,:),'LineWidth',1.5)
hold on
plot(t-43-40,-1/lamda*RR(:,2),'--','LineWidth',1.5)
xlim([0 110])
ylim([-100 10])
legend("experimental","actual")
title("Malaxa 106.5MHz")
xlabel("Time (sec)")
ylabel("Frequency (Hz)")
legend('track','true')
grid on




figure()
plot(linspace(0,112,size(hist_kf_out{1},2)),abs(hist_kf_out{1}(3,:).' - -1/lamda*RR_interp(:,1)),'LineWidth',1.5)
xlim([60 170]-60)
title("Malaxa 106.5MHz")
xlabel("Time (sec)")
ylabel("Absolute frequency error(Hz)")
grid on

figure
% subplot(3,1,1)
plot(linspace(0,112,size(hist_kf_out{1},2)),hist_kf_out{1}(3,:),'LineWidth',1.5)
hold on
plot(linspace(0,112,size(hist_kf_out{1},2)),-1/lamda*RR_interp(:,1),'--','LineWidth',1.5)
xlim([0 110])
ylim([-100 10])
legend("experimental","actual")
title("Malaxa 106.5MHz")
xlabel("Time (sec)")
ylabel("Frequency (Hz)")
legend('track','true')
grid on


figure
% subplot(3,1,1)
plot(linspace(0,110,size(hist_kf_out{1},2)),hist_kf_out{1}(3,:),'LineWidth',1.5)
hold on
plot(t-43-40,-1/lamda*RR(:,1),'--','LineWidth',1.5)
xlim([0 110])
ylim([-100 10])
legend("experimental","actual")
title("Malaxa 106.5MHz")
xlabel("Time (sec)")
ylabel("Frequency (Hz)")
legend('track','true')
grid on

%% error calculation
figure
% subplot(3,1,1)
plot(linspace(60,150,size(hist_kf_out{1},2))-60,hist_kf_out{1}(3,:),'LineWidth',1.5)
hold on
plot(t(10:35)-60,-1/lamda*RR(10:35,1),'--','LineWidth',1.5)
xlim([60 150]-60)
ylim([-100 10])
legend("experimental","actual")
title("Malaxa 106.5MHz")
xlabel("Time (sec)")
ylabel("Frequency error (Hz)")
legend('track','true')
grid on

