function [outputFolder] = VideoFrameExtractor( num_of_frames, name_of_vid, name_of_frameFolder )
% VideoFrameExtractor: Extracts frames from an avi video and saves to a
% folder named "Movie_Frames_from_[name_of_video]"
%   num_of_frames: int; how many frames to extract from video
%   name_of_vid: string; name of the video, must be same as how it's saved
%   name_of_frameFolder: string; name of output folder, must be created
%   before running function
    
    NumberOfFrames = num_of_frames;
    video_raw = VideoReader(name_of_vid);
    numberOfFrames=video_raw.NumberOfFrames;
    vidHeight = video_raw.Height;
    vidWidth = video_raw.Width;
    video_path = fullfile('D:\Carl\\Research\\',name_of_vid);
    frameFolder = fullfile('D:\Carl\\Research\\',name_of_frameFolder);
    fontSize = 12;

    numberOfFramesWritten = 0;
    % Prepare a figure to show the images in the upper half of the screen.
    figure;
    screenSize = get(0, 'ScreenSize');
    % Enlarge figure to full screen.
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

    [folder, baseFileName, extentions] = fileparts(video_path);
    % Make up a special new output subfolder for all the separate
    % movie frames that we're going to extract and save to disk.
    folder = pwd;   % Make it a subfolder of the folder where this m-file lives.
    outputFolder = sprintf('%s/Movie_Frames_From %s', folder, baseFileName);

    % this grabs the images from the video
    for frame = 1 : NumberOfFrames
        % Extract the frame from the movie structure.
        thisFrame = read(video_raw, frame);

        % Display it
        hImage = subplot(2, 2, 1);
        image(thisFrame)
        caption = sprintf('Frame %4d of %d.', frame, NumberOfFrames);
        title(caption, 'FontSize', fontSize);
        drawnow; % Force it to refresh the window.		
        % Write the image array to the output file, if requested.

        % Construct an output image file name.
        outputBaseFileName = sprintf('Frame %4.4d.png', frame);
        outputFullFileName = fullfile(outputFolder, outputBaseFileName);
        imwrite(thisFrame, outputFullFileName, 'png');
    end
    
end

