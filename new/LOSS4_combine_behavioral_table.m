%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%combine with the behavioral data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load('//home/kumral/Desktop/Projects/LOSS_analyses/preprocess/wake_fmax40_log1_reject0_reduce1_interpolate0norm_sharptool1/data_all.mat');
data = rmfield(data,{'VP','Weckung'});
folder = '//home/kumral/Desktop/Projects/LOSS_analyses/github_scripts/scripts_clone/LOSS'; 
subj = fullfile(folder, '/dream.csv');
table_behavior = readtable(subj,'PreserveVariableNames',true);
table_behavior = table_behavior(:,1:6);
table_behavior = removevars(table_behavior, 'Var1');

data_table = struct2table(data);
%data_table(33,:) = [] %17_4 %delete if it is wake because in the wake condition this subj is more

combined_data = join(data_table,table_behavior, 'leftkeys','filename','rightkeys','filename');
save('data_all_behavior.mat', 'combined_data', '-v7.3')
%%