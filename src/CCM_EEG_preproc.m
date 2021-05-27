%% PreProc Batch - EGI Version - Center Cognitive Medicin
%tricked out for XNAT, by patrick, 2021 
%% Set-up working parameters
% close all
% clear all
%warning off;
wpms.dirs  = struct('CWD','/opt/src/','packages','PACKAGES', ...
    'FUNCTIONS','FUNCTIONS/','RAW','INPUTS/RAW/','preproc','PREPROC_OUTPUT/', 'ERP','ERP/', ...
    'DATA_DIR','EEGLAB_FORMAT/','WAVELET_OUTPUT_DIR','WAVELET_OUTPUT_DIR/', ...
    'COHERENCE_DIR','IMAGCOH_OUTPUT /','EEGDispOutput','EEGDISPLAY_OUTPUT/', ...
    'TIMELOCK','TIMELOCK/','GA_TIMELOCK','GA_TIMELOCK/','edat_txt','INPUTS/edat_txt/','QA','QA/');


wpms.names = dir('/opt/src/INPUTS/RAW/*.raw')
t = struct2table(wpms.names)
t = t.name
disp(length(wpms.names))
wpms.names = {t}
for name_i = 1:length(wpms.names)
wpms.names(name_i)= erase(wpms.names(name_i),'.raw')
end

ft_defaults

%% load variable config csv 
%  load('/opt/src/pretrial.mat')
filename='/opt/src/INPUTS/config.csv'
fileID = fopen(filename,'r');
C = textscan(fileID,'%q %f %q %f %q %q %q %f %q %f','Delimiter',',');
%% set variables from config
pre_trial=C{1,2},(1:1)
post_trial=C{1,4},(1:1)
%trialfunction=C{1,6}{1,1},(1:1)
condition=C{1,6}{1,1},(1:1)
reject_min=C{1,8},(1:1)
reject_max=C{1,10},(1:1)
%% Preprocessing I
%Import, downsample and re-reference
for name_i = 1:length(wpms.names)
    sampling_frequency = 250; %hz
    [dat] = ccmegi_importeeg_and_downsample(wpms,'raw',name_i,sampling_frequency); % should not need to downsample, may write different function for this.
    [refdat] = fnl_rereference(dat,'all');
    
    clear dat
    
    [data] = ccm_preproc_filter(refdat,'no',[58 62],'yes',30,4,'but','yes',0.1,'onepass',1,'but'); 
% no high-pass needed EGI data sampled at 0.1-100 Hz
% Lowpassing at 30 for ERP, 30-50 for TF
% 
    save([wpms.dirs.CWD wpms.dirs.preproc wpms.names{name_i} '_REFnFILT'],'data','-v7.3');
%     clear refdat data cfg %tidying
end

%% Automatic Bad Channel Rejection

for name_i = 1:length(wpms.names)
    patrick_docker_ccm256_auto_chan_reject(wpms,name_i);
end

%% Visual Inspection of Data:
% for name_i = 7% length(wpms.names)   
%     ccm256_bad_channel_inspection(wpms,name_i,100);
% end

%% Remove Good Channels from Data to visualize rejected channels:
for name_i = 1:length(wpms.names)   
    patrick_docker_remove_good_channels(wpms,name_i);
end

%% Remove Bad Channels out from Data:
for name_i = 1:length(wpms.names)   
    fnl_remove_bad_channels(wpms,name_i);
end

%% Automatic ICA

for name_i = 1:length(wpms.names)
    patrick_docker_ccm256_auto_ica(wpms,name_i);
end
%%
%Select trial definition based on config parameters
if  1 == strcmp(condition,'_Gonogo')
for name_i = 1:length(wpms.names)   
    %    pre_trial = .2; %for target 1 sec on each side, for cue 
%    post_trial = 1; %changed to 2 for inspection
   trialfunction = 'TF_Gonogo'; %will need to change per task, each task has trial function, will need to edit function for ANT task
    file_ext = 'raw';
    trdat = patrick_docker_gonogo(wpms,name_i,trialfunction,pre_trial,post_trial,file_ext);
