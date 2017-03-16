function [ DataSetA,DataSetB,DataSetC,DataSetD,breakdown_cell,McNemarResults,M1vM2_ConfMat ] = MisclassifiedAnalysis( MapperDictVal,MapperDictFramesHead,TexturePreds,IntPreds,Actuals,img_folder,QuadrantToView ,stdDevRange)
%MisclassifiedAnalysis: Analysis of misclassifed cases
%   MapperDictVal: the dictionary created in 'Map the Validation set
%       indices to the indices of the entire data set' section
%   MapperDictFramesHead: the dictionary created with 'MapRecordsToImages' func
%   MapperDictFramesTail: the dictionary created with 'MapRecordsToImages' func
%   TexturePreds: predictions from texture model
%   IntPreds: predictions from intensity model
%   Actuals: actual labels to validation set
%   img_folder: string; path to the folder with the original frame images
%   QuadrantToView: string; can be any of these four: ["A","B","C","D"]
% OUTPUT
%   DataSetA-DataSetD: these list the misclassified cases that fall into
%       each quadrant (A is Texture and Intensity BOTH correct)
%   breakdown_cell: cell structure; lists breakdown of H/T in each quadrant
%   McNemarResults: results from McNemar statistical test
%   M1vM2_ConfMat: Confusion Mat comparing two models (intesity v texture)
    


    % find out how many rows are needed for datasets A-D
    A_rows = 0;
    B_rows = 0;
    C_rows = 0;
    D_rows = 0;
    for row = 1:size(Actuals,1)
       if IntPreds(row,1) == Actuals(row,1)
           if TexturePreds(row,1) == Actuals(row,1)
               A_rows = A_rows + 1;
           else
               D_rows = D_rows + 1;
           end
       else
           if TexturePreds(row,1) == Actuals(row,1)
               B_rows = B_rows + 1;
           else
               C_rows = C_rows + 1;
           end
       end
    end
    
    % initialize the misclassified data sets
    DataSetA = zeros(A_rows,4);
    DataSetB = zeros(B_rows,4);
    DataSetC = zeros(C_rows,4);
    DataSetD = zeros(D_rows,4);
    
    M1vM2_ConfMat = zeros(3,3); % initialize the Model to Model Conf Mat
    
    % initalize the row index for each data set
    A_cnt = 1;
    B_cnt = 1;
    C_cnt = 1;
    D_cnt = 1;
    
    % populate the misclassifed cases datasets and M1vM2 conf matrix
    for val_idx = 1:size(Actuals,1) % iterate through all validation set
        if Actuals(val_idx,1) == 1; % if tail label: get the right idx for mapping correctly
            endPtTag = 'tail';
            FrameMapperVal = MapperDictVal(val_idx) - size(MapperDictFramesHead,1); % offset the index so it maps correctly
        else
            endPtTag = 'head';
            FrameMapperVal = MapperDictVal(val_idx); % no offset (because head data was vertically concatenated first in dataset)
        end
        if IntPreds(val_idx,1) == Actuals(val_idx,1)
            if TexturePreds(val_idx,1) == Actuals(val_idx,1)
                M1vM2_ConfMat(1,1) = M1vM2_ConfMat(1,1)+1; % increment Model conf mat
                DataSetA(A_cnt,1) = MapperDictFramesHead(FrameMapperVal); % first col is frame index
                DataSetA(A_cnt,2) = Actuals(val_idx,1); % second col is actual label
                DataSetA(A_cnt,3) = TexturePreds(val_idx,1); % third col is texture prediction
                DataSetA(A_cnt,4) = IntPreds(val_idx,1); % fourth col is intensity prediction
                A_cnt = A_cnt + 1; % increment the A dataset index by 1
                if QuadrantToView == 'A' % if you want to see figs from this quadrant
                    GenerateSegFigComparison(img_folder,endPtTag,stdDevRange,MapperDictFramesHead(FrameMapperVal));
                end
            else
                M1vM2_ConfMat(2,1) = M1vM2_ConfMat(2,1)+1; % increment Model conf mat
                DataSetD(D_cnt,1) = MapperDictFramesHead(FrameMapperVal); % first col is frame index
                DataSetD(D_cnt,2) = Actuals(val_idx,1); % second col is actual label
                DataSetD(D_cnt,3) = TexturePreds(val_idx,1); % third col is texture prediction
                DataSetD(D_cnt,4) = IntPreds(val_idx,1); % fourth col is intensity prediction
                D_cnt = D_cnt + 1; % increment the D dataset index by 1
                
                
                
            end
        else
            if TexturePreds(val_idx,1) == Actuals(val_idx,1)
                M1vM2_ConfMat(1,2) = M1vM2_ConfMat(1,2)+1; % increment Model conf mat
                DataSetB(B_cnt,1) = MapperDictFramesHead(FrameMapperVal); % first col is frame index
                DataSetB(B_cnt,2) = Actuals(val_idx,1); % second col is actual label
                DataSetB(B_cnt,3) = TexturePreds(val_idx,1); % third col is texture prediction
                DataSetB(B_cnt,4) = IntPreds(val_idx,1); % fourth col is intensity prediction
                B_cnt = B_cnt + 1; % increment the B dataset index by 1
            else
                M1vM2_ConfMat(2,2) = M1vM2_ConfMat(2,2)+1; % increment Model conf mat
                DataSetC(C_cnt,1) = MapperDictFramesHead(FrameMapperVal); % first col is frame index
                DataSetC(C_cnt,2) = Actuals(val_idx,1); % second col is actual label
                DataSetC(C_cnt,3) = TexturePreds(val_idx,1); % third col is texture prediction
                DataSetC(C_cnt,4) = IntPreds(val_idx,1); % fourth col is intensity prediction
                C_cnt = C_cnt + 1; % increment the C dataset index by 1
            end
        end
    end
    
    % find break down of head and tail in each quadrant (dependent on tail
    % label = 1 and head label = 0)
    A_head = A_cnt - sum(DataSetA(:,2)); 
    A_tail = sum(DataSetA(:,2));
    B_head = B_cnt - sum(DataSetB(:,2)); 
    B_tail = sum(DataSetB(:,2));
    C_head = C_cnt - sum(DataSetC(:,2)); 
    C_tail = sum(DataSetC(:,2));
    D_head = D_cnt - sum(DataSetD(:,2)); 
    D_tail = sum(DataSetD(:,2));
    
    % put head/tail breakdown of quadrants into cell format
    breakdown_cell = cell(4,2);
    breakdown_cell{1,1} = A_head;
    breakdown_cell{1,2} = A_tail;
    breakdown_cell{2,1} = B_head;
    breakdown_cell{2,2} = B_tail;
    breakdown_cell{3,1} = C_head;
    breakdown_cell{3,2} = C_tail;
    breakdown_cell{4,1} = D_head;
    breakdown_cell{4,2} = D_tail;
    
    
    % fill out the totals for M1 vs M2 Conf Mat
    M1vM2_ConfMat(3,1) = sum(M1vM2_ConfMat(1:2,1));
    M1vM2_ConfMat(3,2) = sum(M1vM2_ConfMat(1:2,2));
    M1vM2_ConfMat(1,3) = sum(M1vM2_ConfMat(1,1:2));
    M1vM2_ConfMat(2,3) = sum(M1vM2_ConfMat(2,1:2));
    M1vM2_ConfMat(3,3) = sum(M1vM2_ConfMat(3,1:2));
    if M1vM2_ConfMat(3,3) ~= sum(M1vM2_ConfMat(1:2,3))
        error('You have a problem with your M2M Conf Matrix. Make sure it adds up.')
    end

    % McNemar Significance Test
    t_stat = (M1vM2_ConfMat(1,2)-M1vM2_ConfMat(2,1))/sqrt(M1vM2_ConfMat(1,2)+M1vM2_ConfMat(2,1));
    p_value = 1-tcdf(t_stat,2);
    McNemarResults = [t_stat, p_value];
        
        
        
        
    
    % set the cd
    cd(img_folder)
    
    % grab images
    imgs = dir(strcat('GOOD_',img_label,'*'));
    num_of_imgs = size(dir(strcat('GOOD_',img_label,'*')),1); % how many images to process
    
    % make cell array to store the frame number of the cropped image
    cell_arr = cell(num_of_imgs,1);
        
end

