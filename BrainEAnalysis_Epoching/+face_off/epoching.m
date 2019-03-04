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

face_off_events = face_off_events(face_off_events > startEvent(end) & face_off_events < endEvent(end));

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
