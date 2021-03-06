function [EEG_clean, fig, rejTrials, statsinfo] = face_off(EEGmain, tabledata, flag_save, flag_alignment)

%% Load data
% [FileName,PathName] = uigetfile({'*.set' 'EEGLAB (.set)'; '*.bdf' 'Biosig (.bdf)';'*.xdf' 'LSL (.xdf)'},'Select file');
% EEG = pop_loadxdf('/Users/pragathi/NEATlab/Data/PilotData/Pilot2/Pilot2 BrainE.xdf'); %fullfile(PathName,FileName));
% EEGmain = pop_loadxdf(fullfile(PathName,FileName));

taskname = 'FaceOff';

%% Parameters
statsinfo = [];

targetChmain(1).targetCh = {'FCz'};

timelim = [-.5 2];% for epoching, based on the time locking event

baseline = [-500 0];
latencies = 100:100:500;

%filtering
srate = 250;
cutoffFreq = [1 55];

%source estimation, network analysis- bsbl, peb plus
windowSize = 25;
overlaping = 25;
solverType = 'bsbl';
saveFull = true;
account4artifacts = true;

%plotting

figiter = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% keyboard

%% Preliminary Filtering
EEGmain.data = double(EEGmain.data);
EEGmain = pop_resample( EEGmain, srate);
EEGmain = pop_eegfiltnew(EEGmain, cutoffFreq(1), cutoffFreq(2), 826,0,[],0);
% EEGmain = pop_eegfiltnew(EEGmain, cutoffFreq(1), [], 826,0,[],0);

EEGmain = pop_reref( EEGmain, []);
ind = find(ismember({EEGmain.chanlocs.labels},'TIMESTAMP'));
if ~isempty(ind)
    EEGmain = pop_select(EEGmain,'nochannel',ind);
end

try %#ok
    EEGmain = pop_chanedit(EEGmain, 'eval','chans = pop_chancenter( chans, [],[]);');
end

