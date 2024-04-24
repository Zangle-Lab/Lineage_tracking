function [B,M] = cell_filter(I,fudgeFactor)
%function to mask out cells

[~, threshold] = edge(I, 'sobel'); 
BWs = edge(I,'sobel', threshold * fudgeFactor);

%dilate the image
se90 = strel('line', 8, 90);
se0 = strel('line', 8, 0);
BWsdil = imdilate(BWs, [se90 se0]);

%fill gaps
BWdfill = imfill(BWsdil, 'holes');

%smooth image
seD = strel('diamond',2);
BWfinal = imerode(BWdfill,seD);
BWfinal = bwareaopen(BWfinal, 5); %remove regions smaller than 5 pixels
BWfinal = 1-BWfinal;

if sum(~isnan(BWfinal)) ~=0  
    I(~BWfinal) = 0; %0;
    B = I;
else
    B = I;
end

M = BWfinal; %return the mask used for processing