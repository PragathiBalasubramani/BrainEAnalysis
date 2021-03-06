function [EEG, fig] = lion_cage()

%% Load data
[FileName,PathName] = uigetfile({'*.set' 'EEGLAB (.set)'; '*.bdf' 'Biosig (.bdf)';'*.xdf' 'LSL (.xdf)'},'Select file');
% EEG = pop_loadxdf('/Users/pragathi/NEATlab/Data/PilotData/Pilot2/Pilot2 BrainE.xdf'); %fullfile(PathName,FileName));
EEGmain = pop_loadxdf(fullfile(PathName,FileName));

%% Parameters
baseline = [-1000 0];
latencies = 100:100:500;
flag_behanalysis = 0;

if flag_behanalysis
    %beh analysis
    %collect the conditions required
    trialset = behavior_events(pathname,behfilename);
else
    trialset.ind = 1:size(EEGmain,3);
    trialset.condition = 'All trials';
end

targetChmain(1).targetCh = 'FCz';


%% Pre-processing
srate = 250;
cutoffFreq = [1 45];
EEGmain.data = double(EEGmain.data);
EEGmain = pop_resample( EEGmain, srate);
EEGmain = pop_eegfiltnew(EEGmain, cutoffFreq(1), cutoffFreq(2), 826,0,[],0);
EEGmain = pop_reref( EEGmain, []);
ind = find(ismember({EEGmain.chanlocs.labels},'TIMESTAMP'));
if ~isempty(ind)
    EEGmain = pop_select(EEGmain,'nochannel',ind);
end
try %#ok
    EEGmain = pop_chanedit(EEGmain, 'eval','chans = pop_chancenter( chans, [],[]);');
end

