% Validate Head Tail Model on New Video

% set the path
path = 'D:\Carl\Research';
cd(path)

%% Create empty data sets for Features

% Texture data set
head_data = InitializeDataSets(250,14,0);
tail_data = InitializeDataSets(250,14,1);

% Intensity data set
head_intense = InitializeDataSets(250,5,0);
tail_intense = InitializeDataSets(250,5,1);

% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
var_names = {'AngularSecondMoment','Contrast','Correlation','Variance','InvDiffMoment','SumAvg','SumVar','SumEnt','Entropy','DiffVariance','DiffEntropy','InfoMeasCorr1','InfomeasCorr2','MaxCorCoef'};
int_var_names = {'MaxIntensity','MinIntensity','MeanIntensity','StdIntensity','RangeIntensity'};
response_names = {'head','tail'};
frame_folder_name = 'Movie_Frames_From N2_NF3';
cropped_folder = 'D:\Carl\Research\input\cropped_n2_nf3V2'; % CreateCroppedImages
CustomGLCM_path = 'D:\Carl\Research';
[folder, baseFileName, extentions] = fileparts(fullfile('D:\Carl\\Research\\','N2_NF3.avi'));
normedFrames_Folder = fullfile(sprintf('%s/NormedFrames %s', folder, baseFileName)); % CreateCroppedImages
folder = pwd; % InitialzeFirstFrame
head_direction = 'south'; % InitialzeFirstFrame

training_rows = 250; % how many rows to initialize "InitializeDataSets()"
textureData_cols = 14;% how many cols to initialize "InitializeDataSets()"
intensityData_cols = 5; % how many cols (5 features for intensity)
head_label = 0; % head label in the data set
tail_label = 1;% tail label in the data set
numFramesToExtract = 500; % how many frames you want to extract from vid

% pixel intensity ranges - Don't change!!
background_min = 226; % No touchie! Min intensity for background in 1st frame
background_max = 240; % No touchie! Max intensity for background in 1st frame
background_range = 14; % No touchie! range of background ints in first frame
background_ranges = [226,240,14]; % No touchie! the ranges, just put in an array together
foreground_ranges = [97,218,121]; % No touchie! the ranges, just put in an array together
base_frame_ranges = [97,252,155]; % No touchie! This is the minimum of ENTIRE frame, not just bg and fg
    % base_frame_range is diff from foreground/bg because backgound range
    % taken from a small clean subregion of the background, not entire rng
stdDevRange = [28.56 34.82];
meanPxRange = [147 157];
kurtPxRange = [1.7554 2.5624];

% parameters for haralick features
angles = [0,45,90,135]; % GenerateHaralickFeatures
displacement = 1; % GenerateHaralickFeatures


% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

%% Extract frames from an avi video of worm

output_folder = VideoFrameExtractor(2000,'N2_NF3.avi','n2_nf3Frames')


%% Normalize the frames to be within the same range as N2_nf4
% these are saved to 'normedFrames_Folder' path
ForegroundBackgroundNorm(outputFolder,normedFrames_Folder, base_frame_ranges ,foreground_ranges, background_ranges);

%% Initialize the first frame

[previous_head, previous_tail] = InitializeFirstFrame(normedFrames_Folder,min_worm_px_sz,max_worm_px_sz,head_direction);


%% Create cropped images
CreateCroppedImages(normedFrames_Folder,min_worm_px_sz,max_worm_px_sz,previous_head,previous_tail,1402,cropped_folder);

%% Generate Features - Haralick and Intensity

% head data feature generation
[head_data,head_intense,bad_frame_idx_head,bad_frames_head] = GenerateHaralickFeatures(cropped_folder,CustomGLCM_path,'head',head_data,head_intense,displacement,angles);
cd(path)

% tail data feature generation
[tail_data,tail_intense,bad_frame_idx_tail,bad_frames_tail] = GenerateHaralickFeatures(cropped_folder,CustomGLCM_path,'tail',tail_data,tail_intense,displacement,angles);
cd(path)

%% Identify bad rows
[all_rows_to_delete] = FindRowsToDelete( head_data,tail_data );

%% Remove all bad rows

% Remove bad tail image data:
tail_data(all_rows_to_delete,:) = [];
tail_intense(all_rows_to_delete,:) = [];

% Remove bad head image data:
head_data(all_rows_to_delete,:) = [];
head_intense(all_rows_to_delete,:) = [];

%% Mapping of bad frames to original frames

% get the cropped image names
cd(cropped_folder)
head_images = dir('*head.png');
tail_images = dir('*tail.png');

% create idx mapper dictionary
cd(path)
[OrigDataSet_Head,head_idx_map] = MapRecordsToImages(all_rows_to_delete,head_data,head_images(1:250,1));
[OrigDataSet_Tail,tail_idx_map] = MapRecordsToImages(all_rows_to_delete,tail_data,tail_images(1:250,1));

%% Combine the datasets into one and normalize
% Haralick Feature Data
all_data_haralick = [head_data;tail_data];

% separate data from label
haralick_feat_data = all_data_haralick(:,1:14);
haralick_labels = all_data_haralick(:,15);

% Intensity feature data
all_data_intensity = [head_intense;tail_intense];

% separate data from label
intensity_feat_data = all_data_intensity(:,1:5);
intensity_labels = all_data_intensity(:,6);

% normalize feat data (min/max) normalization
haralick_feat_data = ColumnNormalizer(haralick_feat_data);
intensity_feat_data = ColumnNormalizer(intensity_feat_data);


%% Evaluations
% make predictions on training
tree_predH = predict(Haralick_Tree_Mdl1,haralick_feat_data,'Subtrees','all');
tree_predI = predict(Intensity_Tree_Mdl1,intensity_feat_data,'Subtrees','all');

% Confusion Matrices
confMat_treeH0 = confusionmat(haralick_labels,tree_predH(:,1))
confMat_treeI0 = confusionmat(haralick_labels,tree_predI(:,1))


%% Map incorrect cases to frames
wrong_intensity_idx0 = find(tree_predI(:,1)~=intensity_labels);
wrong_haralick_idx0 = find(tree_predH(:,1)~=haralick_labels);

[head_right,head_right_idx,both_wrong_idx_head] = M1right_M2wrong(intensity_labels,tree_predH(:,1),tree_predI(:,1),'head');
[tail_right,tail_right_idx,both_wrong_idx_tail] = M1right_M2wrong(intensity_labels,tree_predH(:,1),tree_predI(:,1),'tail');

%% Significance Test

[p_val,t_stat,McNemar_mat] = McNemarSignificance(intensity_labels,tree_predH(:,1),tree_predI(:,1));







