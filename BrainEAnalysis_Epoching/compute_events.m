function [new_eventids,EpochTrials] = compute_events(eventids, eventType, Targetevents)
new_eventids = [];
new_eventset = [eventids; eventids + 1; eventids + 2; eventids + 3; eventids + 4; eventids + 5; eventids + 6; eventids + 7; eventids + 8]';
while new_eventset(end,end) > length(eventType) 
    new_eventset = new_eventset(1:end-1,:);
end
new_eventTypeset = eventType(new_eventset);


for iterTrials = 1:length(eventids)
    try
    indhere = find(ismember(new_eventTypeset(iterTrials,:), Targetevents));
    if ~isempty(indhere)
        new_eventids(iterTrials) = new_eventset(iterTrials, indhere(1));
    else
        new_eventids(iterTrials) = nan;
    end
    catch
        new_eventids(iterTrials) = nan;
    end
end
EpochTrials = ~isnan(new_eventids);
end