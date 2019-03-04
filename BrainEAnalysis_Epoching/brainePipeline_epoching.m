% clear
% CHECK Pilot20 for two folders, collapse middle fish to one
%% Set data and result folder paths
rawData = '/data2/BrainEPilot/BrainE Pilot Data';
results = '/data2/BrainEPilot/BrainE Pilot Results1';
files1 = pickfiles(rawData,{'BrainE.xdf'});
files1p1 = pickfiles(rawData,{'BrainE2.xdf'});
files2 = pickfiles(rawData,{'braine.xdf'});
files = char(files1, files2, files1p1);
Nsubjects = size(files,1);
if ~exist(results,'dir')
    mkdir(results);
end

%% Set parameters
subjectIndices = 1:Nsubjects;
runOnChannels = true;
runOnSources = true;
taskNames = {'go_green','middle_fish','lost_star','lucky_door','face_off','two_tap'};
Ntasks = length(taskNames);
%---------
% PEB+ parameters
overlaping = 25;
solverType = 'bsbl';
saveFull = false;
account4artifacts = true;
postprocCallback = [];
src2roiReductionType = 'hist';

templatefile = headModel.getDefaultTemplateFilename();
conductivity = [0.33, 0.022, 0.33];
orientation = false;
%---------
files = files(subjectIndices,:);
fid = fopen(fullfile(results,'braine_8p3.log'),'w');
c = onCleanup(@()fclose(fid));

%% Run pipeline for every subject
for subject= 1:Nsubjects
    rawFile = deblank(files(subject,:));
    if ~isempty(rawFile)
        [pathName, rawFileName] = fileparts(rawFile);
        
        % Create subject folder if needed
        subjectFolder = fullfile(results,rawFileName);
        if ~exist(subjectFolder,'dir')
            mkdir(subjectFolder);
        end
        
        disp(['Processing subject ' rawFileName ' ' num2str(subject) '/' num2str(Nsubjects)]);
        for task=1 %:Ntasks
            disp(['Processing task' num2str(task)]);
            try
                
                % Create task folder if needed
                subjectTaskFolder = fullfile(results,rawFileName,taskNames{task});
                if ~exist(subjectTaskFolder,'dir')
                    mkdir(subjectTaskFolder);
                end
                
                % Epoching
%                 epochFiles = pickfiles(subjectTaskFolder,{'epoch_','.set'});
                epochFiles = pickfiles(subjectTaskFolder,{'processvars','.mat'},{'processvars','.mat'},{'_v'});
                if isempty(epochFiles)
                    behFile = pickfiles(pathName,'.xlsx');
                    %behFile = deblank(behFile(1,:));
                    switch taskNames{task}
                        case 'go_green'
                            [EEGset, ProcessVars] = go_green.preProcessing(rawFile, behFile);
                        case 'middle_fish'
                            [EEGset, ProcessVars] = middle_fish.preProcessing(rawFile, behFile);
                        case 'lost_star'
                            [EEGset, ProcessVars] = lost_star.preProcessing(rawFile, behFile);
                        case 'lucky_door'
                            [EEGset, ProcessVars] = lucky_door.preProcessing(rawFile, behFile);
                        case 'face_off'
                            [EEGset, ProcessVars] = face_off.preProcessing(rawFile, behFile);
                        case 'two_tap'
                            [EEGset, ProcessVars] = two_tap.preProcessing(rawFile, behFile);
                    end
                    for k=1:length(EEGset)
                        pipelineSettings = ProcessVars(k);
                        EEGset{k}.etc.pipelineSettingsFile = fullfile(subjectTaskFolder,['processvars_' taskNames{task} '_' rawFileName '_' EEGset{k}.setname,'.mat']);
                        pop_saveset(EEGset{k},'filepath',subjectTaskFolder,'filename',['epoch_' taskNames{task} '_' rawFileName '_' EEGset{k}.setname],'savemode','onefile');
                        save(EEGset{k}.etc.pipelineSettingsFile,'pipelineSettings');
                    end
                end
                
                
            catch ME
                ME.message
                                keyboard
                fprintf(fid,'%s\t%s\t%s\n',rawFileName,taskNames{task},ME.message);
            end
        end
    end
end
