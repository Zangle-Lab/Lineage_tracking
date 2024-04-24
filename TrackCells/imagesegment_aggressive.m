function [L2,BWdfill] = imagesegment_aggressive(I)
%function to segment images
%first detect cell regions
%then segment using a watershed transform

BWs = I>50;

BWs = bwareaopen(BWs, 50, 4); %remove regions smaller than 50 pixels

se90 = strel('line', 10, 90);
se0 = strel('line', 10, 0);

BWsdil = imdilate(BWs, [se90 se0]);

%fill gaps
BWdfill = imfill(BWsdil, 'holes');

%to segment connected cells, follow this page:
%http://blogs.mathworks.com/steve/2006/06/02/cell-segmentation/
%new make a mask for the watershed transform
Igr = mat2gray(I);
Igr = imfilter(Igr, fspecial('gaussian', [5 5], 10));
Igr_2 = imfilter(Igr, fspecial('gaussian', [3 3], 0.5));

thr = 0.05;

mask_em = imextendedmax(Igr, thr);

se_1 = strel('disk',1);

mask_em = imdilate(mask_em, se_1, 1); %4

%complement the image so that the peaks become valleys
I_c = imcomplement(Igr_2);

%modify the image so that the background pixels and the extended
%maxima pixels are forced to be the only local minima in the image.
I_mod = imimposemin(I_c,  mask_em);
I_mod(~BWs) = 0;

%now, compute watershed transform
L = watershed(I_mod,8);
bw3 = BWs;
bw3(L==0) = 0;
bw4 = bwareaopen(bw3, 5);

L2 = bwlabel(bw4);

se_2 = strel('disk',3);

BW = L2>0;
Wdil = imdilate(L2, se_2);
L2(~BW)= Wdil(~BW);
