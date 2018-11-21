
function fig = trialStats(EEG, condition, targetCh, flag_alignment, taskname)

nch = length(targetCh);
prcTrials = [0.1 0.15 0.25 0.5 0.6 0.7 0.8 0.9 1];
trialNumber = round(size(EEG.data,3)*prcTrials);
nt = length(trialNumber);
x = zeros(nt, nch);
erp = mean(EEG.data,3);
for ch=1:nch
    indCh = find(ismember({EEG.chanlocs.labels},targetCh{ch}));
    for k=1:nt
        x(k,ch) = corr(erp(indCh,:)',mean(EEG.data(indCh,:,1:trialNumber(k)),3)');
    end
end

fig = figure('Tag',taskname,'UserData',['TrialStats task:' taskname ' condition:' condition ' channel:' targetCh  ' Alignment:' flag_alignment]);

h = plot(prcTrials*100,x,'-.o');

set(h,'color',[0 0.447 0.741]);

xlabel('Fraction of trials (%)')

ylabel('Correlation');
legend(targetCh,'Location','southeast');
grid on
ylim([0.5 1]);
xlim(prcTrials([1 end])*100)
end