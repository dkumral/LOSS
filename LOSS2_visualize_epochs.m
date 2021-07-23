%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%histograms of epochs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%rejected epochs%%
t = tiledlayout(1, 5);
x_width=28 ;y_width=7;
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
set(gcf, 'PaperUnits', 'inches');

for stg = 1:5
    nexttile()
    for  i = 1:81
        epochs_reject(i,stg) = data(i).total_rejected_epochs(stg)
        histogram(epochs_reject(:,stg),10)
        xlabel('rejected epochs');
    end
end
saveas(t,'rejected_epochs.jpeg')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%used epochs after rejected%%
t = tiledlayout(1, 5);
x_width=28 ;y_width=7;
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
set(gcf, 'PaperUnits', 'inches');set(gcf, 'PaperUnits', 'inches');
for stg = 1:5
    nexttile()
    for  i = 1:81
        epochs_used(i,stg) = (data(i).total_sleepstage(stg)- data(i).total_rejected_epochs(stg));
        histogram(epochs_reject(:,stg),10);
        xlabel('used epochs after rejected');
    end
end
saveas(t,'used_epochs_after_rejected.jpeg')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%used epochs without rejected%%
t = tiledlayout(1, 5);
x_width=28 ;y_width=7;
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
set(gcf, 'PaperUnits', 'inches');

for stg = 1:5
    nexttile()
    for  i = 1:81
        epochs_used_withoutrejected(i,stg) = data(i).total_sleepstage(stg);
        histogram(epochs_used_withoutrejected(:,stg),10);
        xlabel('used epochs without rejected');
    end
    
end
saveas(t,'used_epochs_without_rejected.jpeg')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%averaging and outlier%%

for i = 1:81
    VPN = split(data(i).VP, 'VP')
    data(i).VPN = str2num(cell2mat(VPN(2)));
end

data_STR = struct2table(data);
for i = 1:20
    data_com = data_STR((data_STR.VPN)==(i+1),:);
    total_sleep_withoutrej(:,i) = nansum([data_com.total_sleepstage{:}],2)
    total_sleep_used_after_rejected(:,i)  = total_sleep_withoutrej(:,i) - nansum([data_com.total_rejected_epochs{:}],2)
end

total_sleep_withoutrej = total_sleep_withoutrej'
total_sleep_used_after_rejected = total_sleep_used_after_rejected'

t = tiledlayout(1, 5);
x_width=28 ;y_width=7;
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
set(gcf, 'PaperUnits', 'inches');

for stg = 1:5
    nexttile()
    histogram(total_sleep_used_after_rejected(:,stg),10);
    xlabel('used epochs after rejected averaged cycle');
end
saveas(t,'used_epochs_after_rejected_averagedcycle.jpeg')



for stg = 1:5
    nexttile()
    histogram(total_sleep_withoutrej(:,stg),10);
    xlabel('used epochs without rejected averaged cycle');
end
saveas(t,'used_epochs_without_rejected_averagedcycle.jpeg')

total_sleep_withoutrej(total_sleep_withoutrej<40) = NaN;
totalNA=sum(isnan(total_sleep_withoutrej))

total_sleep_used_after_rejected(total_sleep_used_after_rejected<40) = NaN;
totalNA=sum(isnan(total_sleep_used_after_rejected))


TF = isoutlier(total_sleep_withoutrej(:), 'quartiles')
total_sleep_withoutrej_out = reshape(TF,20,5)
total_sleep_withoutrej(total_sleep_withoutrej_out==1) = NaN;

TF = isoutlier(total_sleep_used_after_rejected(:), 'quartiles')
total_sleep_used_after_rejected_out = reshape(TF,20,5)
total_sleep_used_after_rejected(total_sleep_used_after_rejected_out==1) = NaN;


t = tiledlayout(1, 5);
x_width=28 ;y_width=7;
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
set(gcf, 'PaperUnits', 'inches');

for stg = 1:5
    nexttile()
    histogram(total_sleep_used_after_rejected(:,stg),10);
    xlabel('used epochs after rejected averaged cycle');
end
saveas(t,'used_epochs_after_rejected_averagedcycle_afteroutlier.jpeg')

for stg = 1:5
    nexttile()
    histogram(total_sleep_withoutrej(:,stg),10);
    xlabel('used epochs without rejected averaged cycle');
end
saveas(t,'used_epochs_without_rejected_averagedcycle_afteroutlier.jpeg')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%averaging and outlier based on Nature paper: 40 epochs for each cycle%%
%%%compute  if there is events <40, put NA, %%
for i = 1:81
    for stg = 1:5
        if data(i).total_sleepstage(stg)<=40
            data(i).outliers_epochs_withoutrejected(stg) = NaN;
        else
            data(i).outliers_epochs_withoutrejected(stg) = data(i).total_sleepstage(stg);
        end
    end
end

data_STR = struct2table(data); %change to structure
sum(isnan(data_STR.outliers_epochs_withoutrejected)) %sum of NaNs in total

%%%compute  the average across same individual %%

for i = 1:20
    data_com = data_STR((data_STR.VPN)==(i+1),:);
    total_sleep_withoutrej_outliers(:,i) = nansum(data_com.outliers_epochs_withoutrejected,1)
end

total_sleep_withoutrej_outliers = total_sleep_withoutrej_outliers'
total_sleep_withoutrej_outliers(total_sleep_withoutrej_outliers==0) = NaN;
%%coutlier computation based on quartiles %%
TF = isoutlier(total_sleep_withoutrej_outliers(:), 'quartiles')
total_sleep_used_after_rejected_out_outlier = reshape(TF,20,5)
total_sleep_withoutrej_outliers(total_sleep_used_after_rejected_out_outlier==1) = NaN;
sum(isnan(total_sleep_withoutrej_outliers)) %sum of NaN

t = tiledlayout(1, 5);
x_width=28 ;y_width=7;
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
set(gcf, 'PaperUnits', 'inches');

for stg = 1:5
    nexttile()
    histogram(total_sleep_withoutrej_outliers(:,stg),10);
    xlabel('used epochs without rejected averaged cycle');
end
saveas(t,'used_epochs_without_rejected_averagedcycle_outliers40_quartiles.jpeg')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

