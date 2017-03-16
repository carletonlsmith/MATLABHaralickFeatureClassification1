function [ previous_head, previous_tail ] = InitializeFirstFrame( normedFrames_Folder, stdDevRange, meanPxRange, head_direction )
%InitializeFirstFrame: This initializes head and tail locations
%   normedFrames_Folder: string; this is folder location of the norm frames
%   stdDevRange: 1x2 array; the min and max of worm body px standard dev
%   range. This range was found by 4*StdDev's of a 40 frame sample
%   meanPxRange: 1x2 array; same as stdDevRange, this is the mean of
%   sampling distribution of means * 4std
%   head_direction: 'north' if the worm head is facing up,
    
    % all images
    frame_folder_path = fullfile(normedFrames_Folder,'\Frame 0001.png');

    % find the first frame, initialize the head and tail
    first_frame = imread(fullfile(frame_folder_path));
    
    %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    imgbw = im2bw(first_frame,.85); % make binary based on that threshold
    %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    
    % continue preprocessing the frame
    imgbw = imcomplement(imgbw); % make worm white, bkground black
    se = strel('disk',2); % create SE for closing
    imgClosed = imclose(imgbw,se); % close holes
    imgCC = bwconncomp(imgClosed); % find cc
    
    % calculate number of pixels in each connected component
    %numPixels = cellfun(@numel,imgCC.PixelIdxList);
    
    for cc_idx = 1:size(imgCC.PixelIdxList,2)
        std_dev = std(double(first_frame(imgCC.PixelIdxList{cc_idx})));
        if std_dev > stdDevRange(1,1) && std_dev < stdDevRange(1,2) 
            worm_cc_idx = imgCC.PixelIdxList{cc_idx};
        else
            imgClosed(imgCC.PixelIdxList{cc_idx}) = 0;
        end
    end
    figure; imshow(imgClosed)
    title('Does this look like a good segmentation?')
%     % delete all cc except largest one
%     for comp = 1:size(numPixels,2)
%         if numPixels(comp) > min_worm_px_sz & numPixels(comp) < max_worm_px_sz % the total number of pixels on worm body should be in this range
%             biggest = numPixels(comp);
%         else
%             imgClosed(imgCC.PixelIdxList{comp}) = 0;
%         end
%     end
    
    % get stats
    stats = regionprops('table',imgClosed,'Centroid','BoundingBox','PixelList','ConvexHull','BoundingBox','MajorAxisLength','MinorAxislength','Orientation','Extrema');
    
    % check orientation
    if stats.Orientation >=0
        PosOrient = true;
    else
        PosOrient = false;
    end
    
    % check if bad frame
    if size(stats,1) == 0
        bad_frame = true;
    end
    
    % set extrema coordinates
    if PosOrient
        extrema1 = stats.Extrema{1}(2,:);
        extrema2 = stats.Extrema{1}(6,:);
    else
        extrema1 = stats.Extrema{1}(1,:);
        extrema2 = stats.Extrema{1}(5,:);
    end
    
    % assign correct extrema to head and tail
    if head_direction == 'north'
        previous_head = extrema1;
        previous_tail = extrema2;
    else
        previous_head = extrema2;
        previous_tail = extrema1;
    end
end

