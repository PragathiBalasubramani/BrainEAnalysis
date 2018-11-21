function [fig] = wcoherenceROI(EEG, hm, targetCh1, targetCh2, taskname, condition, flag_alignment)
x = mean(EEG.data(targetCh1,:,:),3);
y = mean(EEG.data(targetCh2,:,:),3);
targetCh1_name = {EEG.chanlocs(targetCh1).labels};
targetCh2_name = {EEG.chanlocs(targetCh2).labels};
fig = figure('Tag', taskname,'UserData',['WCoherence- task:' taskname ' condition:' condition ' ROI:' targetCh1_name '<->' targetCh2_name  ' Alignment:' flag_alignment]);
fig.Position(3:4) = [562   640];

ax = subplot(3,3,1:6);
wcoherence(x,y,EEG.srate);
% %1st roi, assuming autocoh
% baseline = EEG.times>baseline(1) & EEG.times<=baseline(2);
% EEGtimes = EEG.times;
% indrm = EEG.times<EEG.times(1)*0.9 | EEG.times>EEG.times(end)*0.9;
% EEGtimes(indrm) = [];
% baseline(indrm) = [];
% data = double(squeeze(EEG.data(1,:,1)));
% [wt,freq] = cwt(data, 'amor', EEG.srate);
% Nf = size(wt,1);
% Coh = zeros([size(wt)]);
% G = LargeTensorC([size(wt) EEG.trials]);
% 
% for t=1:EEG.trials
%     G(:,:,t) = cwt(EEG.data(targetCh1,:,t), 'amor', EEG.srate);
% end
% 
% for f=1:Nf
%     Si = squeeze(G(f,:,:));
%     Sii = diag(Si*Si')/EEG.trials;
%     Coh(f,:) = Sii./sqrt((Sii.*Sii));
%     % atan2(imag(Sij), real(Sij))
%     phase(f,:) = rad2deg(unwrap(angle(Sii)));
% end
% indfreq = freq>2 & freq<40;
% imagesc(EEGtimes,log10(freq(indfreq)),phase(indfreq,:));
% Fix the y-axis tick labels
% ax = gca;
% fval = 10.^ax.YTick;
% Nf = length(ax.YTick);
% yLabel = cell(Nf,1);
% fval(fval >= 10) = round(fval(fval >= 10));
% for it=1:Nf, yLabel{it} = num2str(fval(it),3);end
% mx = prctile((abs(phase(:))),95);
% set(gca,'YDir','normal','YTickLabel',yLabel,'CLim',[-mx mx]);
% hold on;
% plot([0 0],ylim,'k-.');
% ylabel('Frequency (Hz)')
% grid on;
% xlabel('Time (ms)')
% titlestr = ['ERSP ' targetCh ' ' condition];
% titlestr(titlestr=='_') = ' ';
% title(titlestr);
% colorbar;
% cmap = bipolar(256,0.75);
% colormap(cmap);
% 
% colorbar('Position',[0.9164 0.4106 0.0234 0.5096]);
% cmap = bipolar(256,0.75);
% colormap(cmap);

%The first ROI target
roi = double(hm.indices4Structure(targetCh1_name));
fig2 = vis.plotMaxView(hm,roi);

ax = subplot(3,3,7,'parent',fig);
copy_axes(fig2.Children(4), ax, true)

ax = subplot(3,3,8,'parent',fig);
copy_axes(fig2.Children(3), ax, true)
title(ax,'Sagittal')

ax = subplot(3,3,9,'parent',fig);
copy_axes(fig2.Children(2), ax, true)

close(fig2);
end