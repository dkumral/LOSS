%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%detect 
addpath('/home/kumral/neurostorage/LOSS/EEG_raw/')
load('LOSS_VP21_1-rejected-wake.set', '-mat')

wakesize = size(EEG.stats.psd,3)
use_W = size(EEG.stats.usetrials,1);
totalwakemin = (wakesize*4)
load('LOSS_VP21_1-rejected-sleep.set', '-mat')
sleepsize = size(EEG.stats.psd,3)
use_S = size(EEG.stats.usetrials,1);
S1time = sum(EEG.stats.sleep_trial  ==1)*4;     %count how many times it is stg

S2time = sum(EEG.stats.sleep_trial  ==2)*4;     %count how many times it is stg

sum(EEG.stats.sleep_epoch(:,1) == 2 )*7.5*4

S3time = sum(EEG.stats.sleep_trial  ==3)*4;     %count how many times it is stg

sum(EEG.stats.sleep_epoch(:,1) == 3)*7.5*4
S4time = sum(EEG.stats.sleep_trial  ==4)*4;     %count how many times it is stg

filenameM = sprintf('LOSS_VP%d_%d_PSD.mat', 21,1);
load(filenameM)
PSDsize = size(PSD,3)
totalsize = sleepsize + wakesize
totalsizeuse = use_W+use_S
load('LOSS17_night_ctrl_01.mat')
%[8,2] %1164:1170# 
load('VP21_1_sleep.mat')
load('LOSS_VP21_1-reject-filtered.set', '-mat')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%detect 
%%combined with the sleep info data to see the "8" motion artefacts, time
%%of book etc....
load('/home/kumral/Desktop/Projects/LOSS/Results/LOSS_book_eeg_match.mat')

for cyc = 1:5
    for vp = 1:21
        if vp<10
            filenameM = sprintf('VP%d_%d_sleep.mat', vp,cyc );
            filenameB = sprintf('LOSS0%d_night_ctrl_0%d.mat', vp,cyc );
        else
            filenameM = sprintf('VP%d_%d_sleep.mat', vp,cyc );
            filenameB = sprintf('LOSS%d_night_ctrl_0%d.mat', vp,cyc );
        end
        if exist(filenameM, 'file') == 2
            load(filenameM)
            sleep_info{vp,cyc} = sleep;
            VP(vp,cyc) = vp;
            Weckung(vp,cyc) = cyc;     
        else
            sleep_info{vp,cyc} = NaN;
        end
            if exist(filenameB, 'file') == 2
                load(filenameB, 'RES');
                startbook(vp,cyc) = RES.startbook;
                endbook(vp,cyc) = RES.endbook;

            else
                startbook(vp,cyc) =NaN;
            end
        end
end

addedtime = startbook + book_eeg_match + endbook
numberofepochs = addedtime/4;
sleep_audiobook_info = [VP(:), Weckung(:), startbook(:), endbook(:),  book_eeg_match(:), addedtime(:), numberofepochs(:)]
sleep_audiobook_info = sortrows(sleep_audiobook_info,'ascend');
sleep_audiobook_info(1:23,:) = [];
sleep_audiobook_info(64,:) = [];

load('data_information_epochs.mat')
data_information_epochs2 = struct2table(data_information_epochs)
sleep_audiobook_info2 =array2table(sleep_audiobook_info)
sleep_audiobook_info2.Properties.VariableNames{1} = 'VP'
sleep_audiobook_info2.Properties.VariableNames{2} = 'Weckung'
sleep_audiobook_info2.Properties.VariableNames{3} = 'startbook'
sleep_audiobook_info2.Properties.VariableNames{4} = 'endbook'
sleep_audiobook_info2.Properties.VariableNames{5} = 'book_eeg_match'
sleep_audiobook_info2.Properties.VariableNames{6} = 'addedtime'
sleep_audiobook_info2.Properties.VariableNames{7} = 'numberofepochs'

sleep_info_audiobook = innerjoin(sleep_audiobook_info2,data_information_epochs2, 'leftkeys',[1,2],'rightkeys',[7,8]);
for i = 1:81
    if sleep_info_audiobook.total(i) < sleep_info_audiobook.numberofepochs(i)
        display('audiobook>acquisitiontime')
        sleep_info_audiobook.matching{i} = 'audiobook>acquisitiontime';
        sleep_info_audiobook.matchingnumeric(i) =0;
    else
        display('acquisitiontime>audiobook')
        sleep_info_audiobook.matching{i} = 'acquisitiontime>audiobook';
        sleep_info_audiobook.matchingnumeric(i) =1;
    end
end

sleep_info_audiobook.matchingdifference = sleep_info_audiobook.total - sleep_info_audiobook.numberofepochs;

for i=1:81
    if sleep_info_audiobook.matchingnumeric(i) == 1
        sleepstageinfo = [sleep_info_audiobook.Stages_use_W{i,1}(:,1); sleep_info_audiobook.Stages_use_S{i,1}(:,1)];
        sleepstageinfoepoch = [sleep_info_audiobook.Stages_use_W{i,1}(:,end); sleep_info_audiobook.Stages_use_S{i,1}(:,end)];
        S = [sleepstageinfoepoch, sleepstageinfo];
        S  = sortrows(S,1,'ascend');
        if isnan(ceil(sleep_info_audiobook.numberofepochs((i))));
            display('NAN')
        else
        S(1:ceil(sleep_info_audiobook.numberofepochs((i))), 3) = 999;
        S((ceil(sleep_info_audiobook.numberofepochs((i)))+1):end, 3) = S((ceil(sleep_info_audiobook.numberofepochs((i)))+1):end,2);
        sleep_info_audiobook.sleep_audiobook_epoch{i} = S;
        end
    else
        display('acquisition and audiobook time difference')
    end
end
save ('sleep_info_audiobook.mat','sleep_info_audiobook', '-v7.3');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%detect
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%detect 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%detect 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%detect 

% total = size(sleep_info_audiobook.Stages_use_S,1) + size(sleep_info_audiobook.Stages_use_W,1)
% data_information_epochs = table2struct(sleep_info_audiobook)
% for i = 1:81
%     data_information_epochs(i).total = size(data_information_epochs(i).Stages_use_S,1) + size(data_information_epochs(i).Stages_use_W,1)
%     if (data_information_epochs(i).total ==	size(data_information_epochs(i).original,3))
%         data_information_epochs(i).epochs_match = 1;
%         data_information_epochs(i).epochs_difference = size(data_information_epochs(i).original,3) - data_information_epochs(i).total
%     else
%         data_information_epochs(i).epochs_match = 0;
%         data_information_epochs(i).epochs_difference = size(data_information_epochs(i).original,3) - data_information_epochs(i).total
%         
%     end
%     
% end

