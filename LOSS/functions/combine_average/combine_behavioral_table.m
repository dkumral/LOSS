%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%combine with the behavioral data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [combined_data]  = combine_behavioral_table(data)
data = rmfield(data,{'VP','Weckung'});
folder = '//home/kumral/Desktop/Projects/LOSS_analyses/github_scripts/scripts_clone/LOSS';
subj = fullfile(folder, '/dream.csv');
table_behavior = readtable(subj,'PreserveVariableNames',true);
table_behavior = table_behavior(:,1:6);
table_behavior = removevars(table_behavior, 'Var1');

data_table = struct2table(data);
combined_data = join(data_table,table_behavior, 'leftkeys','filename','rightkeys','filename');
save('data_all_behavior.mat', 'combined_data', '-v7.3')
end
%%