function s_t_matrix = sharp_tool(matrix, window_length, adjust)
%In each channel, this function places a window around one value, gets the
%average of the whole window and subtracts it from the current value. If
%the window would hypothetically extend over the beginning or the end of
%the channel, the function can adjust the window accordingly.
%
%
%example:
%channel = [10, 4, 2, 5, 14, 8, 3, 2], windowsize = 2
%When the value is 2 (third value), the function will calcluate the moving 
%average for values 10,4,2,5,14 and subtract that average from the value 2.
%For the value 4 (second value), the window would extend over the
%beginning, so window would be adjusted to only include the values 
%10, 4, 2, 5 and subtract their average from 4.
%
%
%Output: The copy of the input matrix with the moving average subtracted
    s_t_matrix = matrix;
    
    %adds 1 if window_length is an uneven number
    if mod(window_length,2)==1
        window_length = window_length +1;
        disp('Added 1 to window_length to make it an even number')
    end
    
    half_window = window_length/2;
    %Application of the moving average window and substraction of the
    %average values
    
    if nargin ==2
        adjust = 1;
    end
    
    if adjust
        for i = 1:height(s_t_matrix)
            chan_len = width(s_t_matrix(i,:)); %power values Hz
            for j = 1:chan_len            
                if j-half_window < 1
                    MA = nanmean(matrix(i, 1:(j+half_window)));
                elseif j+half_window > chan_len
                    MA = nanmean(matrix(i,(j-half_window):end));
                else           
                    MA = nanmean(matrix(i, (j-half_window):(j+half_window)));
                end
                s_t_matrix(i,j) = s_t_matrix(i,j)-MA;        
            end
        end
        
    elseif ~adjust                
        for i = 1:height(s_t_matrix)
            chan_len = width(s_t_matrix(i,:));
            for j = half_window+1:chan_len-half_window
                MA = nanmean(matrix(i, j-half_window:j+half_window));
                s_t_matrix(i,j) = s_t_matrix(i,j)-MA;
            end
        end
    end
end

            