%%%%this function is implemented for the normalization of the PSDs%%%
function norm_mat = eegcha_normalize0_1(a)
norm_mat=zeros(size(a));
for stg = 1:size(a,3) %giving you the stage dimension
    for i = 1:size(a,1) %giving you the channel dimension
        Nr = normalize(squeeze(a(i,:,stg)), 'range');
        norm_mat(i,:,stg)=Nr;
    end
end
end
%%