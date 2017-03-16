function [ IdxMapper ] = MapRecordsToImages( bad_frame_arr,img_data,images_structure )
%MapRecordsToImages: This function maps the rows of the data set to the
%original index numbers of the image frames in the folder
%   bad_frame_arr: array of the indices from the data set that were erased
%   img_data: the data set
%   images_structure: a cell structure with the names of the images
%OUTPUT:
%   IdxMapper: a dictionary with the data set row as key and image frame
%   idx as the value
    keySet = [];
    valueSet = [];
    %OrigDataSet = zeros(size(images_structure,1),size(img_data,2));
    for head_newsDS_idx = 1:size(img_data,1)
        if sum(images_structure(head_newsDS_idx).name(1,1:3) == 'BAD')==3
            error('Only "GOOD" images should be contained in img structure, remove the "BAD" crops.')
        else
            keySet = [keySet head_newsDS_idx];
            valueSet = [valueSet str2double(images_structure(head_newsDS_idx).name(1,16:20))];
        end
    end
    
    
    IdxMapper = containers.Map(keySet,valueSet);
    
    %% This is old method - disregard
%     for head_newsDS_idx = 1:size(images_structure,1)
%         if any(head_newsDS_idx == bad_frame_arr || sum(images_structure(head_newsDS_idx).name(1,1:3) == 'BAD')==3)
%             OrigDataSet(head_newsDS_idx,:) = 0;
%             counter = counter + 1;
%             keySet = [keySet head_newsDS_idx];
%             valueSet = [valueSet head_newsDS_idx+counter];
%         else
%             OrigDataSet(head_newsDS_idx,:) = img_data(head_newsDS_idx-counter,:);
%             keySet = [keySet head_newsDS_idx];
%             valueSet = [valueSet head_newsDS_idx+counter];
%         end
%     end

end

