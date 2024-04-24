function [B,M] = imagebackground_poly4(I,fudgeFactor)
%function [B] = imagebackground_poly4(I)
%function to find the background of an image, I, using a 4th order
%polynomial fit to the background pixels
%input: I, the grayscale image to find the background of
%output: B, the background of I
%method: find 'objects' in I, mask them from the image, fit the remainder
%to a 4th order polynomial surface

%detect entire cell
[junk, threshold] = edge(I, 'sobel');
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
BWfinal = bwareaopen(BWfinal, 10); %remove regions smaller than 10 pixels

figure(100)
imshow(BWfinal);


IList = I(~BWfinal);
sz = size(I);
[X,Y] = meshgrid(1:sz(2), 1:sz(1));
XList = X(~BWfinal);
YList = Y(~BWfinal);

if sum(~isnan(BWfinal)) ~=0
    CFit = polyfitn([XList YList], IList, 4);
    B =(reshape(polyvaln(CFit, [X(:), Y(:)]), sz(1), sz(2)));
else
    B = I;
end

M = ~BWfinal; %return the mask used for processing
