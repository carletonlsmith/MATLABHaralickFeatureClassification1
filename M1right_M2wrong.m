function [ M1_correct_cnt, idx_lst, bothWrong_idx] = M1right_M2wrong( actual_labels, M1_preds,M2_preds,endpt )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    M1_correct_cnt = 0;
    idx_lst = [];
    bothWrong_idx = [];
    for row = 1:size(actual_labels,1)
        if endpt == 'head'
            if M1_preds(row,1) == 0 && actual_labels(row,1) == M1_preds(row,1) && M2_preds(row,1)==1
                M1_correct_cnt = M1_correct_cnt + 1;
                idx_lst = [idx_lst row];
            elseif M1_preds(row,1) == 1 && actual_labels(row,1) ~= M1_preds(row,1) && M2_preds(row,1)==1
                bothWrong_idx = [bothWrong_idx row];
            end
        elseif endpt == 'tail'
            if M1_preds(row,1) == 1 && actual_labels(row,1) == M1_preds(row,1) && M2_preds(row,1)==0
                M1_correct_cnt = M1_correct_cnt + 1;
                idx_lst = [idx_lst row];
            elseif M1_preds(row,1) == 0 && actual_labels(row,1) ~= M1_preds(row,1) && M2_preds(row,1)==0
                bothWrong_idx = [bothWrong_idx row];
            end
        end     
end

