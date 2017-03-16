function [ GLCM ] = CustomGLCM(img,CCcoordinates,Img_sz,Displacement,Angle)
%CustomGLCM Generates GLCM matrix using only coordinates of CC
%   img: the gray level image
%   CCcoordinates: the linear indices of the worm pixels in the image
%   Img_sz: 2D array denoting the dimensions of the input image EX: [x y] 
%   Displacement: int; the displacement distance
%   Angle: int; the direction to generate the glcm


% Displacement = 1;
% Angle = 0;
% CCcoordinates = imgCC.PixelIdxList{1};
% Img_sz = [31 31];

[i,j] = ind2sub(Img_sz,CCcoordinates); % find worm pixel idx

% create a matrix consisting of i,j and their index number
px_indices_mat = zeros(size(i,1),3);
for px_idx = 1:size(i,1)
    px_indices_mat(px_idx,1) = px_idx;
    px_indices_mat(px_idx,2) = i(px_idx);
    px_indices_mat(px_idx,3) = j(px_idx);
end

% initialize GLCM
GLCM = zeros(8,8);

% if Angle = 0
if Angle == 0
    for row = 1:size(img,1) % for row in range, based on displacement
        for col = 1:size(img,2)-Displacement % for col in range, based on displacement
            for px_idx = 1:size(px_indices_mat,1) % iterate through worm pixels in image
                if row == i(px_idx) && col == j(px_idx) % check if the index of img pixel on worm body
                    adjusted_px_int1 = floor(double(img(row,col))/32.0)+1; % intensity value of first pixel
                    adjusted_px_int2 = floor(double(img(row,col+Displacement))/32.0)+1; % intensity value of second pixel
                    GLCM(adjusted_px_int1,adjusted_px_int2) = GLCM(adjusted_px_int1,adjusted_px_int2) + 1; % add count to GLCM mat
                end
            end
        end
    end
    
elseif Angle == 45 % if Angle = 45
    for row = 1+Displacement:size(img,1) % for row in range, based on displacement
        for col = 1:size(img,2)-Displacement % for col in range, based on displacement
            for px_idx = 1:size(px_indices_mat,1) % iterate through worm pixels in image
                if row == i(px_idx) && col == j(px_idx) % check if the index of img pixel on worm body
                    adjusted_px_int1 = floor(double(img(row,col))/32.0)+1; % intensity value of first pixel
                    adjusted_px_int2 = floor(double(img(row-Displacement,col+Displacement))/32.0)+1; % intensity value of second pixel
                    GLCM(adjusted_px_int1,adjusted_px_int2) = GLCM(adjusted_px_int1,adjusted_px_int2) + 1; % add count to GLCM mat
                end
            end
        end
    end

elseif Angle == 90 % if Angle = 90
    for row = 1+Displacement:size(img,1)
        for col = 1:size(img,2)
            for px_idx = 1:size(px_indices_mat,1)
                if row == i(px_idx) && col == j(px_idx)
                    adjusted_px_int1 = floor(double(img(row,col))/32.0)+1;
                    adjusted_px_int2 = floor(double(img(row-Displacement,col))/32.0)+1;
                    GLCM(adjusted_px_int1,adjusted_px_int2) = GLCM(adjusted_px_int1,adjusted_px_int2) + 1; % add count to GLCM mat
                end
            end
        end
    end

else % if Angle = 135
    for row = 1+Displacement:size(img,1)
        for col = 1+Displacement:size(img,2)
            for px_idx = 1:size(px_indices_mat,1)
                if row == i(px_idx) && col == j(px_idx)
                    adjusted_px_int1 = floor(double(img(row,col))/32.0)+1;
                    adjusted_px_int2 = floor(double(img(row-Displacement,col-Displacement))/32.0)+1;
                    GLCM(adjusted_px_int1,adjusted_px_int2) = GLCM(adjusted_px_int1,adjusted_px_int2) + 1; % add count to GLCM mat

                end
            end
        end
    end
end




end


