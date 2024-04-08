function [x_hat_SX_plus,v_xyz_plus,x_hat_SX_minus,v_xyz_minus,RT_plus,RT_minus]=SX(meas,rx)
%% position estimation
x_hat_plus_ok=0;x_hat_minus_ok=0;
S=rx;
if(rank(S)~=size(S,2))
    pause();
end
r=[];
for i=1:size(rx,1)
    r=[r;meas{i}(1,1)];
end
z=1/2*(vecnorm(rx,2,2).^2-r.^2);
ss=S*S.';
T=(eye(size(ss))-ss);
reps=size(r,2);
for i=1:reps
    a=(S.'*S)\S.'*z(:,i);
    b=(S.'*S)\S.'*r(:,i);
    RT_plus=(-2*a.'*b+sqrt(4*(a.'*b)^2-4*(b.'*b-1)*a.'*a))/(2*(b.'*b-1));
    RT_minus=(-2*a.'*b-sqrt(4*(a.'*b)^2-4*(b.'*b-1)*a.'*a))/(2*(b.'*b-1));
    
    %             x_hat_SI(:,i)=(S.'*S)\S.'*z(:,i)+(S.'*S)\S.'*r(:,i)*(-r(:,i).'*T*z(:,i))/(r(:,i).'*T*r(:,i));
    x_hat_SX_plus(:,i)=(S.'*S)\S.'*z(:,i)+(S.'*S)\S.'*r(:,i)*(RT_plus);
    x_hat_SX_minus(:,i)=(S.'*S)\S.'*z(:,i)+(S.'*S)\S.'*r(:,i)*(RT_minus);
    
end

% filter out the negative altitudes or complex values
if(x_hat_SX_plus(3)>0)
    x_hat_plus_ok=1;
elseif(x_hat_SX_minus(3)>0)
    x_hat_minus_ok=1;
end

%% velocity estimation
v=[];
for i=1:size(rx,1)
    v=[v;meas{i}(1,2)];
end

if(x_hat_plus_ok)
    Rr=vecnorm((x_hat_SX_plus.'-rx),2,2);
    v_xyz_plus=zeros(3,1);
    Rt=norm(x_hat_SX_plus);
    a=x_hat_SX_plus./Rt;
    b=(x_hat_SX_plus.'-rx);
    C=[b./Rr+a.'];
    v_xyz_plus=(C.'*C)\C.'*v;
else
    v_xyz_plus=NaN;
    x_hat_SX_plus=NaN;
end

if(x_hat_minus_ok)
    Rr=vecnorm((x_hat_SX_minus.'-rx),2,2);
    v_xyz_minus=zeros(3,1);
    Rt=norm(x_hat_SX_minus);
    a=x_hat_SX_minus./Rt; %ok
    b=(x_hat_SX_minus.'-rx); % checked
    C=[b./Rr+a.']; % checked
    v_xyz_minus=(C.'*C)\C.'*v;
else
    v_xyz_minus=NaN;
    x_hat_SX_minus=NaN;
end

end