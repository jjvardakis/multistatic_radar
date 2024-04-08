function ret=LS_Filter(ref,srv,nlag,reg)
%Least squares clutter removal for passive radar. Computes filter taps
%using the direct matrix inversion method

% Parameters:
% ref:reference
% srv:surveilance
% nlag: filter length in samples
% reg: L2 regularization parameter for matrix inversion
% return_filter: (bool) option to return filter taps as well as cleaned signal
% 
% Returns:
% y:surveillance signal with clutter removed
% w: (optional) least squares filter taps
% w=complex(zeros(nlag,1));
if(size(ref)~=size(srv))
    fprintf('not equal sizes');
end
A=complex(zeros(size(ref,2),nlag+10));
lags=(-10:nlag-1);

%compute the data matrix
for k=1:length(lags)
    A(:,k)=circshift(ref.',lags(k));
end

% compute autocorrelation matrix of ref
ATA= A'*A;

%create Tikhonov regularization matrix
K=eye(size(ATA));

%solve least squares problem
% w=block_levinson(srv(1:120000).',ref(1:120000).');

% direct but slightly slower implementation
w=(ATA+K.*reg)\A'*srv.';
% w=pinv(A)*srv.';
ret=srv-(A*w).';