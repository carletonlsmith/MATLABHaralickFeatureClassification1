function [ output_args ] = GenerateSegFigComparison( normedFrames_Folder,endPtTag,stdDevRange,frameIdx )
%UNTITLED3 Summary of this function goes here
%   normedFrames_Folder: string; path to the folder with the normed images
%   endPtTag: string; which cropped image to select - head or tail
%   frameIdx: the frame index to read

    % set the cd
    cd(normedFrames_Folder)
    
    idxWithOffset = frameIdx + 2; % the first two rows in struct created from dir() are just a "." and ".."
    all_files = dir(normedFrames_Folder);
    framePath = fullfile(normedFrames_Folder,all_files(idxWithOffset).name);
    
    % find the first frame, initialize the head and tail
    TheFrame = imread(framePath);
    
    %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    imgbw = im2bw(TheFrame,.85); % make binary based on that threshold
    %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    
    % continue preprocessing the frame
    imgbw = imcomplement(imgbw); % make worm white, bkground black
    se = strel('disk',2); % create SE for closing
    imgClosed = imclose(imgbw,se); % close holes
    imgCC = bwconncomp(imgClosed); % find cc
    
    % calculate number of pixels in each connected component
    %numPixels = cellfun(@numel,imgCC.PixelIdxList);
    
    for cc_idx = 1:size(imgCC.PixelIdxList,2) % for each connected component
        std_dev = std(double(TheFrame(imgCC.PixelIdxList{cc_idx}))); % calculate the std dev of that comp
        if std_dev > stdDevRange(1,1) && std_dev < stdDevRange(1,2) % if the std dev is in correct range
            worm_cc_idx = imgCC.PixelIdxList{cc_idx}; % grab the idx of worm
        else
            imgClosed(imgCC.PixelIdxList{cc_idx}) = 0; % set the rest cc = 0
        end
    end

    % get stats
    stats = regionprops('table',imgClosed,'Centroid','BoundingBox','PixelList','ConvexHull','MajorAxisLength','MinorAxislength','Orientation','Extrema');
    
    % find the contour points from segmentation
    countourPts = bwboundaries(imgClosed,'noholes');
    
    F2 = TheFrame;
    Frgb = cat(3,F2,F2,F2); % convert to rgb
    
    % make contour outline blue
    for px = 1:size(countourPts{1},1) % make contour blue
        Frgb(countourPts{1}(px,1),countourPts{1}(px,2),1) = 0;
        Frgb(countourPts{1}(px,1),countourPts{1}(px,2),2) = 0;
        Frgb(countourPts{1}(px,1),countourPts{1}(px,2),3) = 255;
        
        % to add thickness, add another adjacent pixel
        Frgb(countourPts{1}(px,1),countourPts{1}(px,2)-1,1) = 0;
        Frgb(countourPts{1}(px,1),countourPts{1}(px,2)-1,2) = 0;
        Frgb(countourPts{1}(px,1),countourPts{1}(px,2)-1,3) = 255;
    end

    % check orientation
    if stats.Orientation >=0
        extrema1 = stats.Extrema{1}(2,:);
        extrema2 = stats.Extrema{1}(6,:);
    else
        extrema1 = stats.Extrema{1}(1,:);
        extrema2 = stats.Extrema{1}(5,:);
    end
    
    % make the extrema pts red
    
    %% EXTREMA 1
    for padding = 1:2
        % top left
        Frgb(floor(extrema1(1,2))-padding,floor(extrema1(1,1))-padding,1) = 255;
        Frgb(floor(extrema1(1,2))-padding,floor(extrema1(1,1))-padding,2) = 0;
        Frgb(floor(extrema1(1,2))-padding,floor(extrema1(1,1))-padding,3) = 0;

        % top middle
        Frgb(floor(extrema1(1,2))-padding,floor(extrema1(1,1)),1) = 255;
        Frgb(floor(extrema1(1,2))-padding,floor(extrema1(1,1)),2) = 0;
        Frgb(floor(extrema1(1,2))-padding,floor(extrema1(1,1)),3) = 0;

        % top right
        Frgb(floor(extrema1(1,2))-padding,floor(extrema1(1,1))+padding,1) = 255;
        Frgb(floor(extrema1(1,2))-padding,floor(extrema1(1,1))+padding,2) = 0;
        Frgb(floor(extrema1(1,2))-padding,floor(extrema1(1,1))+padding,3) = 0;

        % middle left
        Frgb(floor(extrema1(1,2)),floor(extrema1(1,1))-padding,1) = 255;
        Frgb(floor(extrema1(1,2)),floor(extrema1(1,1))-padding,2) = 0;
        Frgb(floor(extrema1(1,2)),floor(extrema1(1,1))-padding,3) = 0;

        % the center
        Frgb(floor(extrema1(1,2)),floor(extrema1(1,1)),1) = 255;
        Frgb(floor(extrema1(1,2)),floor(extrema1(1,1)),2) = 0;
        Frgb(floor(extrema1(1,2)),floor(extrema1(1,1)),3) = 0;

        % middle right
        Frgb(floor(extrema1(1,2)),floor(extrema1(1,1))+padding,1) = 255;
        Frgb(floor(extrema1(1,2)),floor(extrema1(1,1))+padding,2) = 0;
        Frgb(floor(extrema1(1,2)),floor(extrema1(1,1))+padding,3) = 0;

        % bottom left
        Frgb(floor(extrema1(1,2))+padding,floor(extrema1(1,1))-padding,1) = 255;
        Frgb(floor(extrema1(1,2))+padding,floor(extrema1(1,1))-padding,2) = 0;
        Frgb(floor(extrema1(1,2))+padding,floor(extrema1(1,1))-padding,3) = 0;

        % bottom middle
        Frgb(floor(extrema1(1,2))+padding,floor(extrema1(1,1)),1) = 255;
        Frgb(floor(extrema1(1,2))+padding,floor(extrema1(1,1)),2) = 0;
        Frgb(floor(extrema1(1,2))+padding,floor(extrema1(1,1)),3) = 0;

        % bottom right
        Frgb(floor(extrema1(1,2))+padding,floor(extrema1(1,1))+padding,1) = 255;
        Frgb(floor(extrema1(1,2))+padding,floor(extrema1(1,1))+padding,2) = 0;
        Frgb(floor(extrema1(1,2))+padding,floor(extrema1(1,1))+padding,3) = 0;
    end
    
    %% EXTREMA 2
    for padding = 1:2
        % top left
        Frgb(floor(extrema2(1,2))-padding,floor(extrema2(1,1))-padding,1) = 255;
        Frgb(floor(extrema2(1,2))-padding,floor(extrema2(1,1))-padding,2) = 0;
        Frgb(floor(extrema2(1,2))-padding,floor(extrema2(1,1))-padding,3) = 0;

        % top middle
        Frgb(floor(extrema2(1,2))-padding,floor(extrema2(1,1)),1) = 255;
        Frgb(floor(extrema2(1,2))-padding,floor(extrema2(1,1)),2) = 0;
        Frgb(floor(extrema2(1,2))-padding,floor(extrema2(1,1)),3) = 0;

        % top right
        Frgb(floor(extrema2(1,2))-padding,floor(extrema2(1,1))+padding,1) = 255;
        Frgb(floor(extrema2(1,2))-padding,floor(extrema2(1,1))+padding,2) = 0;
        Frgb(floor(extrema2(1,2))-padding,floor(extrema2(1,1))+padding,3) = 0;

        % middle left
        Frgb(floor(extrema2(1,2)),floor(extrema2(1,1))-padding,1) = 255;
        Frgb(floor(extrema2(1,2)),floor(extrema2(1,1))-padding,2) = 0;
        Frgb(floor(extrema2(1,2)),floor(extrema2(1,1))-padding,3) = 0;

        % the center
        Frgb(floor(extrema2(1,2)),floor(extrema2(1,1)),1) = 255;
        Frgb(floor(extrema2(1,2)),floor(extrema2(1,1)),2) = 0;
        Frgb(floor(extrema2(1,2)),floor(extrema2(1,1)),3) = 0;

        % middle right
        Frgb(floor(extrema2(1,2)),floor(extrema2(1,1))+padding,1) = 255;
        Frgb(floor(extrema2(1,2)),floor(extrema2(1,1))+padding,2) = 0;
        Frgb(floor(extrema2(1,2)),floor(extrema2(1,1))+padding,3) = 0;

        % bottom left
        Frgb(floor(extrema2(1,2))+padding,floor(extrema2(1,1))-padding,1) = 255;
        Frgb(floor(extrema2(1,2))+padding,floor(extrema2(1,1))-padding,2) = 0;
        Frgb(floor(extrema2(1,2))+padding,floor(extrema2(1,1))-padding,3) = 0;

        % bottom middle
        Frgb(floor(extrema2(1,2))+padding,floor(extrema2(1,1)),1) = 255;
        Frgb(floor(extrema2(1,2))+padding,floor(extrema2(1,1)),2) = 0;
        Frgb(floor(extrema2(1,2))+padding,floor(extrema2(1,1)),3) = 0;

        % bottom right
        Frgb(floor(extrema2(1,2))+padding,floor(extrema2(1,1))+padding,1) = 255;
        Frgb(floor(extrema2(1,2))+padding,floor(extrema2(1,1))+padding,2) = 0;
        Frgb(floor(extrema2(1,2))+padding,floor(extrema2(1,1))+padding,3) = 0;
    end
    
    
    % plot the comparison
    figure; imshowpair(TheFrame,Frgb,'montage','scaling','none')

end

