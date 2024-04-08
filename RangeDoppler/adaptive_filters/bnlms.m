function [ret_vec,w]=bnlms(ref,obs,L,M,mu,a,w)
%% Block Normalized Least-Mean-Square algorithm
%  ''time domain''
% input
% ref: reference signal
% obs: observation signal
% L: length of the block
% M:   number of taps
% mu:  a value between 0 and 2
% a:   small value for stabillity purposes
% 
% output:
% ret: clutter removed observation signal


%% initializations
ref_m=complex(zeros(M,1));
obs_cl_rem=complex(zeros(length(ref),1));
% ref_m(:,1)=ref(M:-1:1);
counter=L;
ex=complex(zeros(1,1));
ok=0;
times=0;
for n=1:length(ref)
    %% step 1:
    %   shift each sample of u(n) by one on the left
    %   and put the new sample in the end
    ref_m(L-1:-1:1)=ref_m(L:-1:2);
    ref_m(L)=ref(n);
    if(ok==0)
        ref_start=ref_m;
        ok=1;
    end
    counter=counter-1;
    %% step 2:
    %  calculate the output vector at time n
    obs_cl_rem(n)=w'*ref_m;
    %% step 3:
    %  calculate the error
    e= obs(n) - obs_cl_rem(n);
    ret_vec(n)=e;
    ex=ex+ref_m*e';
    times=times+1;
    if(counter<1 )
        counter=L;
        times=0;
        %% step 4:
        %  calculate the next w vector
        w=w+mu*ex/(L*(a+norm(ref_start)^2));
%         w=w+mu*ex/((a+norm(ref_start)^2));
        ex=complex(zeros(1,1));
        ok=0;
    end
end
ret=obs_cl_rem.';
end