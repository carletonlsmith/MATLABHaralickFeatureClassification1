function [ data_set ] = InitializeDataSets( rows, cols, label )
%InitializeDataSets: creates an empty dataset with the given num rows and
%label in last column
%   rows: int; the number of rows to include in the dataset of all zeros
%   cols: int; the number of columns to include in the dataset, not
%   including the label column
%   label: the label to provide in the last column of the dataset
%   data_set: array of all zeros with the label as last column
    
    data_set = zeros(rows,cols+1);
    if label ~= 0
        data_set(:,cols+1) = repmat(1,[rows,label]);
    end
end

