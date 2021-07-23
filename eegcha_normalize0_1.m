function norm_mat = eegcha_normalize0_1(a)
    norm_mat=zeros(size(a));
    for i = 1:height(a)
        Nr = normalize(a(i,:), 'range');
        norm_mat(i,:)=Nr;
    end
end

