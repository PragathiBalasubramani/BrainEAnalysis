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

two_tap_events = strfind(eventType, 11);
startEvent = find(ismember(eventType,50));
if isempty(startEvent)
    startEvent = find(ismember(eventType,[500]));
    startEvent(1) = [];
end
endEvent   = find(ismember(eventType,501));

two_tap_events = two_tap_events(two_tap_events > startEvent(1) & two_tap_events < endEvent(end));

%Now adjust the start time based on the alignment needed
if flag_alignment == 1 %resp onset
    
    %finding the position of the target events
    Targetevents = [11];
    
    [new_two_tap_events,EpochTrials] = compute_events(two_tap_events, eventType, Targetevents);
    
    new_two_tap_events = new_two_tap_events(EpochTrials);
    
    latency = {eventLatency(new_two_tap_events)};
    
    eventType = {[taskname '_resp']};
    
end

EEG = eeg_addnewevents(EEG,latency, eventType);
EEG = pop_epoch( EEG, eventType, timelim, 'epochinfo', 'yes');
[EEG, rejTrials] = pop_autorej(EEG, 'nogui','on','eegplot','off');
end


