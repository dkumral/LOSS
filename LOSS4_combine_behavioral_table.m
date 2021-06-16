%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%combinewiththe behavioral data and also reduce/rehape the 3D to 2D of the PSD
%%files both original (PSD) as well as 1/f slope corrected
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('//home/kumral/Desktop/Projects/LOSS_analyses/github_scripts/data_PSD_averaged_slope.mat');
%load('C:\Users\neurointern\Data\git\Eddie\LOSS\data_PSD_averaged_slope.mat')
data = rmfield(data,{'VP','Weckung'});
folder = '//home/kumral/Desktop/Projects/LOSS_analyses/github_scripts/scripts_clone/LOSS'; 
%folder = 'C:\Users\neurointern\Data\git\Eddie\LOSS';
subj = fullfile(folder, '/dream.csv');
table_behavior = readtable(subj,'PreserveVariableNames',true);
table_behavior = table_behavior(:,1:7);
table_behavior = removevars(table_behavior, 'Var1');


data_table = struct2table(data);
combined_data = join(data_table,table_behavior, 'leftkeys','filename','rightkeys','filename');

for subj = 1:81
     for stg = 1:5
        PSD_org =   combined_data.PSD_avg_epoch{subj,stg} ; 
        combined_data.PSD_red_org{subj, stg} = reshape(PSD_org.',1,[])'; %original PSD
        PSD = combined_data.Pows(subj,1).res{1, stg}  ;
        combined_data.PSD_red{subj, stg} = reshape(PSD.',1,[])';%corrected PSD PSD
    end
end

save('combined_data.mat', 'combined_data', '-v7.3')

%%