dbstop if error

%select the folder for analysis
disp('Select the folder path for analysis');
selpath = uigetdir('/home/pragathib/BrainEPilot');

fileList = dir(fullfile(selpath, '*BrainE.xdf'));

if isempty(fileList) %when the main folder with all participant data is selected
    nsubjects = length(dir(selpath)) - 3; %to exclude DSstore, ., ..
else
    nsubjects = 1; %just do single subject analysis
end

flag_save = 1; %1 = save as figs, 2 = in a report, 0 = not save (risk of overwitten figures)

% flag_alignment.num = 3; %1 = trial onset, 2 = stim onset, 3 = response onset, 4 = feedback onset, 5 = net coin tally time (Lucky Door), 6 probe in the case of lost star
% flag_alignment.name = 'feedback';
%%
for indalign = 3:6
    
    switch indalign
        case 1
            flag_alignment.num = 1;
            flag_alignment.name = 'trial_start';
        case 2
            flag_alignment.num = 2;
            flag_alignment.name = 'stim_start';
            
        case 3
            flag_alignment.num = 3;
            flag_alignment.name = 'resp';
            
        case 4
            flag_alignment.num = 4;
            flag_alignment.name = 'feedback';
            
        case 5
            flag_alignment.num = 5;
            flag_alignment.name = 'NetFdbk';
            
        case 6
            flag_alignment.num = 6;
            flag_alignment.name = 'Probe';
            
    end
    
    % outputs of interest from each of the module, EEG (aligned based on the
    % flag, and the network activations for 8 different functional networks)
    
    % (8 different) network filter * trials * time * spectral information, and
    % they are graded based on the activity more representative of the ideal
    % network of activity.
    
    %post stimulus activity (500 msec) for the participant report
    
    for itersubject = 1 %:nsubjects
        %load the directory and the file for each subject
        if nsubjects > 1
            selpathnext = dir(selpath);
            foldername = selpathnext(3+itersubject).name;
            fileList = dir(fullfile(selpath, foldername, '*BrainE.xdf'));
            behfileList = dir(fullfile(selpath, foldername, '*Behavior_Data.xlsx'));
            cd(fullfile(selpath, foldername));
        else %just a single subject
            fileList = dir(fullfile(selpath, '*BrainE.xdf'));
            behfileList = dir(fullfile(selpath, '*Behavior_Data.xlsx'));
            cd(fullfile(selpath));
        end
        
        EEGmain = pop_loadxdf(fullfile(fileList(1).folder,fileList(1).name));
        
        %Run different BrainE task analysis
        
        %     %Go Green
        try
            close all;
            %         try
            %             tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',4);
            %         catch
            tabledata = [];
            %         end
            [EEG_gg, fig_gg, rejTrials_gg, statsinfo_gg] = go_green(EEGmain, tabledata, flag_save, flag_alignment);
        end
        
        %middle fish
        try
            close all;
            
            %         try
            %             tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',1);
            %         catch
            %             tabledata = [];
            %         end
            [EEG_mf, fig_mf, rejTrials_mf, statsinfo_mf] = middle_fish(EEGmain, tabledata, flag_save, flag_alignment);
        end
        
        
        %     %lost star
        try
            close all;
            
            %         try
            %             tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',2);
            %         catch
            %             tabledata = [];
            %         end
            [EEG_ls, fig_ls, rejTrials_ls, statsinfo_ls] = lost_star(EEGmain, tabledata, flag_save, flag_alignment);
        end
        
        
        %     %lucky door
        
        try
            close all;
            
            %         try
            %             tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',6);
            %         catch
            %             tabledata = [];
            %         end
            [EEG_ld, fig_ld, rejTrials_ld, statsinfo_ld] = lucky_door(EEGmain, tabledata, flag_save, flag_alignment);
        end
        
        
        %     %face off
        
        try
            close all;
            
            %         try
            %             tabledata = readtable(fullfile(behfileList(1).folder,behfileList(1).name),'Sheet',5);
            %         catch
            %             tabledata = [];
            %         end
            [EEG_fo, fig_fo, rejTrials_fo, statsinfo_fo] = face_off(EEGmain, tabledata, flag_save, flag_alignment);
        end
        %
        
        
    end
    
    
end
%% Other plot commands
% EEG_clean = EEGmain;
%
% keyboard
%Neural activity in the source space
% EEG_src = moveSource2DataField(EEG_clean);

%networks can be obtained from the below
% nw = load('Networks_BrainE.mat','network'); % obtain network variable involving a mask for different networks
% funcnetwork = nw.network;


%Use the fig handles for report generation
%     EEG_src = moveSource2DataField(EEG_clean); %use this command for
%     moving the source field in the EEG matrix to the data matrix., then
%     the ERSP denoting the activity at every required frequency can be
%     calculated


