function [ data_set_hara,data_set_int,bad_frame_idx,bad_frames,cell_arr ] = GenerateHaralickFeatures( img_folder,CustomGLCM_path,img_label,displacement,angles )
% GenerateHaralickFeatures: This generates haralick features from images
%   img_folder: string; absolute file path to the images
%   CustomGLCM_path: string; absolute file path to the GLCM function
%   img_label: string; name of the images to be used as labels (example:
%       'head' or 'tail')
%   data_set: NxM array; an empty data set created by InitializeDataSets
%   angles: 1xM array; lists the angles to consider in GLCM: [0,45,90,135]
%   displacement: int; the displacement dist used to generate the GLCM
% % OUTPUT:
%   data_set_hara: NxM array; the haralick data set
%   data_set_int: NxM array; the intensity data set
%   bad_frame_idx: 1xM array; the bad frame indexes
%   bad_frames: int; the count of bad frames

    % set the cd
    cd(img_folder)
    
    % grab images
    imgs = dir(strcat('GOOD_',img_label,'*'));
    num_of_imgs = size(dir(strcat('GOOD_',img_label,'*')),1); % how many images to process
    
    % make cell array to store the frame number of the cropped image
    cell_arr = cell(num_of_imgs,1);
    
    cd(CustomGLCM_path);
    % Intensity data set: InitializeDataSets(rows,columns,class_label)
    if img_label == 'head'
        data_set_hara = InitializeDataSets(num_of_imgs,14,0);
        data_set_int = InitializeDataSets(num_of_imgs,5,0);
    elseif img_label == 'tail'
        data_set_hara = InitializeDataSets(num_of_imgs,14,1);
        data_set_int = InitializeDataSets(num_of_imgs,5,1);
    else
        error('Nah, specify "head" or "tail" as img_label. You got this!')
    end
    
    se = strel('disk',2);
    cd(img_folder)
    bad_frames = 0;
    bad_frame_idx = zeros(size(imgs,1),1);
    for img_idx = 1:num_of_imgs % loop through all the head images
        cd(img_folder); % set path
        img = imread(imgs(img_idx).name);% read img
        cell_arr{img_idx} = imgs(img_idx).name;
        imgbw = im2bw(img,.85); % make binary
        imgbw = imcomplement(imgbw); % make worm white, bkground black
        imgCC = bwconncomp(imgbw); % find cc

        % evaluate if the cropped image is a bad cropping by checking number of
        % cc inside the object imgCC. Keep track of bad images.

        if imgCC.NumObjects~=1 || mean2(img) < 1 || size(img,1) < 31
            bad_frames = bad_frames+1;
            bad_frame_idx(img_idx,1) = img_idx;
            
            imgbw2 = imerode(imgbw,se);
            imgbw3 = imdilate(imgbw2,se);
            imgCC2 = bwconncomp(imgbw3);
            if imgCC2.NumObjects~=1
                figure; imshow(imgbw3)
                imgs(img_idx).name
            end
            imgCC = bwconncomp(imgbw3);
            
%             % set haralick features equal to zero
%             for col = 1:14 % for each column, append the values to the final dataframe
%                 data_set_hara(img_idx,col) = 0;
%             end
% 
%             % set intensity features equal to zero
%             data_set_int(img_idx,1) = 0;
%             data_set_int(img_idx,2) = 0;
%             data_set_int(img_idx,3) = 0;
%             data_set_int(img_idx,4) = 0;
%             data_set_int(img_idx,5) = 0;

%             continue
        end


        %% haralick without background - calculate glcm for [0,45,90,135]
        cd(CustomGLCM_path) % set the path to find the NewCustomGLCM function
        if img % if the image is not all zeros, then:
            glcms_arr = [];
            for ang = 1:size(angles,2) % for every direction to consider
                glcm = NewCustomGLCM(img,imgCC.PixelIdxList{1},[size(img,1) size(img,2)],displacement,ang);
                ang = int2str(angles(ang)); % convert angles to strings
                glcms_arr = [glcms_arr glcm];
                %assignin('caller',strcat('GLCM',ang),glcm) % append the angle to the name of the new GLCM variable
            end
            haralick0 = haralickTextureFeatures(glcms_arr(:,1:8)); % create the 14 texture features using the 0 degree angle
            haralick45 = haralickTextureFeatures(glcms_arr(:,9:16)); % create the 14 texture features using the 45 degree angle
            haralick90 = haralickTextureFeatures(glcms_arr(:,17:24)); % create the 14 texture features using the 90 degree angle
            haralick135 = haralickTextureFeatures(glcms_arr(:,25:32)); % create the 14 texture features using the 135 degree angle

            %noAgg_haralick = horzcat(haralick0.',haralick45.',haralick90.',haralick135.'); % disregard this line

            %% resume haralick
            haralick_final = double(ones(14,1)); % initialize the final data frame
            for feature = 1:14 % for each feature, find the mean of all 4 angles
                haralick_final(feature) = mean([haralick0(feature),haralick45(feature),haralick90(feature),haralick135(feature)]);
            end
            haralick_final = haralick_final.'; % averaged haralick features

            % put features into data set
            for col = 1:14 % for each column, append the values to the final dataframe
                data_set_hara(img_idx,col) = haralick_final(1,col);
            end

            % no aggregation dataset
            %for col = 1:56 % disregard. This is a dataset without finding the mean of 4 angles. I don't use this.
                %head_noAgg(img_idx,col) = noAgg_haralick(1,col);
            %end

            % find intensity features
            [i,j] = ind2sub([31,31],imgCC.PixelIdxList{1}); % convert linear idx to subscript idx
            intensities = [];
            for worm_px = 1:size(imgCC.PixelIdxList{1},1) % for every px on the worm
                intensities = [intensities img(i(worm_px),j(worm_px))]; % append the intensities to this array
            end

            % calculate the intensity features
            intensities = double(intensities);
            max_int = max(intensities);
            min_int = min(intensities);
            mean_int = mean(intensities);
            std_int = std(intensities);
            range_int = max_int - min_int;

            % put intensity features into data set
            data_set_int(img_idx,1) = max_int;
            data_set_int(img_idx,2) = min_int;
            data_set_int(img_idx,3) = mean_int;
            data_set_int(img_idx,4) = std_int;
            data_set_int(img_idx,5) = range_int;
        end
    end % head features for texture and intensity are complete

    
    
    
    

end

