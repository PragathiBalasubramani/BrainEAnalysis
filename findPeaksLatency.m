function Peaklatency = findPeaksLatency(EEG, EEGtimes, baseline, postStm)
EEGnow = mean(EEG,3);
if nargin < 3
    baseline = find(EEGtimes >-100 & EEGtimes <= 0);
else
    baseline = find(EEGtimes >baseline(1) & EEGtimes <= baseline(2));
end
if nargin < 4
    postStm = find(EEGtimes >=100 & EEGtimes <= 500);
end
mx = [];
mn = [];
N = size(EEGnow,1);
for ch=1:N
    mx = [mx findpeaks(EEGnow(ch,baseline))];
    [~,loc] = findpeaks(-EEGnow(ch,baseline));
    mn = [mn EEGnow(ch,baseline(loc))];
end
th_mn = prctile(mn,5);
th_mx = prctile(mx,95);

loc_mx = [];
loc_mn = [];
for ch=1:N
    [pk,loc] = findpeaks(EEGnow(ch,postStm));
    loc_mx = [loc_mx loc(pk > th_mx)];
    [~,loc] = findpeaks(-EEGnow(ch,postStm));
    pk = EEGnow(ch,postStm(loc));
    loc_mn = [loc_mn loc(pk < th_mn)];
end
loc_mx = unique(loc_mx);
loc_mx(diff(loc_mx) < 5) = [];
loc_mn = unique(loc_mn);
loc_mn(diff(loc_mn) < 5) = [];
Peaklatency = unique(postStm(sort([loc_mx loc_mn])));
end