%     clear post_trial pre_trial trialfunction
%     clear sample*
%     clear value*        
end
elseif  1 == strcmp(condition,'_Stroop')
for name_i = 1:length(wpms.names)   
    %    pre_trial = .2; %for target 1 sec on each side, for cue 
%    post_trial = 1; %changed to 2 for inspection
   trialfunction = 'TF_Stroop'; %will need to change per task, each task has trial function, will need to edit function for ANT task
    file_ext = 'raw';
    trdat = patrick_docker_stroop(wpms,name_i,trialfunction,pre_trial,post_trial,file_ext);
%     clear post_trial pre_trial trialfunction
%     clear sample*
%     clear value*      
end
elseif  1 == strcmp(condition,'_Incidental')
for name_i = 1:length(wpms.names)   
    %    pre_trial = .2; %for target 1 sec on each side, for cue 
%    post_trial = 1; %changed to 2 for inspection
   trialfunction = 'TF_Incidental'; %will need to change per task, each task has trial function, will need to edit function for ANT task
    file_ext = 'raw';
    trdat = patrick_docker_incidental(wpms,name_i,trialfunction,pre_trial,post_trial,file_ext);
%     clear post_trial pre_trial trialfunction
%     clear sample*
%     clear value*      
end
elseif  1 == strcmp(condition,'_Alerting')
for name_i = 1:length(wpms.names)   
%     pre_trial = .5; %for target 1 sec on each side, for cue 
%     post_trial = .5;
    trialfunction = 'TF_Alerting_collapse'; %will need to change per task, each task has trial function, will need to edit function for ANT task
    file_ext = 'raw';
    trdat = patrick_Alerting_collapse(wpms,name_i,trialfunction,pre_trial,post_trial,file_ext);
%     clear post_trial pre_trial trialfunction
%     clear sample*
%     clear value*       
end
elseif  1 == strcmp(condition,'_Orienting')
 for name_i = 1:length(wpms.names)   
%     pre_trial = .5; %for target 1 sec on each side, for cue 
%     post_trial = .5;
     trialfunction = 'TF_Orienting_collapse'; %will need to change per task, each task has trial function, will need to edit function for ANT task
     file_ext = 'raw';
     trdat = patrick_Orienting_collapse(wpms,name_i,trialfunction,pre_trial,post_trial,file_ext);
%     clear post_trial pre_trial trialfunction
%     clear sample*
%     clear value*
 end
elseif  1 == strcmp(condition,'_Executive')
for name_i = 1:length(wpms.names)   
%     pre_trial = .5; %for target 1 sec on each side, for target
%     post_trial = .5;
     trialfunction = 'TF_Executive_collapse'; %will need to change per task, each task has trial function, will need to edit function for ANT task
     file_ext = 'raw';
     trdat = patrick_Executive_collapse(wpms,name_i,trialfunction,pre_trial,post_trial,file_ext);
%     clear post_trial pre_trial trialfunction
%     clear sample*
%     clear value*      
end
end
%% Apply artifact rejection %toggle which condition to use
%patrick b changed "true" to "1", will stop if finds sub with <1 good trial
for name_i = 1:length(wpms.names)
%    condition = '_gonogo'    
%    condition = '_Alerting'
%    condition = '_Orienting'
%    condition = '_Executive'
%    condition = '_incidental'
%     reject_min = -150
%     reject_max = 150
    patrick_docker_ccm_artifact_rejection_auto(wpms,name_i,1,30,reject_min,reject_max,condition)
end
%% Reinterpolate bad channels %toggle which condition to use
for name_i = 1:length(wpms.names) 
%     condition = '_gonogo'
%      condition = '_Alerting'
%     condition = '_Orienting'
%    condition = '_Executive'
%     condition = '_incidental'
    patrick_docker_ccm256_reinterpolate(wpms,name_i,condition);
end