%channel file specification, locate, find theta (using cartesian 2 polar
%conversions for every channel
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
hm = headModel.loadFromFile(hmfile);

%% Epoching
%epoching and removing baseline in the time period mentioned
[EEGmain,rejTrials,EpochTrials] = epoching(EEGmain, timelim, flag_alignment.num, taskname);
EEGmain = pop_rmbase( EEGmain, baseline);


%% Source estimation and artifact rejection
%clean EEG
EEG_clean = pop_inverseSolution(EEGmain, windowSize, overlaping, solverType, saveFull, account4artifacts);

nw = load('Networks_BrainE.mat','network'); % obtain network variable involving a mask for different networks
funcnetwork = nw.network;

%sanity check to see if the beh data and the EEG trials balance
%The program is in such a way that the order of trials are maintained the
%same between the beh file and the EEG matrix

%beh analysis
%collect the conditions required
trialset = behavior_events(tabledata, rejTrials, EpochTrials);

%trialset's end structure has all the trials in it, that belongs to a
%particular task
sanitycheck = setdiff(1:max(trialset(end).ind),[1:size(EEG_clean.data,3)]);

%             keyboard

%%
if isempty(sanitycheck)
    for iter = 1:length(trialset)
        %Just focusing on a particular condition?
        EEG = EEG_clean; %duplicating the main EEG matrix- cleaned
        
        condition = trialset(iter).condition;
        
        %finding the indices of the eegepoch that belongs to a condition
        trialsetind = trialset(iter).ind;
        
        
        if ~isempty(trialsetind)
            %epoching based on a condition
            EEG.data = EEG.data(:,:,trialsetind); %clean data
            EEG.trials = length(trialsetind);
            EEG.event = [];%macell2matke sure the structure is not used, since the trial information is modified
            EEG.urevent = [];%make sure the structure is not used, since the trial information is modified
            EEG.epoch = [];
            %% Figures
            
            for chiter = 1:length(targetChmain)
                
                targetCh = targetChmain(chiter).targetCh;
                %%
                try
                    figiter = figiter + 1;
                    %Trial Stats
                    fig(figiter) = trialStats(EEG, condition, targetCh, flag_alignment.name, taskname);
                    tempdata = get(fig(figiter),'UserData');
                    tempdata = cell2mat(tempdata);
                    tempdata(tempdata==' ') = '_';
                    if flag_save == 1, saveas(fig(figiter),[(tempdata)],'png'); end
                end
                %%
                try
                    figiter = figiter + 1;
                    %ERP image
                    fig(figiter) = singleTrialAnalysis(EEG, taskname, condition, targetCh, flag_alignment.name);
                    tempdata = get(fig(figiter),'UserData');
                    tempdata(tempdata==' ') = '_';
                    if flag_save == 1, saveas(fig(figiter),[(tempdata)],'png'); end
                end
                
                %% ERSP image
                try
                    figiter = figiter + 1;
                    [ERSP, EEGtimes, freq] = ersp(EEG, targetCh,baseline);
                    fig(figiter) = erspImagePlot(ERSP, targetCh, EEGtimes, freq, taskname, condition, flag_alignment.name);
                    tempdata = get(fig(figiter),'UserData');
                    tempdata(tempdata==' ') = '_';
                    if flag_save == 1, saveas(fig(figiter),[(tempdata)],'png'); end
                end
            end
            
            %% TopoPlot
            try
                figiter = figiter + 1;
                fig(figiter) = braineTopoplot(EEG, taskname, condition, flag_alignment.name, latencies, EEG.chanlocs, EEGtimes);
                tempdata = get(fig(figiter),'UserData');
                tempdata(tempdata==' ') = '_';
                if flag_save == 1, saveas(fig(figiter),[(tempdata)],'png'); end
            end
            %%  Source Localisation analysis, general
            %             Peaklatency = findPeaksLatency(EEG.data, EEG.times, baseline);
            %             For consistency across data sets
            Peaklatency = [25 50 100 150 200 250 300 350 400 450 500];
            
            %% --Evidence against similarity to optimal cortical source, (For every network)
%             
            figiter = figiter + 1;
            [fig(figiter), Bf] = computeNwEvidence(EEGmain, EEG, hm, funcnetwork, trialsetind, Peaklatency, taskname, condition, flag_alignment.name);
            tempdata = get(fig(figiter),'UserData');
            tempdata(tempdata==' ') = '_';
            if flag_save == 1, saveas(fig(figiter),[(tempdata)],'png'); end
            
            
            %% Pick the top network and perform ERSP for each of its ROI, also do the wavelet based coherence, and phase computation
            EEG.etc.src.act = EEG.etc.src.act(:,:,trialsetind);
            EEG_src = moveSource2DataField(EEG);
            [~, sortnet] = sort(min(Bf,[],2),'ascend');
            %pick the first network
            net = sortnet(1);
            indNet = find(ismember(hm.atlas.label,funcnetwork(net).ROI));
            indNet_cmpr = find(ismember(hm.atlas.label,{'G_postcentral R'        }));
            for chi = 1:length(indNet)
                try
                    figiter = figiter + 1;
                    targetChs = {EEG_src.chanlocs(indNet(chi)).labels};
                    [ERSP, EEGtimes, freq] = ersp(EEG_src, targetChs,baseline);
                    fig(figiter) = erspImageROI(ERSP, hm, targetChs, EEGtimes, freq, taskname, condition, flag_alignment.name);
                    tempdata = get(fig(figiter),'UserData');
                    tempdata(tempdata==' ') = '_';
                    if flag_save == 1, saveas(fig(figiter),[(tempdata)],'png'); end
                
                    %Obtaining phase information with respect to the
                    %{'G_postcentral R'        }-- arbitrarily chosen
                    figiter = figiter + 1;
                    fig(figiter) = wcoherenceROI(EEG_src, hm, indNet(chi), indNet_cmpr, taskname, condition, flag_alignment.name);
                    tempdata = get(fig(figiter),'UserData');
                    tempdata = cell2mat(tempdata);
                    tempdata(tempdata==' ') = '_';
                    if flag_save == 1, saveas(fig(figiter),[(tempdata)],'png'); end
                    
                end
            end
            
        end
    end
end

end


function [EEG,rejTrials,EpochTrials] = epoching(EEG, timelim, flag_alignment, taskname)
%flag_alignment: 1) trial onset based, 2) stimulus onset based, 3) response
%based, 4) feedback based

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

%%%%%%%%%%first obtain all the trials, with respect to the trial onset

face_off_events = strfind(eventType, 10);
startEvent = find(ismember(eventType,4000));
if isempty(startEvent)
    startEvent = find(ismember(eventType,[400]));
    startEvent(1) = [];
end
endEvent   = find(ismember(eventType,401));

face_off_events = face_off_events(face_off_events > startEvent(1) & face_off_events < endEvent(end));

%Now adjust the start time based on the alignment needed
if flag_alignment == 1 %trial onset
    
    EpochTrials = ~isnan(face_off_events);
    
    latency = {eventLatency(face_off_events)};
    eventType = {[taskname]};
    
elseif flag_alignment == 2 %stim onset
    
    %finding the position of the target events
    Targetevents = [1:8, 21:24]; %could be 21:24 to mention the direction of arrows and the top / bottom location
    
    [new_face_off_events,EpochTrials] = compute_events(face_off_events, eventType, Targetevents);
    
    new_face_off_events = new_face_off_events(EpochTrials);
    
    latency = {eventLatency(new_face_off_events)};
    
    eventType = {[taskname '_stim']};
    
