%--
network = repmat(struct('name','','ROI',[],'mask',[]),8,1);

network(1).name = 'CON';
network(1).ROI = {...
    'G_and_S_cingul-Mid-Ant R', 'G_and_S_cingul-Mid-Ant L',...
    'S_circular_insula_ant R', 'S_circular_insula_ant L',...
    'G_insular_short R' , 'G_insular_short L',...
    'G_front_middle R', 'G_front_middle L',...
    'S_front_middle R', 'S_front_middle R'};

network(2).name = 'FPN';
network(2).ROI = {...
    'S_front_inf R', 'S_front_inf L',...
    'G_front_middle R', 'G_front_middle L',...
    'S_front_inf R', 'S_front_inf L',...
    'S_intrapariet_and_P_trans R', 'S_intrapariet_and_P_trans L',...
    'S_precentral-inf-part R', 'S_precentral-inf-part L',...
    'S_parieto_occipital R', 'S_parieto_occipital L',...
    'G_parietal_sup R', 'G_parietal_sup L',...
    'G_pariet_inf-Supramar R', 'G_pariet_inf-Supramar L',...
    'G_pariet_inf-Angular R', 'G_pariet_inf-Angular L',...
    'G_occipital_sup R', 'G_occipital_sup L',...
    'G_precuneus R' , 'G_precuneus L',...
    'G_and_S_cingul-Mid-Post R', 'G_and_S_cingul-Mid-Post L'};

network(3).name = 'DMN';
network(3).ROI = {...
    'G_front_sup R' , 'G_front_sup L',...
    'G_rectus R', 'G_rectus L',...
    'G_precuneus R' , 'G_precuneus L',...
    'G_cingul-Post-dorsal R' , 'G_cingul-Post-dorsal L',...
    'G_cingul-Post-ventral R' , 'G_cingul-Post-ventral L',...
    'G_oc-temp_med-Parahip R', 'G_oc-temp_med-Parahip L',...
    'G_temporal_middle R', 'G_temporal_middle L',...
    'Pole_temporal R', 'Pole_temporal L',...
    'S_calcarine R', 'S_calcarine L',...
    'S_interm_prim-Jensen R', 'S_interm_prim-Jensen L',...
    'G_pariet_inf-Supramar R', 'G_pariet_inf-Supramar L',...
    'S_parieto_occipital R', 'S_parieto_occipital L',...
    'S_temporal_sup R', 'S_temporal_sup L'};

network(4).name = 'DAN';
network(4).ROI = {...
    'S_precentral-sup-part R', 'S_precentral-sup-part L',...
    'S_intrapariet_and_P_trans R', 'S_intrapariet_and_P_trans L',...
    'G_parietal_sup R', 'G_parietal_sup L',...
    'S_postcentral R', 'S_postcentral L',...
    'G_postcentral R', 'G_postcentral L'};

network(5).name = 'VAN';
network(5).ROI = {...
    'G_front_inf-Triangul R','G_front_inf-Triangul L',...
    'S_temporal_sup R', 'S_temporal_sup L'};

network(6).name = 'VN';
network(6).ROI = {...
    'G_oc-temp_lat-fusifor R', 'G_oc-temp_lat-fusifor L',...
    'G_oc-temp_med-Lingual R', 'G_oc-temp_med-Lingual L',...
    'Pole_occipital R', 'Pole_occipital L',...
    'S_collat_transv_post R', 'S_collat_transv_post L',...
    'S_oc_sup_and_transversal R', 'S_oc_sup_and_transversal L',...
    'G_occipital_middle R', 'G_occipital_middle L',...
    'G_and_S_occipital_inf R', 'G_and_S_occipital_inf L',...
    'G_occipital_sup R', 'G_occipital_sup L',...
    'S_oc_middle_and_Lunatus R', 'S_oc_middle_and_Lunatus L'};


network(7).name = 'AN';
network(7).ROI = {'G_temp_sup-Lateral R', 'G_temp_sup-Lateral L'};

network(8).name = 'SMN';
network(8).ROI = {...
'S_central R', 'S_central L',...
'G_postcentral R', 'G_postcentral L',...
'G_precentral R', 'G_precentral L',...
'S_precentral-sup-part R', 'S_precentral-sup-part L',...
'S_precentral-inf-part R', 'S_precentral-inf-part L',...
'G_and_S_paracentral R', 'G_and_S_paracentral L'};

hm = headModel.loadDefault;

n = length(network);
M = [];
for k=1:n
    network(k).mask = any(hm.indices4Structure(network(k).ROI),2);
    M = [M network(k).mask];
end
hm.plotOnModel(M)
%---