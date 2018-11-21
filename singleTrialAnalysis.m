function fig = singleTrialAnalysis(EEG, taskname, condition, targetCh, flag_alignment)
targetCh = cell2mat(targetCh);
fig = figure('Tag', taskname,'UserData',['Single trial analysis- task:' taskname ' condition:' condition ' channel:' targetCh  ' Alignment:' flag_alignment]);
indCh = find(ismember(lower({EEG.chanlocs.labels}),lower(targetCh)));
pop_erpimage(EEG,1, indCh,[], targetCh, 5, 1,{},[],'' ,'yerplabel','\muV','erp','on','cbar','on','topo', { indCh EEG.chanlocs EEG.chaninfo } );
end