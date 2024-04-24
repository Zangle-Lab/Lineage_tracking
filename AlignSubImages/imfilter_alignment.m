 function BW2 = imfilter_alignment(I,T)
% This is the image filter for align the microwell-cell images
% The filter filters out the microwells for findng the accurate dislacement.
% Input I is the raw tiff image, T is the filtering threshold.

M = 0.09;

while M > 0.075
    T = T -0.0001;

    C1 = imresize(I, 1/4);
    C2 = imresize(C1, 4);

    C3 = imbinarize(C2,T);
    BW = logical(1-C3);

    BW2 = bwareafilt(BW,36);

    M = mean2(BW2);
end

