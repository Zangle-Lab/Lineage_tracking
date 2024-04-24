% this code read the tracks array data, reads the first and the last time
% point of each cell track, run through the track function again for
% reconnection.
clc; clear; close all;
fdir = 'XX'; %define file directoy
load([fdir, 'data_allframes.mat'])

minpathlength = 1; %min path length to use in plotting results. only paths
%                    of this length or longer will be displayed. this does
%                    not affect the tracking software (tracks shorter than
%                    minpathlength will still be computed and stored)

max_disp = 20; %max displacement for particle tracking
%               max_disp is an estimate of the maximum distance that a
%               particle would move in a single time interval. It should be
%               set to a value somewhat less than the mean spacing between
%               the particles

param.mem = 0; %this is the number of time steps that a particle can be
%               'lost' and then recovered again.  If the particle reappears
%               after this number of frames has elapsed, it will be
%               tracked as a new particle. The default setting is zero.
%               this is useful if particles occasionally 'drop out' of
%               the data.
param.dim = 3; %number of dimensions of coordinate data to track. If you
%               set this value to 2, then it will track based on position
%               in x and y. If param.dim = 3, then the software will track
%               based on mass as well.
param.good = 0; %set this keyword to eliminate all trajectories with
%                fewer than param.good valid positions.  This is useful
%                for eliminating very short, mostly 'lost' trajectories
%                due to blinking 'noise' particles in the data stream.
param.quiet = 1; %set this keyword to 1 if you don't want any text
%                 displayed while the tracking algorithm is running

co_num = 5; % reconnection iteration number

tracks_orig = tracks;
aa = 1;

while aa < co_num
    T_array_temp_2 = [T_array(:,1:3), T_array(:,5:6), T_array(:,4)];

    [num, indices] = track_numpart(tracks,2);%minpathlength);

    T_array_temp = zeros(num*2,6);

    num_2 = num;


    % Last Point connection
    for ii = 1:num
        currentnum = tracks(indices(ii),5);


        [x,y,z,t] = track_partn_SF(tracks,currentnum);

        T_array_temp(ii*2-1,1) = x(1);
        T_array_temp(ii*2,1) = x(end);

        T_array_temp(ii*2-1,2) = y(1);
        T_array_temp(ii*2,2) = y(end);

        T_array_temp(ii*2-1,3) = z(1);
        T_array_temp(ii*2,3) = z(end);

        T_array_temp(ii*2-1,6) = t(1);
        T_array_temp(ii*2,6) = t(end);

        T_array_temp(ii*2-1,4) = currentnum;
        T_array_temp(ii*2,4) = currentnum;

        T_array_temp(ii*2,5) = 1; % for marking the beginng and end of the
        % track, to get rid of the head connection later.

    end
    T_add = zeros(length(time),6);
    T_add(:,3) = 10;
    T_add(:,6) = time;

    T_array_temp = [T_array_temp; T_add];
    T_array_temp  = sortrows(T_array_temp,6);

    tracks_2 = track(T_array_temp,max_disp,param);

    tracks_temp = [tracks_2(:,1:3), tracks_2(:,6:7), tracks_2(:,4:5)];
    tracks_2 = tracks_temp;

    tracks_2 = tracks_2(tracks_2(:,3)>11,:);
    tracks_2  = sortrows(tracks_2,5);

    % Get rid of the connecting heads/tails

    [num, indices] = track_numpart(tracks_2,2); %find tracks >= minpathlength

    tracks_3 = tracks_2;
    for ii = 1:num
        %ii = 7;
        currentnum = tracks_2(indices(ii),5);
        HT = tracks_2(tracks_2(:,5) == currentnum, 7);

        num_HT = length(HT);
        for jj = 1:num_HT-1
            if HT(jj) == HT(jj+1)
                tracks_3(tracks_3(:,5) == currentnum, :) = [];
            end
        end

    end
    tracks_2 = tracks_3;

    % add two point connection back to tracks
    %to reconnect tracks
    %tracks_2 %this is your reconnected matrix (x, y, mass, t, newID, oldID, other)
    %tracks %this is your original matrix (x, y, mass, t, ID, other)
    tracks_fixed = tracks;
    [num, indices] = track_numpart(tracks_2,2); %find fixed tracks that link 2 paths
    %loop through all fixed tracks in tracks_2
    %for each one, we need to find the oldIDs to link,
    %find the ID of the first cell in the oldID list (because it may have been fixed in a previous loop)
    %then set the ID of the second cell equal to the ID of the first cell
    for ii = 1:num
        %get current newID
        currentnum = tracks_2(indices(ii),5);

        %get oldIDs to link. oldID(1) is first cell, oldID(end) is second cell
        oldIDs = tracks_2(tracks_2(:,5) == currentnum, 6);

        %get cell ID of the first cell from tracks_fixed. This will account for any previous renaming of this first cell
        fixedID = tracks_fixed(tracks(:,5)==oldIDs(1),5);

        %set ID of second cell in the list equal to ID of first cell in the list
        tracks_fixed(tracks_fixed(:,5) == oldIDs(end),5) = fixedID(1);
    end

    tracks_fixed  = sortrows(tracks_fixed,5);

    tracks = tracks_fixed;

    aa = aa + 1;
end

%%
%plot growth over time

figure
[num, indices] = track_numpart(tracks_fixed,minpathlength); %find tracks >= minpathlength

%plot those tracks
for ii = 1:num
    currentnum = tracks_fixed(indices(ii),5);
    [x,y,z,t] = track_partn_SF(tracks_fixed,currentnum);
    plot(t, z, '.-')
    hold on
end
hold off

ylabel('Mass (pg)', 'FontSize', 14)
xlabel('time (h)', 'FontSize', 14)
set(gca, 'FontSize', 14)

title('Cell Mass track ', 'FontSize', 10)