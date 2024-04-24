%% This matlab function plot the tracking results for better visualization

clc; clear; close all;


num_loc = 1; %number of locations
num_frame_2 = 678; %number of frames

fdir = 'XX'; %set file directory

load([fdir, 'dividing_well_list.mat'])

for oo = 1:1

    num_well = length(L_{oo});


    mkdir (sprintf('%s%d%s',fdir, 'loc_',oo,'\'));

    for o = 1:1

        dir1 = sprintf('%s%d%s',fdir, 'loc_',oo,'\');
        dir2 = sprintf('%s%d%s','well_',L_{oo}(o),'\');
        mkdir ([dir1 dir2]);
        savefdir = [dir1 dir2];

        kk = L_{oo}(o);

        dir1 = sprintf('%s%d%s',fdir, 'loc_',oo,'\');
        dir2 = sprintf('%s%d%s','well_',kk,'\');

        froot_3 = [dir1 dir2];

        froot_2 = 'L:\Jingzhou\060520_70Z3\mass_track_data\';


        filename1 = sprintf ('Loc_%d_well_%d_data_allframes.mat',oo,kk);
        filename2 = sprintf ('Loc_%d_well_%d_data1.mat',oo,kk);

        load([froot_2, filename1]);
        load([froot_2, filename2]);

        t = 0; % start time, hr
        for nn = 1:num_frame_2
            figure(1);


            fdir=   froot_3;
            filename = sprintf('QPM20X_%d_frame_%d.mat',oo,nn);

            load ([fdir filename]);

            imagesc(Abkg.*3.4611);
            caxis([0,3])
            %-------------Color bar----------------------------------------------
            h = colorbar;
            set(h,'Ytick',-1:1:4,'FontSize',25);
            h.Label.String = 'Dry mass, pg/\mum^2';
            set(h,'FontSize',25);
            %----------------------------------------------------------------------

            hold on
            slice = tracks(any(tracks(:,4)==t_stored(nn),2),:);

            plot (slice(:,1),slice(:,2),'k.','MarkerSize',10)
            text (slice(:,1)+0.5,slice(:,2),num2str(slice(:,5)), 'Color', [0 0 0],'fontsize', 25 )

            T = sprintf('%.1f',time(nn)*60);
            xlabel([num2str(T),'min'],'FontSize',25)

            hold on

            plotBWoutlines_2(L_stored(:,:,nn))

            hold off

            axis equal
            axis tight
            set(gca,'xtick',[])
            set(gca,'xticklabel',[])
            set(gca,'ytick',[])
            set(gca,'yticklabel',[])


            savefilename = sprintf('QPM20X_%d_frame_%d.jpg',oo,nn);
            file = ([savefdir savefilename]);
            saveas(gcf,file)
        end
    end
end