function CR=CFAR(X, fw, gw, thresh)
% constant false alarm rate target detection

% Parameters:
%     fw: CFAR kernel width 
%     gw: number of guard cells
%     thresh: detection threshold
%     
%     Returns:
%     X with CFAR filter applied'''

Tfilt = ones(fw,fw)/(fw^2-gw^2);
e1=(fw -gw)/2;
e2=fw - e1 +1;
Tfilt(e1:e2,e1:e2) = 0;

CR= X./(imfilter(X,Tfilt,'circular','same')+1e-10);
indices=find(CR<thresh);
CR(indices)=0;
end