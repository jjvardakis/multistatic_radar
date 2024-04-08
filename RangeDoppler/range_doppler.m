%% calculates ARD surface
% xambg=load('xambg_python2.mat');
% xambg=abs(xambg.xambg_matrix)./mean(abs(xambg.xambg_matrix),'all');
% xambg(100:110,100:110,100)

% % TV settings
% Fs=8*10^6;
% CPI=.1;
% Fc=498*10^6;

% FM settings
Fs=2*10^5;
CPI=1;
Fc=98.2*10^6;
% %Skloka
% basel=7280;

% Malaxa
basel=7280;

range_res=physconst('LightSpeed')/(2*Fs);
dplr_res=1/CPI;

parentDirectory = fileparts(cd);
addpath(parentDirectory)
xambg=load("..\RangeDoppler\wf_malaxa_2.mat");
xambg=abs(xambg.XAMBG);
xambg=abs(xambg)./median(abs(xambg),'all');
dplr_cells=size(xambg,1);
range_cells=size(xambg,2);
% range_cells=20;
Nframes = size(xambg,3);
% Nframes = 60;
start=1;
% CFAR filtering
CF = zeros(size(xambg));
for i=start:Nframes
    CF(:,:,i) = CFAR(xambg(:,:,i), 20, 4, 3);
end

for k=start:Nframes
    k
    figure(1);
    data = persistence(CF, k, 30, 0.91);
%         data = persistence(xambg, k, 30, 0.91);
    data = flipud(data);
    % data(:,end-2:end)=0;
    % data(256,:)=0;
    %     data = flipud(xambg(:,:,k));
    vmn = prctile(data, 1,'all');
    vmx = prctile(data,99.9,'all');
    if(vmn<vmx)
        imagesc(data.',[vmn vmx]);
    end
    colormap(parula);
    grid on
    grid minor
    temp=['fig',num2str(k),'.png'];
    xticklabels = [-250:50:272];
    xticks = linspace(6,size(data, 1)-6, numel(xticklabels));
    set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)
    %     set(ygrid,'LineWidth',1.5)
    yticklabels = linspace(basel,(range_cells-1)*range_res+basel,5);
    yticks = linspace(1, size(data, 2), numel(yticklabels));
    set(gca, 'YTick', yticks, 'YTickLabel', (flipud(yticklabels(:))))
    xlabel('Doppler Frequency (Hz)')
    ylabel('Range (Kms)')
    %     saveas(gca,temp);
    s2 = temp;
    s = strcat('/figs/',s2);
    % saveas(gca,[parentDirectory s]);
    pause(0.1)
end


