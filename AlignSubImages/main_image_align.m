clc;clear;close all;

fdir = 'G:\Data\Jingzhou\slpeen_imaging\020720_run1\';
numw = 15; % number of wells
numf = 2148; % number of frames in each well
load([fdir, 'avg_well\avg_well1.mat']);
R0 = Abkg;

R1 = imread([fdir, 'avg_well\avg_well1.tif']);

% for solving connecting edge issues
R1cc = 1000;
R1(1:10,:)=R1cc;
R1(2046:2056,:)=R1cc;
R1(:,1:10)=R1cc;
R1(:,2046:2056)=R1cc; 

C2 = imfilter_alignment(R1,0.015);

for ii = 1:numw
    xft = zeros(1,numf);
    yft = zeros(1,numf);
    f = zeros(1,numf);
    for jj = 1:numf
        filename = sprintf('QPM20X_%d_frame_%d.mat',ii,jj);

        load ([fdir filename]);

        Ri = Phase;

        filename2 = sprintf('QPM20X_%d_frame_%d.tif',ii,jj);

        Ri1 = imread([fdir filename2]);

        Ci2 = imfilter_alignment(Ri1,0.008);

        [yshift, xshift] = CorrShift1(C2,Ci2);

        xft(jj) = xshift;
        yft(jj) = yshift;
        f(jj) = jj;

        if abs(yshift)>50
            yshift = 0;
        else
            yshift;
        end

        if abs(xshift)>50
            xshift = 0;
        else
            xshift;
        end

        T = maketform('affine', [1 0 0; 0 1 0; (-xshift)/4 (-yshift)/4 1]);
        Fi = imtransform(Ri, T, 'XData',[1 size(Ri,2)], 'YData',[1 size(Ri,1)]);
        Phase = (Fi +R0);

        [B,M]=imagebackground_poly4(Phase,2.2);

        savefdir=sprintf('%s%d%s',fdir, 'aligned_images\cell_seg\well_',ii,'\');
        mkdir(savefdir);
        savefilename = sprintf('QPM20X_%d_frame_%d.jpg',ii,jj);
        file = ([savefdir savefilename]);

        Abkg=B-Phase;
        Abkg(Abkg<0)=0;

        mkdir (sprintf('%s%d%s','G:\Data\Jingzhou\slpeen_imaging\020720_run1\aligned_images\well_',ii,'\'));
        save_fdir=sprintf('%s%d%s','G:\Data\Jingzhou\slpeen_imaging\020720_run1\aligned_images\well_',ii,'\');
        save([save_fdir filename],'Abkg')
    end

end