function [ERSP, EEGtimes, freq, ERSP_alltrials] = ersp(EEG, targetCh,baseline)
baseline = EEG.times>baseline(1) & EEG.times<=baseline(2);
EEGtimes = EEG.times;
indrm = EEG.times<EEG.times(1)*0.9 | EEG.times>EEG.times(end)*0.9;
EEGtimes(indrm) = [];
baseline(indrm) = [];
ind = ismember({EEG.chanlocs.labels},targetCh);
data = double(squeeze(EEG.data(ind,:,:)));
for t=1:EEG.trials
    [wt,freq] = cwt(data(:,t), 'amor', EEG.srate);
    if t==1
        Pxx = zeros([length(freq) length(EEGtimes) EEG.trials]);
        ERSP = zeros([length(freq) length(EEGtimes)]);
        [~,sorting] = sort(freq);
    end
    Pxx(:,:,t) = abs(wt(sorting,~indrm)).^2;
end
mu = mean(mean(Pxx(:,baseline,:),2),3);
ERSP(:,:) = mean(bsxfun(@minus,Pxx, mu),3);
ERSP_alltrials(:,:,:) = bsxfun(@minus,Pxx, mu);
freq = freq(sorting);
ERSP(freq<1,:,:) = [];
ERSP_alltrials(freq<1,:,:) = [];
freq(freq<1) = [];
end