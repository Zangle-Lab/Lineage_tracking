% This script aligns the images and takes the average to find the average well background
clc;clear;close all;

CFT = 2.2; % cell filter threshold
IAT = 0.8; % imfilter_allignment threshold
fdir = 'G:\Data\Jingzhou\spleen_imaging\020720_run1\';

load([fdir, 'first_frames\QPM20X_4_frame_1.mat']);
S1 = Abkg;

numf = 19;

[B1,M1] = cell_filter(S1,CFT);
C2 = imfilter_alignment_V2(S1,IAT);

%initialize variables
ys = zeros(numf);
xs = zeros(numf);
sumM = single(zeros(size(M1)));
sum = single(zeros(size(B1)));

for ii = 1:numf
    filename = sprintf('QPM20X_%d_frame_1.mat',ii);
    load([fdir, 'first_frames\', filename]);

    Si = Abkg;

    [Bi,Mi] = cell_filter(Si,CFT);

    Mii = single(Mi);
    sumM = imadd(sumM,Mii);

    Cmi2 = imfilter_alignment_V2(Si, IAT);

    [yshift, xshift] = CorrShift1(C2, Cmi2);

    filename2 = sprintf ('QPM40X_%d_frame_1.tif',ii);
    Ri = imread ([fdir filename2]);

    T = maketform('affine', [1 0 0; 0 1 0; (-xshift) (-yshift) 1]);
    T2 = maketform('affine', [1 0 0; 0 1 0; (-xshift) (-yshift) 1]);

    Fi = imtransform(Bi, T, 'XData',[1 size(Bi,2)], 'YData',[1 size(Bi,1)]);
    Hi = imtransform(Ri, T2, 'XData',[1 size(Ri,2)], 'YData',[1 size(Ri,1)]);

    sum = imadd(sum,Fi);
    sum2 = imadd(sum2,Hi./numf);
end

Abkg = imdivide(sum,sumM);
filename = 'avg_well1';
save_fdir=[fdir, 'avg_well\'];
save([save_fdir filename],'Phase','Abkg')

imwrite(sum2,'G:\Data\Jingzhou\70Z3_microwells_imaging\110519_run1\avg_well\avg_well1.tif')