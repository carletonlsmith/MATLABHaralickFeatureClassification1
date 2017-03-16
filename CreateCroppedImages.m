function [  ] = CreateCroppedImages( normedFrames_Folder,stdDevRange,kurtPxRange,previous_head,previous_tail,num_of_crops,cropped_folder )
%CreateCroppedImages: Create cropped images of head and tail within a folder
%   normedFrames_Folder: string; the path to the normalized image frames
%   stdDevRange: 1x2 array; the min and max of worm body px standard dev
%   previous_head: 1x2 array; the x and y coordinates of the previous head
%   previous_tail: 1x2 array; the x and y coordiantes of the previous tail
%   num_of_crops: int; the number of cropped images to create
%   cropped_folder: string; the folder to save cropped images
    all_images = dir(normedFrames_Folder);
    for img_idx = 3:num_of_crops+2 % I picked 1402, nothing special about it.
        img_gr = imread(strcat(all_images(img_idx).folder,'\',all_images(img_idx).name));% read img
        imgbw = im2bw(img_gr,.85); % make binary based on that threshold
        imgbw = imcomplement(imgbw); % make worm white, bkground black
        se = strel('disk',2); % create SE for closing
        imgClosed = imclose(imgbw,se); % close holes
        imgCC = bwconncomp(imgClosed); % find cc
        bad_frame = false;

        % remove all CC except for largest
        %numPixels = cellfun(@numel,imgCC.PixelIdxList);

%         % delete all cc except largest one
%         for cc_idx = 1:size(imgCC.PixelIdxList,2)
%             std_dev = std(double(img_gr(imgCC.PixelIdxList{cc_idx})));
%             mean_val = mean(double(img_gr(imgCC.PixelIdxList{cc_idx})));
%             if std_dev > stdDevRange(1,1) && std_dev < stdDevRange(1,2) && mean_val > meanPxRange(1,1) && mean_val < meanPxRange(1,2)
%                 worm_cc_idx = imgCC.PixelIdxList{cc_idx};
%             else
%                 imgClosed(imgCC.PixelIdxList{cc_idx}) = 0;
%             end
%         end

        % delete all cc except largest one
        for cc_idx = 1:size(imgCC.PixelIdxList,2)
            std_dev = std(double(img_gr(imgCC.PixelIdxList{cc_idx})));
            kurt_val = kurtosis(double(img_gr(imgCC.PixelIdxList{cc_idx})));
            if std_dev > stdDevRange(1,1) && std_dev < stdDevRange(1,2) && kurt_val > kurtPxRange(1,1) && kurt_val < kurtPxRange(1,2)
                worm_cc_idx = imgCC.PixelIdxList{cc_idx};
            else
                imgClosed(imgCC.PixelIdxList{cc_idx}) = 0;
            end
        end


        % find pixels consisting of worm, and other stats
        stats = regionprops('table',imgClosed,'Centroid','BoundingBox','PixelList','ConvexHull','BoundingBox','MajorAxisLength','MinorAxislength','Orientation','Extrema');

        % check if bad frame (camera mvmt, ect).
        %curr_centroid  = stats.Centroid;
        if size(stats,1) == 0
            bad_frame = true;
        end

        % check orientation to check worm position (this is needed to determine
        % which corner of the bounding box should be used as the endpoint) =
        % Positive or Negative orientation
        if bad_frame == true
            baseFileName_head = sprintf('BAD_head_%s', all_images(img_idx).name); % e.g. "1.png"
            baseFileName_tail = sprintf('BAD_tail_%s', all_images(img_idx).name); % e.g. "1.png"
            fullFileName_head = fullfile(cropped_folder,baseFileName_head);
            fullFileName_tail = fullfile(cropped_folder,baseFileName_tail);
            imwrite(zeros(31,31), fullFileName_head);
            imwrite(zeros(31,31), fullFileName_tail);
            continue
        end

        
        if stats.Orientation >=0
            PosOrient = true;
        else
            PosOrient = false;
        end

        % set head and tail based on previous frames
        if PosOrient
            extrema1 = stats.Extrema{1}(2,:);
            extrema2 = stats.Extrema{1}(6,:);
        else
            extrema1 = stats.Extrema{1}(1,:);
            extrema2 = stats.Extrema{1}(5,:);
        end

        % make the background white and implant the original worm pixels on
        % body
        img_final = double(ones(size(imgClosed)).*255);
        for row = 1:size(imgClosed,1)
            for col = 1:size(imgClosed,2)
                if imgClosed(row,col) % if the pixel at (row, col) is not zero
                    img_final(row,col) = img_gr(row,col);
                end
            end
        end
        img_final = uint8(img_final); % convert to integers


        % create the cropped images - make 31x 31 cropped images of endpts
        extrema1_crop = imcrop(img_final,[extrema1(1)-15 extrema1(2)-15 30 30]);
        extrema2_crop = imcrop(img_final,[extrema2(1)-15 extrema2(2)-15 30 30]);

        % find out which image belongs to head and tail, based on prev frame
        % this uses euclidean distance. Whichever point is closer to the
        % previous head becomes the head in the current frame. Same with tail.
        Ex1DistToHead = sqrt(sum((extrema1 - previous_head) .^ 2));
        Ex2DistToHead = sqrt(sum((extrema2 - previous_head) .^ 2));
        Ex1DistToTail = sqrt(sum((extrema1 - previous_tail) .^ 2));
        Ex2DistToTail = sqrt(sum((extrema2 - previous_tail) .^ 2));

        % name the output folders

        % save cropped images
        baseFileName_head = sprintf('GOOD_head_%s', all_images(img_idx).name); % e.g. "1.png"
        baseFileName_tail = sprintf('GOOD_tail_%s', all_images(img_idx).name); % e.g. "1.png"
        fullFileName_head = fullfile(cropped_folder,baseFileName_head);
        fullFileName_tail = fullfile(cropped_folder,baseFileName_tail);

        % write the correct image, based on the distance to prev head or tail
        if Ex1DistToHead < Ex2DistToHead
            imwrite(extrema1_crop, fullFileName_head);
            imwrite(extrema2_crop, fullFileName_tail);
            previous_head = extrema1;
            previous_tail = extrema2;
%             previous_centroid = stats.Centroid;
%             Camera_move = false;
            extrema1_head = true;
        else
            imwrite(extrema2_crop, fullFileName_head);
            imwrite(extrema1_crop, fullFileName_tail);
            previous_head = extrema2;
            previous_tail = extrema1;
%             previous_centroid = stats.Centroid;
%             Camera_move = false;
            extrema1_head = false;
        end
        bad_frame = false;
    end % you should have cropped images now
end

