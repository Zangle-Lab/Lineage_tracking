clc; clear;close all;

%% Ths section is for number of space and time units.
num_loc = 1; %number of locations
num_frame = 678;%2881;%1100;%2881; %number of frames

fdir = 'XX'; %define main directory with files

%% This section is for reading time, only need to loop once for each experiment.
time = zeros (num_frame,1);

for mm  = 1:num_loc
    t = 0; % start time, hr
    filename1 = sprintf ('QPM20X_%d_frame_1.tif',mm);
    fname_1 = strtrim([fdir filename1]);
    if exist(fname_1) %if TIF files are present, use them to directly read imaging times
      time_0 = LoadTime(fname_1);
      for nn = 1:num_frame
          filename2 = sprintf ('QPM20X_%d_frame_%d.tif',mm,nn); % load the tiff images
          fname_2 = strtrim([fdir filename2]);
          timen = LoadTime(fname_2);
          time(nn) = (datenum(timen)-datenum(time_0)).*24; %store time in hours
      end
    else
      dt = 2.5/60; %time between frames
      time = (0:numloc).*dt;
    end
end
%% Big loop starts to loop over all locations and wells
load([fdir, 'good_well_list.mat'])

for oo = 1:num_loc

    well_file = eval(sprintf ('L_%d',oo));
    num_well = length(well_file);

    for o = 1:num_well

        kk = well_file(o);


        dir1 = sprintf('%s%d%s',fdir, 'cropped_images\loc_',oo,'\');
        dir2 = sprintf('%s%d%s','well_',kk,'\');

        froot = [dir1 dir2];
        fstart = 'QPM20X_';

        tracking_function(froot, fstart, num_frame, time, oo, kk)
    end
end
