
%select the folder for analysis
disp('Select the folder path for analysis');
selpath = uigetdir(matlabroot,'MATLAB Root Folder');

if isempty(fileList) %when the main folder with all participant data is selected
    nsubjects = length(dir(selpath)) - 3; %to exclude DSstore, ., ..
else
    nsubjects = 1; %just do single subject analysis
end

for itersubject = 1:nsubjects
    %load the directory and the file for each subject
    if nsubjects > 1
        selpathnext = dir(selpath);
        foldername = selpathnext(3+itersubject).name;
        fileList = dir(fullfile(selpath, foldername, '*BrainE.xdf'));
        behfileList = dir(fullfile(selpath, foldername, '*Behavior_Data.xlsx'));
    else %just a single subject
        fileList = dir(fullfile(selpath, '*BrainE.xdf'));
        behfileList = dir(fullfile(selpath, '*Behavior_Data.xlsx'));
    end
    
    EEGmain = pop_loadxdf(fullfile(fileList(1).folder,fileList(1).name));
    
    %Run different BrainE task analysis
    
    %Go Green
    tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',3);
    [EEG_gg, fig_gg] = go_green(EEGmain, tabledata);
    
    %middle fish
    tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',1);
    [EEG_mf, fig_mf] = middle_fish(EEGmain, tabledata);
    
    %lost star
    tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',2);
    [EEG_ls, fig_ls] = lost_star(EEGmain, tabledata);
    
    %lucky door
    tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',5);
    [EEG_ld, fig_ld] = lucky_door(EEGmain, tabledata);
    
    %     %lion cage
    %         tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',1);
    % [EEG_lc, fig_lc] = lion_cage(EEGmain, tabledata);
    
    %face off
    tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',4);
    [EEG_fo, fig_fo] = face_off(EEGmain, tabledata);
    
    
    %Use the fig handles for report generation
    
end