% plotting the cleaned EEG in the headmodel gui
% eegplot(EEG.data,'srate',EEG.srate,'data2',EEG_clean.data);
% pop_eegbrowserx(EEG_clean);
% EEG_clean.etc.src
%Nw indices of interest
%Cingulo opercular network
% hm.indices4Structure(hm.atlas.label)
%mask for the network

%load the ROI mat file, and then multiply the mask to the EEG source
% indG = EEG_clean.etc.src.indG;
% funcnetwork(1).src = bsxfun(@times,EEG_clean.etc.src.actFull(indG,:,:),funcnetwork(i).mask);

% n = length(funcnetwork);
% M = [];
% for k=1:n
%     M = [M any(hm.indices4Structure(funcnetwork(k).ROI),2);];
% end
% hm.plotOnModel(M)
%
% connectivity analysis
% The ksdensity function will tell about the shared information between two
% ROI / EEG related activity
% figure;ksdensity(EEG_clean.etc.src.act([1 2],:,1));
% pop_eegplot(EEG_src)
% vis.DesignROIs

%  cla(obj.gui.ax);
%  hm.plotMontage(false, obj.gui.ax);
%
% %% --
% data_raw = EEGmain.data(:,:,trialsetind);
% lambda = EEG.etc.src.lambda(:,trialsetind);
% gamma = EEG.etc.src.gamma(:,:,trialsetind);
% LogEM0 = EEG.etc.src.logE(:,trialsetind);
% logE = zeros([length(funcnetwork), length(Peaklatency), EEG.trials]);
% logEM0 = zeros(length(Peaklatency), EEG.trials);
% for net=1:length(funcnetwork)
%     indNet = find([ismember(hm.atlas.label,funcnetwork(net).ROI) true(1,length(EEG.etc.src.indV))]);
%     for l=1:length(Peaklatency)
%         [~,loc] = min(abs(EEG.times(Peaklatency(l))-EEG.etc.src.indGamma));
%         indWindow = Peaklatency(l)-windowSize+1:Peaklatency(l);
%         for trial=1:EEG.trials
%             logEM0(l,trial) = LogEM0(loc,trial);
%             Cy = (data_raw(:,indWindow,trial)*data_raw(:,indWindow,trial)')/windowSize;
%             [logE(net,l,trial), Sy] = EEG.etc.src.solver.calculateLogEvidence(Cy,lambda(loc,trial),gamma(:,loc,trial),indNet);
%             %                         subplot(121);imagesc(Cy);title(num2str(logEM0(l,trial)));subplot(122);imagesc(Sy);title(num2str(logE(net,l,trial)));
%             %                         drawnow
%             %                         pause(.21)
%         end
%     end
% end
% Bf = 2*bsxfun(@minus,logE,shiftdim(logEM0,-1));
%
% figiter = figiter + 1;
%
% %             subplot 211
% %             plot(mean(Bf,3)')
% %
% %             mean(logEM0,2)
% %
% %             subplot 212
% %             plot(median(Bf,3)')
% fig(figiter) = figure;
% bar(mean(Bf,3)');
% xlabel(['msec from ' flag_alignment.name]);
% ylabel('Bayes factor')
% legend(funcnetwork(:).name,'Location','SouthWest')
% tempdata = ['BayesFactor condition', condition];
% tempdata = [tempdata, flag_alignment.name];
% if flag_save == 1, saveas(fig(figiter),['middle_fish',num2str(figiter),'',(tempdata)],'png'); end
%
% %             plot(2*bsxfun(@minus,squeeze(logE(:,2,:)),logEM0(2,:))');hold on;plot([0 83],[-6 -6],[0 83],[6 6],'-.');hold off
% %           figure;eegplot(EEGmain.data,EEGmain.srate,'data2',EEG_clean.data);
% %% --
%
% %% Pick the top three networks for erspimage
% EEG_src = moveSource2DataField(EEG_clean);
%
% [~, sortnet] = sort(max(mean(Bf,3),[],2));
%
% net = sortnet(1);
% indNet = find(ismember(hm.atlas.label,funcnetwork(net).ROI));
% for chi = 1:length(indNet)
%     try
%         figiter = figiter + 1;
%         targetChs = {ERG.src.chanlocs(chi).labels};
%         [ERSP, EEGtimes, freq] = ersp(EEG, targetChs,baseline);
%         fig(figiter) = erspImage(ERSP, condition, EEGtimes, freq, targetCh);
%         tempdata = get(fig(figiter),'UserData');
%         tempdata = [tempdata, funcnetwork.name];
%         if flag_save == 1, saveas(fig(figiter),['middle_fish',num2str(figiter),'',(tempdata)],'png'); end
%     end
% end
