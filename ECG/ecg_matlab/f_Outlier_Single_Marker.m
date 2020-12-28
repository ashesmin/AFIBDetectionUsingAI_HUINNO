
function [mark_table] = f_Outlier_Single_Marker(delta_data, threshold)

mark_value = 50;
mark_table = zeros(length(delta_data), 1);

%% Step1 : To find Outlier and mark as window size(20)
for i=1:length(delta_data)
    % If value is higer than threshold
    if(delta_data(i) >= threshold)
       for j=(max(1, i-2)):(min(i+2, length(delta_data)))
          mark_table(j) = mark_value;
       end
    end
end

index_prev_mark = 1;
for i=1:length(mark_table)
    if(mark_table(i) == mark_value)
        index_cur_mark = i;
        if((index_cur_mark - index_prev_mark) <= 5)
           mark_table(index_prev_mark:index_cur_mark) = mark_value;
        end
        index_prev_mark = index_cur_mark;
        
        % Exception : Upper bound hit
        if((index_cur_mark > length(mark_table)-5))
            mark_table(index_cur_mark:length(mark_table)) = mark_value;
        end
    end
end

end