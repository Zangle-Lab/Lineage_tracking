clc; clear; close all;

num_loc = 19; %number of locations
num_frame_2 = 2881;%2881; %number of frames

fdir = 'XX';
load([fdir, 'dividing_well_list.mat'])

%%
for oo = 1:num_loc

    num_well = length(L_{oo});

    for o = 1:num_well
        kk = L_{oo}(o);

        froot = [fdir, '\aligned_images\cropped_images\'];
        filename3 = sprintf('Loc_%d_well_%d_data_allframes.mat',oo,kk);
        load([froot, filename3]);

        Mt = zeros(1,numf);

        for aa = 1:length(tracks(:,1))
            bb = find(time == tracks(aa,4));
            mmt = tracks(aa,3);
            Mt(bb) = Mt(bb)+mmt;
        end

        figure(1)
        Mt2 = medfilt1(Mt,30);
        time2 = time(1:length(Mt2));
        if (oo == 10 && kk == 21)  || (oo == 4 && kk == 26)
            Colorplot = [1 0.2 0.2];
        else
            Colorplot = [0.5 0.5 0.5];
        end
        plot (time2,Mt2,'.-','Color', Colorplot)
        ylabel('Mass (pg)', 'FontSize', 20)
        xlabel('time (h)', 'FontSize', 20)
        text(time2(end),Mt2(end), sprintf('L%dW%d',oo,kk), 'FontSize', 5);
        ylim([0 2500])
        box off
        hold on

        figure(2) % Pin to the first division time
        fdt = find(time <= D_{oo}(o), 1, 'last' );
        Mt2 = medfilt1(Mt,10);
        time2 = time(1:length(Mt2));
        time2 = time2-time2(fdt);
        plot (time2,Mt2,'.-')
        xline(0)
        ylabel('Mass (pg)', 'FontSize', 20)
        xlabel('time (h)', 'FontSize', 20)
        text(time2(end),Mt2(end), sprintf('L%dW%d',oo,kk), 'FontSize', 5);
        box off
        hold on
    end
end
 