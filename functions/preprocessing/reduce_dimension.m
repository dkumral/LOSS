%%%%%%%%%%%%%%function is for reducing the EEG channel dimension 128 to 32%%%%%%%%%%%%%

function [PSD_W_S_red]  = reduce_dimension(PSD_S)
            
            dataClean2class = PSD_S;
            DATA_X = NaN(32,size(dataClean2class,2), size(dataClean2class,3));
            
            Gr = 1:32; Ye = 33:64;  Re = 65:96; Wh = 97:128;
            
            DATA_X(1,:,:) = nanmean(dataClean2class([Gr([1]) Wh([1]) Ye([1 2]) Re([1])],:,:),1);
            DATA_X(2,:,:) = nanmean(dataClean2class([Gr([2]) Wh([2]) Ye([3 4]) Re([1])],:,:),1);
            DATA_X(3,:,:) = nanmean(dataClean2class([Gr([3]) Wh([3 4]) Ye([5]) Re([2])],:,:),1);
            DATA_X(4,:,:) = nanmean(dataClean2class([Gr([4]) Wh([5 6]) Ye([5 6]) Re([3])],:,:),1);
            DATA_X(5,:,:) = nanmean(dataClean2class([Gr([5]) Wh([7 8]) Ye([6 7]) Re([4 5])],:,:),1);
            DATA_X(6,:,:) = nanmean(dataClean2class([Gr([6]) Wh([9 10]) Ye([7 8]) Re([6])],:,:),1);
            DATA_X(7,:,:) = nanmean(dataClean2class([Gr([7]) Wh([11 12]) Ye([8]) Re([7])],:,:),1);
            DATA_X(8,:,:) = nanmean(dataClean2class([Gr([8]) Wh([4 5]) Ye([10 11]) Re([9 10])],:,:),1);
            DATA_X(9,:,:) = nanmean(dataClean2class([Gr([9]) Wh([6 7]) Ye([11]) Re([11 12])],:,:),1);
            DATA_X(10,:,:) = nanmean(dataClean2class([Gr([10]) Wh([8 9]) Ye([12]) Re([13 14])],:,:),1);
            DATA_X(11,:,:) = nanmean(dataClean2class([Gr([11]) Wh([10 11]) Ye([12 13]) Re([15 16])],:,:),1);
            
            DATA_X(12,:,:) = nanmean(dataClean2class([Gr([12]) Wh([13]) Ye([15]) Re([8 9])],:,:),1);
            DATA_X(13,:,:) = nanmean(dataClean2class([Gr([13]) Wh([14 15]) Ye([15 16]) Re([10 11])],:,:),1);
            DATA_X(14,:,:) = nanmean(dataClean2class([Gr([14]) Wh([16 17]) Ye([16 17]) Re([12 13])],:,:),1);
            DATA_X(15,:,:) = nanmean(dataClean2class([Gr([15]) Wh([18 19]) Ye([17 18]) Re([14 15])],:,:),1);
            DATA_X(16,:,:) = nanmean(dataClean2class([Gr([16]) Wh([20]) Ye([18]) Re([16 17])],:,:),1);
            DATA_X(17,:,:) = nanmean(dataClean2class([Gr([17]) Ye([19]) Re([18])],:,:),1);
            DATA_X(18,:,:) = nanmean(dataClean2class([Gr([18]) Wh([13 14]) Ye([19 20]) Re([19 20])],:,:),1);
            DATA_X(19,:,:) = nanmean(dataClean2class([Gr([19]) Wh([15 16]) Ye([20 21]) Re([21 22])],:,:),1);
            DATA_X(20,:,:) = nanmean(dataClean2class([Gr([20]) Wh([17 18]) Ye([21 22]) Re([23 24])],:,:),1);
            DATA_X(21,:,:) = nanmean(dataClean2class([Gr([21]) Wh([19 20]) Ye([22 23]) Re([25 26])],:,:),1);
            DATA_X(22,:,:) = nanmean(dataClean2class([Gr([22]) Ye([23]) Re([27])],:,:),1);
            
            DATA_X(23,:,:) = nanmean(dataClean2class([Gr([23]) Wh([21 22]) Ye([24]) Re([18 19])],:,:),1);
            DATA_X(24,:,:) = nanmean(dataClean2class([Gr([24]) Wh([23]) Ye([24 25]) Re([20 21])],:,:),1);
            DATA_X(25,:,:) = nanmean(dataClean2class([Gr([25]) Wh([24 25]) Ye([25 26]) Re([22 23])],:,:),1);
            DATA_X(26,:,:) = nanmean(dataClean2class([Gr([26]) Wh([26]) Ye([26 27]) Re([24 25])],:,:),1);
            DATA_X(27,:,:) = nanmean(dataClean2class([Gr([27]) Wh([27 28]) Ye([27]) Re([26 27])],:,:),1);
            DATA_X(28,:,:) = nanmean(dataClean2class([Gr([28]) Wh([22 29 21]) Ye([28]) Re([28])],:,:),1);
            DATA_X(29,:,:) = nanmean(dataClean2class([Gr([29]) Wh([29 30]) Ye([29]) Re([28 29])],:,:),1);
            DATA_X(30,:,:) = nanmean(dataClean2class([Gr([30]) Wh([30 31]) Ye([30]) Re([29 30 32])],:,:),1);
            DATA_X(31,:,:) = nanmean(dataClean2class([Gr([31]) Wh([31 32]) Ye([31 32]) Re([30 31])],:,:),1);
            DATA_X(32,:,:) = nanmean(dataClean2class([Gr([32]) Wh([27 28 32]) Ye([32]) Re([31])],:,:),1);
            
            dataClean2class = [];
            PSD_W_S_red = DATA_X;
            clear DATA_X
    end
%%