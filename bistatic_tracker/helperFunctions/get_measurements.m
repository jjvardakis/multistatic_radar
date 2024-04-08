function [candidateRange,candidateDoppler,candidateStrength]=get_measurements(ard,track_estimate,frame_extent,N_tracks,rep,range_res,range_cells,baseline)

range_extent=frame_extent(1);
doppler_extent=frame_extent(2);

candidateRange=[];
candidateDoppler=[];

ard=abs(ard)./mean(abs(ard),'all');
%% zero out some standard clutter around the (0,0) range doppler bins.
centerRange=size(ard,2)-1;
centerDoppler=size(ard,1)/2;
% range_del=[centerRange-50:centerRange+1];
% for k=1:size(track_estimate,2)
%     if((track_estimate(2,k)<15 & track_estimate(2,k)>-15))
%         range_del=range_del(find(range_del~=centerRange-floor(track_estimate(1,k)/range_res+1)));
%     end
% end
ard(centerDoppler:centerDoppler,:,rep)=0;
ard(centerDoppler-255:centerDoppler+256,centerRange:centerRange+1,rep)=0;
% ard(1:162,centerRange-1:centerRange+1,rep)=0;
% ard(350:512,centerRange-1:centerRange+1,rep)=0;

% ard(centerDoppler:centerDoppler,centerRange:centerRange+1,rep)=0;
% ard(centerDoppler-255:centerDoppler+255,centerRange-2:centerRange+1,rep)=0;

% figure()
vmn = prctile(ard(:,:).', 1,'all');
vmx = prctile(ard(:,:).',99.9,'all');
if(vmn<vmx)
    imagesc(ard(:,:,rep).',[vmn vmx]); 
end
colormap(parula);
grid on
grid minor
% temp=['fig',num2str(i),'.png'];
xticklabels = [-250:50:272];
xticks = linspace(6,size(ard, 1)-6, numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)
%     set(ygrid,'LineWidth',1.5)
yticklabels = linspace(baseline,baseline+range_cells*range_res,5);
yticks = linspace(1, size(ard, 2), numel(yticklabels));
set(gca, 'YTick', yticks, 'YTickLabel', round(flipud(yticklabels(:))))
xlabel('Doppler Frequency (Hz)')
ylabel('Range (m)')
%% keep only the strongest few measurements
threshold=0;
prctg=80;
while(threshold<=0 && prctg<=100 && prctg>=0)
    threshold=prctile(ard(:,:,rep),prctg,'all');
    prctg=prctg+0.05;
end
[freqCand,delayCand]=find(ard(:,:,rep)>=threshold); % [x,y]
if(length(freqCand)<size(ard,1)*size(ard,2)/100*(100-prctg+0.07))
    candidateStrength=diag(ard(freqCand,delayCand,rep)); 
else
    candidateRange=[];
    candidateDoppler=[];
    candidateStrength=[];
    return
end
% sort them based on strength
[candidateStrength,I] = sort(candidateStrength,'descend');

candidateRange=delayCand(I);
candidateDoppler=freqCand(I);

candidateRange=baseline+range_extent*(centerRange-candidateRange);
candidateDoppler=doppler_extent*(candidateDoppler-centerDoppler);