%channel file specification
xyz = [cell2mat({EEGmain.chanlocs.X})' cell2mat({EEGmain.chanlocs.Y})' cell2mat({EEGmain.chanlocs.Z})'];
xyz = bsxfun(@minus,xyz,mean(xyz));
for k=1:EEGmain.nbchan
    EEGmain.chanlocs(k).X = xyz(k,1);
    EEGmain.chanlocs(k).Y = xyz(k,2);
    EEGmain.chanlocs(k).Z = xyz(k,3);
    [EEGmain.chanlocs(k).theta, EEGmain.chanlocs(k).radius] = cart2pol(xyz(k,1), xyz(k,2), xyz(k,3));
    EEGmain.chanlocs(k).theta = -EEGmain.chanlocs(k).theta*180/pi;
end

%head model specification
template = headModel.getDefaultTemplateFilename();
EEGmain = pop_forwardModel(EEGmain,template);
hmfile = EEGmain.etc.src.hmfile;

figiter = 0;

for iter = 1:length(trialset)
    
    %Just focusing on a particular condition?
    EEG = EEGmain;
    EEG.data = EEGmain.data(:,:,trialset.ind);
    condition = trialset.condition;
    
    %% Epoching
    timelim = [-1 2];
    %epoching and removing baseline in the time period mentioned
    [EEG,rejTrials] = epoching(EEG, timelim);
    EEG = pop_rmbase( EEG, baseline);
    
    %% Source estimation and artifact rejection
    windowSize = 25;
    overlaping = 25;
    solverType = 'bsbl';
    saveFull = true;
    account4artifacts = true;
    %clean EEG
    EEG_clean = pop_inverseSolution(EEG, windowSize, overlaping, solverType, saveFull, account4artifacts);
    
    %Neural activity in the source space
    EEG_src = moveSource2DataField(EEG_clean);
    
    % plotting the cleaned EEG in the headmodel gui
    % eegplot(EEG.data,'srate',EEG.srate,'data2',EEG_clean.data);
    % pop_eegbrowserx(EEG_clean);
    % EEG_clean.etc.src
    
    % The ksdensity function will tell about the shared information between two
    % ROI / EEG related activity
    % figure;ksdensity(EEG_clean.etc.src.act([1 2],:,1));
    % pop_eegplot(EEG_src)
    
    
    %% Figures
    
    for chiter = 1:length(targetChmain)
        
        targetCh = targetChmain(chiter).targetCh;
        
        figiter = figiter + 1;
        %Trial Stats
        fig(figiter) = trialStats(EEG_clean, condition, targetCh);
        
        figiter = figiter + 1;
        %ERP image
        fig(figiter) = singleTrialAnalysis(EEG_clean, targetCh);
        
        %ERSP image
        figiter = figiter + 1;
        [ERSP, times, freq] = ersp(EEG_clean, targetCh,baseline);
        fig(figiter) = erspImage(ERSP, condition, times, freq, targetCh);
        
    end
    
    %TopoPlot
    figiter = figiter + 1;
    fig(figiter) = braineTopoplot(EEG_clean, condition, latencies, EEG.chanlocs, EEG.times);
    
    
    %Source Localisation analysis
    figiter = figiter + 1;
    Peaklatency = findPeaksLatency(EEG_clean.data, EEG.times, baseline);
    fig(figiter) = erpSourceAnalysis(EEG_clean, hmfile, condition, Peaklatency, EEG.times);
    %Specifically for 20 different networks
    %A topoplot
    figiter = figiter + 1;
    fig(figiter) = braineTopoplot(EEG_src, condition, latencies, EEG.chanlocs, EEG.times);
    %On source space analysis
    figiter = figiter + 1;
    Peaklatency = findPeaksLatency(EEG_clean.data, EEG.times, baseline);
    fig(figiter) = erpSourceAnalysis(EEG_clean, hmfile, condition, Peaklatency, EEG.times);
    
end

end


function [EEG,rejTrials] = epoching(EEG, timelim)
eventType = {EEG.event.type};
eventLatency = cell2mat({EEG.event.latency});

% Remove 0 and 99 events
indz = ismember(eventType,{'0','99'});
eventType(indz) = [];
eventLatency(indz) = [];
for k=1:length(eventType)
    eventType{k} = str2double(eventType{k});
end
eventType = cell2mat(eventType);
indnan = isnan(eventType);
eventType(indnan) = [];
eventLatency(indnan) = [];

lion_cage_events = strfind(eventType, 10);
startEvent = find(ismember(eventType,9000));
if isempty(startEvent)
    startEvent = find(ismember(eventType,[900]));
    startEvent(1) = [];
end
endEvent   = find(ismember(eventType,901));
lion_cage_events = lion_cage_events(lion_cage_events > startEvent(1) & lion_cage_events < endEvent(end));

latency = {eventLatency(lion_cage_events)};
eventType = {'go_green'};

EEG = eeg_addnewevents(EEG,latency, eventType);
EEG = pop_epoch( EEG, eventType, timelim, 'epochinfo', 'yes');
[EEG, rejTrials] = pop_autorej(EEG, 'nogui','on','eegplot','off');
end


function fig = braineTopoplot(EEG, condition, latencies, chanlocs, times)
latencies(latencies<min(times)) = min(times);
latencies(latencies>max(times)) = max(times);
ERP = mean(EEG.data,3);

% Topoplots
n = length(latencies);
mx = prctile(abs(ERP(:)),97.5);
indLatency = interp1(times,1:length(times), latencies,'nearest');
fig = figure('Tag','GoGreen','UserData',['Topoplot ' condition '.']);
for i=1:n
    ax = subplot(1,n,i);
    topoplot(ERP(:,indLatency(i)),chanlocs);
    axis(ax,'equal','tight','on');
    set(ax,'CLim',[-mx mx],'YTickLabel',[],'XTickLabel',[],'XColor',[1 1 1],'YColor',[1 1 1]);
    xlabel(ax,[num2str(latencies(i)) ' ms']);
end
colorbar('Position',[0.9331    0.6224    0.0130    0.2312]);
colormap(bipolar(256,0.85));
end

function fig = singleTrialAnalysis(EEG, targetCh)
fig = figure('Tag','GoGreen','UserData',['Single trial analysis channel '  targetCh '.']);
indCh = find(ismember(lower({EEG.chanlocs.labels}),lower(targetCh)));
pop_erpimage(EEG,1, indCh,[], targetCh, 5, 1,{},[],'' ,'yerplabel','\muV','erp','on','cbar','on','topo', { indCh EEG.chanlocs EEG.chaninfo } );
end

function [ERSP, times, freq, ERSP_alltrials] = ersp(EEG, targetCh,baseline)
baseline = EEG.times>baseline(1) & EEG.times<=baseline(2);
times = EEG.times;
indrm = EEG.times<EEG.times(1)*0.9 | EEG.times>EEG.times(end)*0.9;
times(indrm) = [];
baseline(indrm) = [];
ind = ismember({EEG.chanlocs.labels},targetCh);
data = double(squeeze(EEG.data(ind,:,:)));
for t=1:EEG.trials
    [wt,freq] = cwt(data(:,t), 'amor', EEG.srate);
    if t==1
        Pxx = zeros([length(freq) length(times) EEG.trials]);
        ERSP = zeros([length(freq) length(times)]);
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

function fig = erspImage(ERSP, condition, times, freq, targetCh)
% figure;
% newtimef( squeeze(ERP(ind,:)),EEG_incongruent.pnts,[-500 1000],EEG_incongruent.srate, 0,'plotitc','off','baseline',[-500 0]);

fig = figure('Tag','GoGreen','UserData',['ERSP condition ' condition ', channel ' targetCh '.']);
indfreq = freq>2 & freq<40;
imagesc(times,log10(freq(indfreq)),ERSP(indfreq,:));
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
title(['ERSP ' targetCh ' ' condition]);
colorbar;
cmap = bipolar(256,0.75);
colormap(cmap);
end

%%
function Peaklatency = findPeaksLatency(EEG, times, baseline, postStm)
if nargin < 3
    baseline = find(times >-100 & times <= 0);
end
if nargin < 4
    postStm = find(times >=100 & times <= 500);
end
mx = [];
mn = [];
N = size(EEG,1);
for ch=1:N
    mx = [mx findpeaks(EEG(ch,baseline))];
    [~,loc] = findpeaks(-EEG(ch,baseline));
    mn = [mn EEG(ch,baseline(loc))];
end
th_mn = prctile(mn,5);
th_mx = prctile(mx,95);

loc_mx = [];
loc_mn = [];
for ch=1:N
    [pk,loc] = findpeaks(EEG(ch,postStm));
    loc_mx = [loc_mx loc(pk > th_mx)];
    [~,loc] = findpeaks(-EEG(ch,postStm));
    pk = EEG(ch,postStm(loc));
    loc_mn = [loc_mn loc(pk < th_mn)];
end
loc_mx = unique(loc_mx);
loc_mx(diff(loc_mx) < 5) = [];
loc_mn = unique(loc_mn);
loc_mn(diff(loc_mn) < 5) = [];
Peaklatency = postStm(sort([loc_mx loc_mn]));
end

function fig = erpSourceAnalysis(EEG, hmfile, condition, latency, times)

ERP = mean(EEG.data,3);

hm = headModel.loadFromFile(hmfile);
n = length(latency);
X = zeros(size(hm.K,2),n);
solver = bsbl(hm);

for k=1:n
    ind = latency(k)+(-5:5);
    ind(ind>latency(end)) = [];
    x = solver.update(ERP(:,ind));
    X(:,k) = mean(abs(x),2);
end
%             cla(obj.gui.ax);
%             hm.plotMontage(false, obj.gui.ax);
cmap = bipolar(256,0.75);
clim = [0 prctile(X(:),95)];
fig = figure('Tag','GoGreen', 'UserData',['ERP Source Analysis condition ' condition ', channel ' targetCh '.']);
fig.Position(3:4) = [1363 356];
for k=1:n
    ax = subplot(3,n,k);
    patch('vertices',hm.cortex.vertices,'Faces',hm.cortex.faces,'FaceVertexCData',X(:,k),...
        'FaceColor','interp','FaceLighting','phong','LineStyle','none','FaceAlpha',0.3,'SpecularColorReflectance',0,...
        'SpecularExponent',25,'SpecularStrength',0.25,'Parent',ax);
    set(ax,'Clim',clim,'XTick',[],'Ytick',[],'Ztick',[],'XColor',[1 1 1],'YColor',[1 1 1], 'ZColor',[1 1 1]);
    axis(ax, 'vis3d','equal','tight')
    view([-90 90])
    if k==1
        xlabel(ax,'Dorsal');
        title(ax,'L         R','fontweight','normal','fontsize',9);
    end
    if k==n
        cb = colorbar(ax,'position', [0.9219 0.7093 0.0049 0.2157]);
        cb.Ticks = cb.Ticks([1 end]);
        cb.TickLabels = {'0','Max'};
    end
    
    ax = subplot(3,n,k+n);
    patch('vertices',hm.cortex.vertices,'Faces',hm.cortex.faces,'FaceVertexCData',X(:,k),...
        'FaceColor','interp','FaceLighting','phong','LineStyle','none','FaceAlpha',0.3,'SpecularColorReflectance',0,...
        'SpecularExponent',25,'SpecularStrength',0.25,'Parent',ax);
    set(ax,'Clim',clim,'XTick',[],'Ytick',[],'Ztick',[],'XColor',[1 1 1],'YColor',[1 1 1], 'ZColor',[1 1 1]);
    axis(ax, 'vis3d','equal','tight')
    view([0 0])
    if k==1
        zlabel(ax,'Lateral');
        title(ax,'P         A','fontweight','normal','fontsize',9);
    end
    
    ax = subplot(3,n,k+2*n);
    patch('vertices',hm.cortex.vertices,'Faces',hm.cortex.faces,'FaceVertexCData',X(:,k),...
        'FaceColor','interp','FaceLighting','phong','LineStyle','none','FaceAlpha',0.3,'SpecularColorReflectance',0,...
        'SpecularExponent',25,'SpecularStrength',0.25,'Parent',ax);
    set(ax,'Clim',clim,'XTick',[],'Ytick',[],'Ztick',[],'XColor',[1 1 1],'YColor',[1 1 1], 'ZColor',[1 1 1]);
    axis(ax, 'vis3d','equal','tight')
    view(ax,[-90 0]);
    if k==1
        zlabel(ax,'Back');
        title(ax,'L         R','fontweight','normal','fontsize',9);
    end
    ylabel(ax,[num2str(times(latency(k))) ' ms'])
end
colormap(cmap(end/2:end,:));
if n<3
    fig.Position(3:4) = [428 356];
end
end


function fig = trialStats(EEG, condition, targetCh)

nch = length(targetCh);
prcTrials = [0.1 0.15 0.25 0.5 0.6 0.7 0.8 0.9 1];
x = cell(N,1);

trialNumber = round(EEG.trials*prcTrials);
nt = length(trialNumber);
x = zeros(nt, nch);
erp = mean(EEG.data,3);
for ch=1:nch
    indCh = find(ismember({EEG.chanlocs.labels},targetCh{ch}));
    for k=1:nt
        x(k,ch) = corr(erp(indCh,:)',mean(EEG.data(indCh,:,1:trialNumber(k)),3)');
    end
end

fig = figure('Tag','GoGreen','UserData',['TrialStats condition ' condition ', channel ' targetCh '.']);

plot(prcTrials*100,x,'-.')
hold on;
h = plot(prcTrials*100,x,'o');
set(h(1),'color',[0 0.447 0.741]);
set(h(2),'color',[0.85, 0.325, 0.098]);
xlabel('Fraction of trials (%)')

ylabel('Correlation');
legend(targetCh,'Location','southeast');
grid on
ylim([0.5 1]);
xlim(prcTrials([1 end])*100)
end

