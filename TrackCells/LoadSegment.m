function [ D, L, B ] = LoadSegment( fname, wavelength )
%function to load and segment the data stored in fname
%phase data should be stored in fname.Phase

Loaded = load(fname);
D = Loaded.Abkg.*wavelength;

L = imagesegment_aggressive(D);%segment image (detect distinct cell regions and disconnect connected regions)

end

