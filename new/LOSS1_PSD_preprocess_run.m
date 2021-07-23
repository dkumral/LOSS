%%%%%%%%%%%%%%%%%%preprocessing
clear all
addpath('/home/kumral/neurostorage/LOSS/EEG_raw/')
filesDir = '//home/kumral/Desktop/Projects/LOSS_analyses/preprocess/';
fmin = 0.5;
fmax=30;
logtrans =1;
doplot = 1;
reject = 0;
reduce = 0;
interpolate =  0;
sharptool = 1;
condition = 'sleep';
transform = 'norm';
%mkdir(condition) 
%cd(condition)
saveDir = [condition,'_fmax',num2str(fmax),'_log',num2str(logtrans),'_reject',num2str(reject),'_reduce', num2str(reduce), '_interpolate', num2str(interpolate),transform, '_sharptool', num2str(sharptool)];
mkdir(saveDir)
cd(saveDir)
%%%%%%%%%%%%%%%%%%preprocessing%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for cyc = 1:5
    for vp = 2:21
        if vp<10
            filenameS = sprintf('LOSS_VP0%d_%d-rejected-%s.set',vp,cyc,condition);
        else
            filenameS = sprintf('LOSS_VP%d_%d-rejected-%s.set',vp,cyc, condition);
        end
        if vp<10
            filenameM = sprintf('LOSS_VP0%d_%d_PSD.mat', vp,cyc );
        else
            filenameM = sprintf('LOSS_VP%d_%d_PSD.mat', vp,cyc );
        end
        PSD_preprocess(filenameS, filenameM, fmin, fmax, logtrans, interpolate, reject, reduce, sharptool, doplot,vp,cyc, condition, transform)
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%