function fig = erspImageROI(ERSP, hm, targetCh, EEGtimes, freq, taskname, condition, flag_alignment)
% figure;
% newtimef( squeeze(ERP(ind,:)),EEG_incongruent.pnts,[-500 1000],EEG_incongruent.srate, 0,'plotitc','off','baseline',[-500 0]);
targetCh = cell2mat(targetCh);
fig = figure('Tag', taskname,'UserData',['ERSP- task:' taskname ' condition:' condition ' ROI:' targetCh ' Alignment:' flag_alignment]);
fig.Position(3:4) = [562   640];
indfreq = freq>2 & freq<40;
ax = subplot(3,3,1:6);
imagesc(EEGtimes,log10(freq(indfreq)),ERSP(indfreq,:));
% Fix the y-axis tick labels
fval = 10.^ax.YTick;
Nf = length(ax.YTick);
yLabel = cell(Nf,1);
fval(fval >= 10) = round(fval(fval >= 10));
for it=1:Nf, yLabel{it} = num2str(fval(it),3);end
mx = prctile((abs(ERSP(:))),95);
set(gca,'YDir','normal','YTickLabel',yLabel,'CLim',[-mx mx]);
hold on;
plot([0 0],ylim,'k-.');
ylabel('Frequency (Hz)')
grid on;
xlabel('Time (ms)')
titlestr = ['ERSP ROI: ' targetCh '  Condition: ' condition];
titlestr(titlestr=='_') = ' ';
title(titlestr);
colorbar('Position',[0.9164 0.4106 0.0234 0.5096]);
cmap = bipolar(256,0.75);
colormap(cmap);

roi = double(hm.indices4Structure(targetCh));
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
