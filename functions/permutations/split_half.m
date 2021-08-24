%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%the split half %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [observeddifference_mean,VP_new1, VP_new2,PSD1,PSD2,aud1,aud2]  = split_half(PSD, VP, audiobook,nhalf,stage)
close all
rng(123, 'twister')
audio = [1:4];
%%create empty files
PSD1 =[];
PSD2 =[];
VP_new1 =[];
VP_new2 =[];
sz2 = floor(size(VP,1)/2); %half size of the number of individuals
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%run the split half and arrange the documents, correlation will come in the second section%%%
    for a = audio
        for ixm = 1:nhalf %permutation %how many splits
            if mod(sum(audiobook==a),2) == 0 %based on audiobook
                VPA = [];
                VPA = VP(audiobook==a); %which individuals has this audiobook
                data1(:,ixm,:)= VPA(randperm(length(VPA),length(VPA)/2)); %run the random splitting  and find the indivduals: based on the number of individuals (hallf)
                data2(:,ixm,:) = VPA(find(~ismember(VPA,data1(:,ixm,:)))); % find the rest 
                
                data1_PSD(:,ixm,:) = PSD(find(ismember(VP, data1(:,ixm,:))),:); %find the PSD of data1
                data2_PSD(:,ixm,:) = PSD(find(ismember(VP, data2(:,ixm,:))),:); %find the PSD of data2
                for stg = stage
                    data1mean(:,ixm,stg)  = nanmean([(data1_PSD{:,ixm,stg})],2); %take the PSD mean in data1 of that book
                    data2mean(:,ixm,stg) = nanmean([(data2_PSD{:,ixm,stg})],2); %take the PSD mean in data2 of that book
                end
            else %else means that if the number of audiobook is not a even number (e.g., 5)
                VPA = [];
                VPA = VP(audiobook==a);
                data1(:,ixm,:)= VPA(randperm(length(VPA),floor(length(VPA)/2))); %run the random splitting and find the indivduals
                data2x(:,ixm,:) = VPA(find(~ismember(VPA,data1(:,ixm,:)))); %take the rest
                ind = randperm(length(data2x(:,ixm,:)),2)';
                data2(:,ixm,:) = data2x(ind,ixm,:); %select random individuals to make it equal with the data1
                
                data1_PSD(:,ixm,:) = PSD(find(ismember(VP, data1(:,ixm,:))),:); %find the PSD of data1
                data2_PSD(:,ixm,:) = PSD(find(ismember(VP, data2(:,ixm,:))),:); %find the PSD of data2
                for stg = stage
                    data1mean(:,ixm,stg)  = nanmean([(data1_PSD{:,ixm,stg})],2); %take the PSD mean in data1 of that book
                    data2mean(:,ixm,stg) = nanmean([(data2_PSD{:,ixm,stg})],2); %take the PSD mean in data2 of that book
                end
            end
        end
        data1mean_all_audio(:,:,:,a) =   data1mean; %4 dimension: number of PSD/ind x nhalf(splits) x stage x audiobook
        data2mean_all_audio(:,:,:,a) =   data2mean;
        PSD1 = [PSD1;squeeze(data1_PSD(:,:,:))];    
        PSD2 = [PSD2;squeeze(data2_PSD(:,:,:))];   
        VP_new1 = [VP_new1;squeeze(data1(:,:,:))] ; %9 (subject half) X nhalf
        VP_new2 = [VP_new2;squeeze(data2(:,:,:))] ; %9 (subject half) X nhalf
        clear data1_PSD data2_PSD data1mean data2mean data1 data2 data2x
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%find the corresponding audiobook%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ixm = 1:nhalf
    for dim = 1:sz2
        aud1(dim,ixm) = audiobook(VP==VP_new1(dim,ixm)); %it should be ordered
        aud2(dim,ixm) = audiobook(VP==VP_new2(dim,ixm)); %it should be ordered
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%run the correlation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ixm=1:nhalf
    for stg = stage
        for a = audio
            within_sim1 = atanh(corr(data1mean_all_audio(:,ixm,stg,audio(a)), data2mean_all_audio(:,ixm,stg,audio(a)), 'Type', 'Spearman', 'Rows', 'pairwise')); %make the correlation data1 audiobook A1 and data2 audibook A1
            mean_within_corr(a) = within_sim1;   %correlation value for each audiobook between data1 and data2
            mean_within(ixm,stg) = nanmean(mean_within_corr(:)); %we have 4 within correlation values, and taking average of it and also z-transform
            btw_a = audio(audio~=a);
            for i = 1:length(btw_a)
                between_sim1(i,a) = atanh(corr(data1mean_all_audio(:,ixm,stg,audio(a)), data2mean_all_audio(:,ixm,stg,btw_a(i)), 'Type','Spearman', 'Rows', 'pairwise')); %make the correlation data1 audiobook A1 and data2 audiobook A2, A3, A4 seperately
                between_sim2(i,a) = atanh(corr(data2mean_all_audio(:,ixm,stg,audio(a)), data1mean_all_audio(:,ixm,stg,btw_a(i)), 'Type','Spearman','Rows', 'pairwise')); %make the correlation data1 audiobook A1 and data2 A2, A3, A4 seperately
                between_sim3(i,a) = atanh(corr(data1mean_all_audio(:,ixm,stg,audio(a)), data1mean_all_audio(:,ixm,stg,btw_a(i)), 'Type','Spearman', 'Rows', 'pairwise')); %make the correlation data1 audiobook A1 and data2 audiobook A2, A3, A4 seperately
                between_sim4(i,a) = atanh(corr(data1mean_all_audio(:,ixm,stg,audio(a)), data2mean_all_audio(:,ixm,stg,btw_a(i)), 'Type','Spearman', 'Rows', 'pairwise')); %make the correlation data1 audiobook A1 and data2 audiobook A2, A3, A4 seperately
            end
        end
        between_sim1_m = nanmean((between_sim1(:))); %take the mean across 12 values (3 x 4)
        between_sim2_m = nanmean((between_sim2(:))); %take the mean across 12 values (3 x 4)
        between_sim3_m = nanmean((between_sim1(:))); %take the mean across 12 values (3 x 4)
        between_sim4_m = nanmean((between_sim1(:))); %take the mean across 12 values (3 x 4)
        mean_between(ixm,stg)= ((between_sim1_m+between_sim2_m + between_sim3_m +between_sim4_m)/4); %%% take the mean of halves
        observeddifference_ztrans(ixm,stg) = (mean_within(ixm,stg))-(mean_between(ixm,stg));
    end
end

observeddifference_mean= nanmean(observeddifference_ztrans,1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
violinplot(observeddifference_ztrans);
ylabel('Within-between similarity difference across sleep stages');
saveas(gcf,'split_half_between_within_difference.jpeg')
end
