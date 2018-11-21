function fig = braineTopoplot(EEG, taskname, condition, flag_alignment, latencies, chanlocs, EEGtimes)
latencies(latencies<min(EEGtimes)) = min(EEGtimes);
latencies(latencies>max(EEGtimes)) = max(EEGtimes);

% Topoplots
n = length(latencies);
mx = prctile(abs(EEG.data(:)),97.5);
indLatency = interp1(EEGtimes,1:length(EEGtimes), latencies,'nearest');
fig = figure('Tag',taskname,'UserData',['Topoplot task:' taskname ' condition:' condition  ' Alignment:' flag_alignment]);
for i=1:n
    ax = subplot(1,n,i);
    topoplot(EEG.data(:,indLatency(i)),chanlocs);
    axis(ax,'equal','tight','on');
    set(ax,'CLim',[-mx mx],'YTickLabel',[],'XTickLabel',[],'XColor',[1 1 1],'YColor',[1 1 1]);
    xlabel(ax,[num2str(latencies(i)) ' ms']);
end
colorbar('Position',[0.9331    0.6224    0.0130    0.2312]);
colormap(bipolar(256,0.85));
end
