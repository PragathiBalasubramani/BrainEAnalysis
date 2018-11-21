function [new_eventids,EpochTrials] = compute_events(eventids, eventType, Targetevents)
new_eventids = [];
new_eventset = [eventids; eventids + 1; eventids + 2; eventids + 3; eventids + 4]';
new_eventTypeset = eventType(new_eventset);

for iterTrials = 1:length(eventids)
    indhere = find(ismember(new_eventTypeset(iterTrials,:), Targetevents));
    if ~isempty(indhere)
        new_eventids(iterTrials) = new_eventset(iterTrials, indhere(1));
    else
        new_eventids(iterTrials) = nan;
    end
end

EpochTrials = ~isnan(new_eventids);
end