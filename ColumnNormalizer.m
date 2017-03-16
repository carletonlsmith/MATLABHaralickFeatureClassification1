function [ norm_mat ] = ColumnNormalizer( matrix )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

norm_mat = zeros(size(matrix));
for col = 1:size(matrix,2)
    min_val = min(matrix(:,col));
    max_val = max(matrix(:,col));
    for row = 1:size(matrix,1)
        norm_mat(row,col) = (double(matrix(row,col)-min_val))/(double(max_val-min_val));
    end
end

