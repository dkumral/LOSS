maxvp=21;
maxcon=1;
maxcyc=5;
maxstage=6;
maxchan=128;
maxrep=1500;
maxbins=200;

cd \\MEMO-07\DataD\LOSS\
filepath = '\\MEMO-07\DataD\LOSS\EEG_raw\';
%%
for cyc = 4:maxcyc
    d=dir([filepath sprintf('LOSS_VP*_%d_PSD.mat',cyc)]);
    d(cellfun(@length,{d.name})>19) = [];
    clear ALL;
    ALL.nst = NaN(maxvp,maxcon,1,maxstage,'single');
    ALL.psd = NaN(maxvp,maxcon,1,maxstage,maxchan,maxbins,maxrep,'single');
    for i=1:length(d)
        fprintf('%s.set\n',d(i).name(1:end-4));
        if ~exist([filepath d(i).name(1:end-8) '-rejected-sleep.set'],'file')
            warning('Nonexistant: skipping.');
            continue
        end

        vp = str2double(d(i).name(8:9));
        con=1;

        ALL.vp(vp) = vp;

        clear PSD EEG;
        load([filepath d(i).name]);
        load([filepath d(i).name(1:end-8) '-rejected-sleep.set'],'-mat');
        nsc = length(EEG.stats.sleep_trial);
        if nsc~=EEG.trials
            error('nsc');
        end

        PSD = PSD(:,:,EEG.stats.usetrials);
        PSD = reshape(PSD,maxchan,maxbins*EEG.trials);
        fprintf('Using ''nearest'' interpolation for %d bad channels.\n',sum(EEG.reject.rejglobalC));
        PSD = egb_interp(PSD,EEG.chanlocs,~EEG.reject.rejglobalC,'nearest');
        PSD = reshape(PSD,maxchan,maxbins,EEG.trials);
        %figure; semilogy(mean(PSD(:,:,~EEG.reject.rejglobal),3)');
        %title(sprintf('vp%d N%d',vp,night));
        %pause(0.3);

        for sta=2:maxstage
            gepochs = (EEG.stats.sleep_trial==(sta-1));
            fprintf('Stage %d: #%d\n',sta,sum(gepochs));
            if sum(gepochs)>maxrep
                warning('too many epochs');
                gepochs(max(find(gepochs,maxrep))+1:end) = false;
            end
            if sum(gepochs)>10
                ALL.nst(vp,con,1,sta) = sum(gepochs);
                ALL.psd(vp,con,1,sta,:,:,1:sum(gepochs)) = PSD(:,:,gepochs);
            else
                ALL.nst(vp,con,1,sta) = 0;
                ALL.psd(vp,con,1,sta,:,:,:) = NaN;
            end                
        end
        ALL.F = F;
    end
    save(sprintf('LOSS_classify_sleep_dat_all_trials_cyc_%d.mat',cyc),'ALL','-v7.3');
end
     