function [fig, Bf_m] = computeNwEvidence(EEGmain, EEG, hm, funcnetwork, trialsetind, Peaklatency, taskname, condition, flag_alignment)
%source estimation, network analysis- bsbl, peb plus
windowSize = 25;
data_raw = EEGmain.data(:,:,trialsetind);
lambda = EEG.etc.src.lambda(:,trialsetind);
gamma = EEG.etc.src.gamma(:,:,trialsetind);
LogEM0 = EEG.etc.src.logE(:,trialsetind);
logE = zeros([length(funcnetwork), length(Peaklatency), EEG.trials]);
logEM0 = zeros(length(Peaklatency), EEG.trials);
for net=1:length(funcnetwork)
    indNet = find([ismember(hm.atlas.label,funcnetwork(net).ROI) true(1,length(EEG.etc.src.indV))]);
    for l=1:length(Peaklatency)
        [~,loc] = min(abs(EEG.times(Peaklatency(l))-EEG.etc.src.indGamma));
        indWindow = Peaklatency(l)-windowSize+1:Peaklatency(l);
        for trial=1:EEG.trials
            logEM0(l,trial) = LogEM0(loc,trial);
            Cy = (data_raw(:,indWindow,trial)*data_raw(:,indWindow,trial)')/windowSize;
            [logE(net,l,trial), Sy] = EEG.etc.src.solver.calculateLogEvidence(Cy,lambda(loc,trial),gamma(:,loc,trial),indNet);
            %                         subplot(121);imagesc(Cy);title(num2str(logEM0(l,trial)));subplot(122);imagesc(Sy);title(num2str(logE(net,l,trial)));
            %                         drawnow
            %                         pause(.21)
        end
    end
end
%Bayes Factor is the division of the network log evidence to the ground
%truth (It provides  evidence against H0)
Bf = 2*bsxfun(@minus,logE,shiftdim(logEM0,-1));
Bf_m = median(Bf,3);
% TO normalized?
Bf_m = abs(Bf_m); %/max(abs(Bf_m(:))));

fig = figure('Tag', taskname,'UserData',['NwEvidence- task:' taskname ' condition:' condition ' Alignment:' flag_alignment]);
fig.Position(3:4) = [1200 586];
bar(Bf_m);
hold on; plot(get(gca,'xlim'),[6 6],'-.');hold off
% ax = gca;
%set(ax,'YTick',[-1 0],'YTickLabel',{'Low','High'})
flag_alignment(flag_alignment=='_') = ' ';
% xtick = [];xticklabels(Peaklatency);
xtick = [];xticklabels({funcnetwork(:).name});
% xlabel(['msec from ' flag_alignment]);
xlabel('Networks');
title(['Aligned to ' flag_alignment]);
ylabel('Bayes Factor (Evidence against optimal cortical source map)')
legend(num2str(Peaklatency'),'Location','NorthWestOutside')
%             plot(2*bsxfun(@minus,squeeze(logE(:,2,:)),logEM0(2,:))');hold on;plot([0 83],[-6 -6],[0 83],[6 6],'-.');hold off
%           figure;eegplot(EEGmain.data,EEGmain.srate,'data2',EEG_clean.data);+1:Peaklatency(l);
