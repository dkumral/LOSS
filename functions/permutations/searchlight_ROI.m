%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%this script is searchlight for the fOI%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [PSD_perm]  = searchlight_ROI(VP,sz,nperm,stage,PSD,ROI,r)
rng(10)

F=0.5:0.5:30;
start = 1:length(F):length(PSD{1,stage(1)});
ending = length(F):length(F):length(PSD{1, stage(1)});
values = 1:length(PSD{1, stage(1)});

for s = 1:size(ROI{r},2) %number of channel
    Chrange(:,s) = [start(ROI{r}(s)):ending(ROI{r}(s))]; %channel range %chnnel for interests
end
main_loc2 = reshape(Chrange,[],1); %find the main location of that frequency range
loc_nonROI = ~ismember(values', main_loc2); %take other roi of interests
loc_ROI = ismember(values', main_loc2); %take not other roi

for stg = stage
    for ix = 1:nperm
        if sz>19
            VP2 = unique(VP); %take the unique subjects
            VPx =  VP2(cell2mat(arrayfun(@(dummy) randperm(length(VP2)), 1:nperm, 'UniformOutput', false)')'); %permute the data (unique subjects)
            PSD3 = [];
            for i=1:length(VP2)
                PSD_x = PSD(find(VP  == VPx(i,ix)),stg); %arrange the PSDs based ont he permuted data : permuted data
                PSD3 = vertcat(PSD3, PSD_x); % combine all CH1 for all awakenings
            end
            PSD_permP(:,ix,stg) = PSD3; %fully permuted data
            PSD3 = [];
            
            PSD_t(:,ix,stg) = PSD(:,stg); %no permutation but ix dimension
            for s = 1:sz
                PSD_perm{s,ix,stg}(loc_nonROI,1)= PSD_t{s,ix,stg}(loc_nonROI,1); %keep non changed frequency range constant: make the zeros
                PSD_perm{s,ix,stg}(loc_ROI,1) = PSD_permP{s,ix,stg}(loc_ROI,1);
            end
        else
            VPx =  VP(cell2mat(arrayfun(@(dummy) randperm(sz), 1:nperm, 'UniformOutput', false)')'); %permute the data
            for i=1:sz
                PSD_t(:,ix,stg) = PSD(:,stg);
                %PSD_perm{i,ix,stg}= PSD_p{find(VP  == VPx(i,ix)),ix,stg}(main_loc2,1); %keep the frequency range
                PSD_perm{i,ix,stg}(loc_nonROI,1)= PSD_t{find(VP  == VP(i)),ix,stg}(loc_nonROI,1); %keep non changed frequency range constant
                PSD_perm{i,ix,stg}(loc_ROI,1)=PSD_t{find(VP  == VPx(i,ix)),ix,stg}(loc_ROI,1);  %replace zeros with the permuted data
            end
        end
    end
end
clear Chrange main_locs2 loc_nonROI
end

%%PSD_perm{i,ix,stg}(main_loc2,1)= PSD_p{find(VP  == VPx(i,ix)),ix,stg}(main_loc2,1); %remove the freq range

%%