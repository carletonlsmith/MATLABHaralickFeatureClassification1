function [  ] = ForegroundBackgroundNorm( frame_folder_name, outputPath, base_frame_ranges ,foreground_ranges, background_ranges )
%ForegroundBackgroundNorm: Normalize foreground and background of all
%frames
%   frame_folder_path: the name of the folder containing the input frames
%   outpath: the path to save normalized frames
%   base_frame_ranges: 1x3 array; the ranges to be scaled into
%   foreground_ranges: 1x3 array; foreground min, max, and range
%   background_ranges: 1x3 array; background min, max, and range
    
    frame_folder_path = fullfile(frame_folder_name);

    % assign min, max, and range
    background_range = background_ranges(1,3);
    background_min = background_ranges(1,2);
    background_max = background_ranges(1,1);
    
    foreground_range = foreground_ranges(1,3);
    foreground_min = foreground_ranges(1,1);
    foreground_max = foreground_ranges(1,2);
    
    all_raw_frames = dir(frame_folder_path);
    for frame_idx = 3:size(all_raw_frames,1)
        frame_raw = imread(fullfile(strcat(frame_folder_path,'\',all_raw_frames(frame_idx).name)));
        frame_gr = rgb2gray(frame_raw); % make grayscale
        
        % the below function finds linear indices of the worm body
        [worm_px_idx,bad_frame] = FrameNormalization(frame_gr,base_frame_ranges);
        
        % initalize the frame normalized background and foreground
        frame_norm = zeros(size(frame_gr,1),size(frame_gr,2));
        if bad_frame == true
            frame_min = min(min(frame_gr));
            frame_range = max(max(frame_gr))-frame_min;
            for row = 1:size(frame_gr,1)
                for col = 1:size(frame_gr,2)
                    frame_norm(row,col) = (((double(frame_gr(row,col))-double(frame_min))/double(frame_range))*base_frame_ranges(1,3))+ base_frame_ranges(1,1);
                end
            end
            frame_norm = uint8(frame_norm);
            outputBaseFileName = sprintf('Frame %4.4d.png', frame_idx-2);
            outputFullFileName = fullfile(outputPath, outputBaseFileName);
            imwrite(frame_norm, outputFullFileName, 'png'); % save the normalized frame
            continue
        end
        
        % if not a bad frame, normalize both the worm and the background
        frame_body_min = min(frame_gr(worm_px_idx));
        frame_body_range = max(frame_gr(worm_px_idx))-frame_body_min;
        
        % normalize the worm body
        for worm_px = 1:size(worm_px_idx,1)
           px_intensity = frame_gr(worm_px_idx(worm_px));
           frame_norm(worm_px_idx(worm_px)) = (((double(px_intensity)-double(frame_body_min))/double(frame_body_range))*foreground_ranges(1,3))+ foreground_ranges(1,1);
        end
        
        % find the background px in the frame
        background_pxIntLst = zeros((size(frame_gr,1)*size(frame_gr,2))-size(worm_px_idx,1),1);
        idx_cnt = 1;
        for worm_px = 1:(size(frame_gr,1)*size(frame_gr,2))
            if any(worm_px==worm_px_idx)
                continue
            else
                background_pxIntLst(idx_cnt,1) = frame_gr(worm_px);
                idx_cnt = idx_cnt+1;
            end
        end
        
        % get the background ranges for this particular frame
        background_frame_min = min(background_pxIntLst);
        background_frame_max = max(background_pxIntLst);
        background_frame_range = background_frame_max - background_frame_min;
        
        % normalize the worm background
        for worm_px = 1:(size(frame_gr,1)*size(frame_gr,2))
            if any(worm_px==worm_px_idx)
                continue
            else
                px_intensity = frame_gr(worm_px);
                frame_norm(worm_px) = (((double(px_intensity)-double(background_frame_min))/double(background_frame_range))*background_ranges(1,3))+ background_ranges(1,1);
            end
        end
        frame_norm = uint8(frame_norm);
        outputBaseFileName = sprintf('Frame %4.4d.png', frame_idx-2);
        outputFullFileName = fullfile(outputPath, outputBaseFileName);
        imwrite(frame_norm, outputFullFileName, 'png');
    end
       
end
    
    
   

