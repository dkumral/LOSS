%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%compute averaged PSD: each cycle and each person for each sleep stage and save it to one file%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data] =merge_PSD(fileInfo)
addpath('//home/kumral/Desktop/Projects/LOSS_analyses/audiobook_PSDs/')
cd(fileInfo) %directory where the mat file is
fullfiles=dir([fileInfo,'/*.mat']); %add path
for i = 1:length(fullfiles)
    filename = fullfiles(i).name; %name of the file
    load(filename);
    data(i).filename = filename; %for naming
    data(i).VP = strtok(filename, "_"); %for naming
    flname = fliplr(filename); %flip naming
    data(i).Weckung = strtok(flname(8:9), "_");
    data(i).PSD_S_avg = PSD_S_avg;
    data(i).dim_PSD_total = dim_PSD_total'; %dimension total
    data(i).dim_PSD_wake = dim_PSD'; %dimension of PSDwake
    data(i).dim_PSD_sleep = dim_PSD_total- dim_PSD;  %dimension of PSD sleep
    data(i).F = F;

end
save('data_all.mat', 'data', '-v7.3')
end
%%