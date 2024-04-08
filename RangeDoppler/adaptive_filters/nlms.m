function [ret,w,ref_m]=nlms(ref,obs,M,mu,a,w,ref_start)
%% Normalized Least-Mean-Square algorithm
% input
% ref: reference signal
% obs: observation signal
% M:   number of taps
% mu:  a value between 0 and 2
% a:   small value for stabillity purposes
% 
% output:
% ret: clutter removed observation signal


%% initializations
obs_cl_rem=complex(zeros(length(ref),1));
ref_m=ref_start;


for n=1:length(ref)
    %% step 1:
    %   shift each sample of u(n) by one on the left
    %   and put the new sample in the end
    ref_m(2:M)=ref_m(1:M-1);
    ref_m(1)=ref(n);
    %% step 2:
    %  calculate the output vector at time n
    obs_cl_rem(n)=w'*ref_m;
    %% step 3:
    %  calculate the error
    e= obs(n) - obs_cl_rem(n);
    ret(n)=e;
    %% step 4:
    %  calculate the next w vector
    w=w+mu*ref_m*conj(e)./(a+norm(ref_m)^2);
end
end