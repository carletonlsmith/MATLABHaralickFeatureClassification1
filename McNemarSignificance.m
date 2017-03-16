function [ p_value,t_stat,mcnemar_mat ] = McNemarSignificance( true_labels,M1_predictions,M2_predictions )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    mcnemar_conf_mat = zeros(2,2);
    for row = 1:size(true_labels,1)
        if M1_predictions(row,1) == true_labels(row,1) && M2_predictions(row,1) == true_labels(row,1)
            mcnemar_conf_mat(1,1) = mcnemar_conf_mat(1,1) + 1;
        elseif M1_predictions(row,1) == true_labels(row,1) && M2_predictions(row,1) ~= true_labels(row,1)
            mcnemar_conf_mat(1,2) = mcnemar_conf_mat(1,2) + 1;
        elseif M1_predictions(row,1) ~= true_labels(row,1) && M2_predictions(row,1) == true_labels(row,1)
            mcnemar_conf_mat(2,1) = mcnemar_conf_mat(2,1) + 1;
        elseif M1_predictions(row,1) ~= true_labels(row,1) && M2_predictions(row,1) ~= true_labels(row,1)
            mcnemar_conf_mat(2,2) = mcnemar_conf_mat(2,2) + 1;
        else
            sprintf('Here is the problem: ',row)
        end
    end
    
    t_stat = (mcnemar_conf_mat(1,2)-mcnemar_conf_mat(2,1))/sqrt(mcnemar_conf_mat(1,2)+mcnemar_conf_mat(2,1));
    p_value = 1-tcdf(t_stat,2);              % 1-tailed t-distribution
    mcnemar_mat = mcnemar_conf_mat;
end

