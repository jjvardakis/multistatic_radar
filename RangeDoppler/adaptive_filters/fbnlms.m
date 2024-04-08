function [ret_vec,w,u]=fbnlms(ref,obs,L,M,mu,gamma,w,first)
%% Block Normalized Least-Mean-Square algorithm
%  ''frequency domain''
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
ret=complex(zeros(size(ref)));
P=complex(zeros(2*L,1))+0.5;
% no.of blocks
blocks=length(ref)/L;
ref=ref(:);
obs=obs(:);
u=[zeros(L,1);first];
for block=1:blocks
    %% fft and zero-padding
    % w=fft([w zeros(1,L)],2*L);
    u=[u(L+1:end) ;ref((block-1)*L+1:(block)*L)];
    x=fft(u,2*L);


    %% ifft of hadamard product
    y1=ifft(x.*w);
    ret(1,(block-1)*L+1:(block)*L)=y1(L+1:end);
    
    %% error
    e=obs((block-1)*L+1:(block)*L)-ret(1,(block-1)*L+1:(block)*L).';
    ret_vec((block-1)*L+1:(block)*L)=e;
    %% calculate E
    E=fft([zeros(L,1); e],2*L);
    
    %% Signal power estimation
     P=(gamma*P+(1-gamma)*(abs(x)).^2);
  
    %% calculate gradient
      grad_k_tot=ifft((1./P).*E.*conj(x));
%     grad_k_tot=ifft(E.*x);
      grad_k=grad_k_tot(1:L,1);
    
    %% weights update
%     w=w+mu*2*L.*norm(x)^2.^2.*E.*x;
      w=w+mu.*fft([grad_k;zeros(L,1)]);
%     w=w+mu*E.*x;
%  ret(1,(block-1)*L+1:(block)*L)
end
u=u(L+1:end);
end