elseif flag_alignment == 3 %resp onset
    
    %finding the position of the target events
    Targetevents = [11 12 13];
    
    [new_face_off_events,EpochTrials] = compute_events(face_off_events, eventType, Targetevents);
    
    new_face_off_events = new_face_off_events(EpochTrials);
    
    latency = {eventLatency(new_face_off_events)};
    
    eventType = {[taskname '_resp']};
    
elseif flag_alignment == 4 %feedback onset
    
    %finding the position of the target events
    Targetevents = [14, 15];
    
    [new_face_off_events,EpochTrials] = compute_events(face_off_events, eventType, Targetevents);
    
    new_face_off_events = new_face_off_events(EpochTrials);
    
    latency = {eventLatency(new_face_off_events)};
    
    eventType = {[taskname '_fdbk']};
    
end

EEG = eeg_addnewevents(EEG,latency, eventType);
EEG = pop_epoch( EEG, eventType, timelim, 'epochinfo', 'yes');
[EEG, rejTrials] = pop_autorej(EEG, 'nogui','on','eegplot','off');
end



function [trialset] = behavior_events(tabledata, rejTrials, EpochTrials)

%load the behavioral data
% fullFileName1 = fullfile(pathname,behfilename);
%
% tabledata = readtable(fullFileName1);
try
    %find the actual working block
    
    %Taking away the beh data trials whose EEG has been rejected
    tabledata = tabledata(EpochTrials,:); %first pooling the trials of interest
    tabledata(rejTrials,:) = []; %taking out the rejected trials in the pooled set
    
    
    desiredblock = find(tabledata.Block ~= 0);
    actualdata = tabledata(desiredblock,:);
    
    
    %performance events
    perf = actualdata.Accuracy;
    
    perf_inacc = desiredblock(find(perf == 0));
    perf_acc = desiredblock(find(perf == 1));
    
    trialset(1).ind = perf_inacc;
    trialset(1).condition = 'Inaccurate';
    trialset(2).ind = perf_acc;
    trialset(2).condition = 'Accurate';
    
    
    %reaction time events
    rtime = actualdata.ResponseTime;
    
    rtime_fast = desiredblock(find(rtime < median(rtime)));
    rtime_slow = desiredblock(find(rtime > median(rtime)));
    
    
    trialset(3).ind = rtime_fast;
    trialset(3).condition = 'RT fast';
    trialset(4).ind = rtime_slow;
    trialset(4).condition = 'RT slow';
    
    
    %stimulus based events, Match probe and nonMatch probe
    stim = actualdata.Stimulus;
    
    Neutral  = desiredblock(find(stim == 1 | stim == 2));
    Happy = desiredblock(find(stim == 3 | stim == 4));
    Angry  = desiredblock(find(stim == 5 | stim == 6));
    Sad = desiredblock(find(stim == 7 | stim == 8));
    
    Male = desiredblock(find(stim == 1 | stim == 3 | stim == 5 | stim == 7 ));
    Female = desiredblock(find(stim == 2 | stim == 4 | stim == 6 | stim == 8));
    
    trialset(5).ind = Neutral;
    trialset(5).condition = 'Neutral';
    trialset(6).ind = Happy;
    trialset(6).condition = 'Happy';
    trialset(7).ind = Angry;
    trialset(7).condition = 'Angry';
    trialset(8).ind = Sad;
    trialset(8).condition = 'Sad';
    
    trialset(9).ind = Male;
    trialset(9).condition = 'Male';
    trialset(10).ind = Female;
    trialset(10).condition = 'Female';
    
    
    %Stim present in the upper / lower face
    
    Upper = desiredblock(find(stim == 21 | stim == 22));
    Lower = desiredblock(find(stim == 23 | stim == 24));
    
    %left /right
    Left = desiredblock(find(stim == 21 | stim == 23));
    Right = desiredblock(find(stim == 22 | stim == 24));
    
    trialset(11).ind = Upper;
    trialset(11).condition = 'Upper';
    trialset(12).ind = Lower;
    trialset(12).condition = 'Lower';
    trialset(13).ind = Left;
    trialset(13).condition = 'Left';
    trialset(14).ind = Right;
    trialset(14).condition = 'Right';
    
    trialset(end+1).ind = desiredblock;
    trialset(end).condition = 'All Trials';
    
catch
    
    trialsetnow = 1:length(EpochTrials);
    trialsetnow = trialsetnow(EpochTrials);
    trialsetnow(rejTrials) = [];
    trialset.ind = 1:length(trialsetnow);   
    trialset.condition = 'All Trials';
end

end
