%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%this script is searchlight for the frequency domain: PSD%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [PSD_perm]  = searchlight_PSD_ROI(VP,sz,nperm,frangeAll,stage,PSD,ifreq,ROI,r)
rng(999)

%this is for the frequency range
F=0.5:0.5:30;
loc = find(F>=frangeAll(ifreq,1) & F<=frangeAll(ifreq,2)); %find the frequency range
for k = 1:length(loc)
    main_loc(k,:) = loc(k):length(F):length(PSD{1, stage(1)});
    main_loc2 = reshape(main_loc,[],1); %find the main location of that frequency range as index form
end
values = 1:length(PSD{1, stage(1)});
loc_nonfreq = ~ismember(values', main_loc2); %take other frequencies of interests
loc_freq = ismember(values', main_loc2); %take not other frequencies
clear main_loc
%this is for the channel ROI range

start = 1:length(F):length(PSD{1,stage(1)});
ending = length(F):length(F):length(PSD{1, stage(1)});
for s = 1:size(ROI{r},2) %number of channel
    Chrange(:,s) = [start(ROI{r}(s)):ending(ROI{r}(s))]; %channel range %chnnel for interests
end

main_loc_r = reshape(Chrange,[],1); %find the main location of that frequency range
loc_nonROI = ~ismember(values', main_loc_r); %take other frequencies of interests
loc_ROI = ismember(values', main_loc_r); %take not other frequencies

%overlap for freq and ROI
for m = 1:length(PSD{1, stage(1)})
    if(loc_freq(m) && loc_ROI(m) == 1)
        ovrl_freq_ROI(m,1)=1;
    else
        ovrl_freq_ROI(m,1)=0;
    end
end
ovrl_freq_ROI = logical(ovrl_freq_ROI);


%overlap for NONfreq and NONfreqROI
for m = 1:length(PSD{1, stage(1)})
    if(loc_nonfreq(m) && loc_nonROI(m) == 1)
        ovrl_NONfreq_ROI(m,1)=1;
    else
        ovrl_NONfreq_ROI(m,1)=0;
    end
end

ovrl_NONfreq_ROI = logical(ovrl_NONfreq_ROI);

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
                PSD_perm{s,ix,stg}(ovrl_NONfreq_ROI,1)= PSD_t{s,ix,stg}(ovrl_NONfreq_ROI,1); %keep non changed frequency range constant: make the zeros
                PSD_perm{s,ix,stg}(ovrl_freq_ROI,1) = PSD_permP{s,ix,stg}(ovrl_freq_ROI,1);
            end
        else
            VPx =  VP(cell2mat(arrayfun(@(dummy) randperm(sz), 1:nperm, 'UniformOutput', false)')'); %permute the data
            for i=1:sz
                PSD_t(:,ix,stg) = PSD(:,stg);
                %PSD_perm{i,ix,stg}= PSD_p{find(VP  == VPx(i,ix)),ix,stg}(main_loc2,1); %keep the frequency range
                PSD_perm{i,ix,stg}(ovrl_NONfreq_ROI,1)= PSD_t{find(VP  == VP(i)),ix,stg}(ovrl_NONfreq_ROI,1); %keep non changed frequency range constant
                PSD_perm{i,ix,stg}(ovrl_freq_ROI,1)=PSD_t{find(VP  == VPx(i,ix)),ix,stg}(ovrl_freq_ROI,1);  %replace zeros with the permuted data
            end
        end
    end
end

end
%%PSD_perm{i,ix,stg}(main_loc2,1)= PSD_p{find(VP  == VPx(i,ix)),ix,stg}(main_loc2,1); %remove the freq range

%%