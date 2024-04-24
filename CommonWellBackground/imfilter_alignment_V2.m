function [M] = imfilter_alignment_V2(I,fudgeFactor)
%function to provide mask for alignment of microwells
[~, threshold] = edge(I, 'roberts');
BWs = edge(I,'sobel', threshold * fudgeFactor);


BWfinal = bwareaopen(BWs, 50); %remove regions smaller than 50 pixels


M = ~BWfinal; %return the mask used for processing