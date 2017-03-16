function [ modelX,tree_pred,confMat,Acc,mis_classedFrames ] = RunDTModels( Data,Class_Labels,TrainingLogicalIdx,ValidationLogicalIdx,MinLeafSize,PredictorNames,FrameNamesCell )
%UNTITLED Summary of this function goes here
%   Data: the entire data set
%   Class_Labels: the true class labels
%   TrainingLogicalIdx: logical array of training indices
%   ValidationLogicalIdx: logical array of training indices
%   MinLeafSize: int; min leaf size parameter
%   PredictorNames: list; the names of the features in the data
%   FrameNamesCell: Cell array with the names of the all frames used to
%       generate features
%   Output: mis_classedFrames a nx3 array. 1st col is orig frame idx

    % find training and testing frame names
    TrnFrame_names = FrameNamesCell(TrainingLogicalIdx,1); % training
    TestFrame_names = FrameNamesCell(ValidationLogicalIdx,1); % testing
    
    % create the model
    modelX = fitctree(Data(TrainingLogicalIdx,:),Class_Labels(TrainingLogicalIdx),'PredictorNames',PredictorNames,'MinLeafSize',MinLeafSize);
    
    % display the DT
    view(modelX,'Mode','graph')
    
    % make predictions using the new model
    tree_pred = predict(modelX,Data(ValidationLogicalIdx,:),'Subtrees','all');
    
    % Confusion Matrix
    confMat = confusionmat(Class_Labels(ValidationLogicalIdx,:),tree_pred(:,1));
    
    % calculate accuracy
    Acc = double(confMat(1,1)+confMat(2,2))/double(sum(sum(confMat)));

    % find frames of misclassified cases
    mis_classedFrames = cell(confMat(2,1)+confMat(1,2),3);
    idx_cnt = 1;
    ValLabels = Class_Labels(ValidationLogicalIdx,:);
    for row = 1:size(tree_pred,1)
        if tree_pred(row,1) ~= ValLabels(row,1)
            int_idx = regexp(TestFrame_names{row,1},'\d{4,4}','match');
            mis_classedFrames{idx_cnt,1} = str2num(int_idx{1});
            mis_classedFrames{idx_cnt,2} = row;
            mis_classedFrames{idx_cnt,3} = TestFrame_names{row,1};
            idx_cnt = idx_cnt + 1;
        else
            continue
        end
    end
end

