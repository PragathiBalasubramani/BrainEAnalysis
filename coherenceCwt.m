function [Coh, EEGtimes, freq] = coherenceCwt(EEG,baseline)
baseline = EEG.times>baseline(1) & EEG.times<=baseline(2);
EEGtimes = EEG.times;
indrm = EEG.times<EEG.times(1)*0.9 | EEG.times>EEG.times(end)*0.9;
EEGtimes(indrm) = [];
baseline(indrm) = [];

data = double(squeeze(EEG.data(1,:,1)));
[wt,freq] = cwt(data, 'amor', EEG.srate);
Nf = size(wt,1);
Coh = LargeTensorC([EEG.nbchan EEG.nbchan size(wt)]);
G = LargeTensorC([EEG.nbchan size(wt) EEG.trials]);
for ch=1:EEG.nbchan
    for t=1:EEG.trials
        G(ch,:,:,t) = cwt(EEG.data(ch,:,t), 'amor', EEG.srate);
    end
end

for ch_i=1:EEG.nbchan
    for ch_j=1:EEG.nbchan
        for f=1:Nf
            Si = squeeze(G(ch_i,f,:,:));
            Sj = squeeze(G(ch_j,f,:,:));
            Sij = diag(Si*Sj')/EEG.trials;
            Sii = diag(Si*Si')/EEG.trials;
            Sjj = diag(Sj*Sj')/EEG.trials;
            Coh(ch_i,ch_j,f,:) = Sij./sqrt((Sii.*Sjj));
            % atan2(imag(Sij), real(Sij))
            phase(ch_i,ch_j,f,:) = rad2deg(unwrap(angle(Sij)));
        end
    end
end
end