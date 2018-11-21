function fig = erspImagePlot(ERSP, targetCh, EEGtimes, freq, taskname, condition, flag_alignment)
% figure;
% newtimef( squeeze(ERP(ind,:)),EEG_incongruent.pnts,[-500 1000],EEG_incongruent.srate, 0,'plotitc','off','baseline',[-500 0]);
targetCh = cell2mat(targetCh);

fig = figure('Tag', taskname,'UserData',['ERSP- task:' taskname ' condition:' condition ' channel:' targetCh  ' Alignment:' flag_alignment]);
indfreq = freq>2 & freq<40;
imagesc(EEGtimes,log10(freq(indfreq)),ERSP(indfreq,:));
% Fix the y-axis tick labels
ax = gca;
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
titlestr = ['ERSP ' targetCh ' ' condition];

titlestr(titlestr=='_') = ' ';
title(titlestr);
colorbar;
cmap = bipolar(256,0.75);
colormap(cmap);
end
