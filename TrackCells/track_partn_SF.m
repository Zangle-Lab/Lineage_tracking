function [x,y,z,t,MI,SF] = track_partn_SF(tracks, n)
%function [x,y,z,t] = track_partn(tracks, n)
%returns the coordinates and times for particle n in the tracks array
%generated by the track.m function
%inputs: tracks, array containing x, y, z, t, i (locations x, y, third
%coordinate z, and time coordinate, t for i particles); n, particle number
%to return
%outputs: x, y, z, t: coordinates of particle n
%TAZ 4/27/10
%SF also returns the shape factor and mean intensity (or area) stored in
%columns 7 and 6, respectively

if n > max(tracks(:,5))
    disp('invalid particle number')
    x = [];
    y = [];
    z = [];
    t = [];
    MI = [];
    SF = [];
else
    x = tracks(tracks(:,5) == n, 1);
    y = tracks(tracks(:,5) == n, 2);
    z = tracks(tracks(:,5) == n, 3);
    t = tracks(tracks(:,5) == n, 4);
    MI = tracks(tracks(:,5) == n, 6);
    SF = tracks(tracks(:,5) == n, 7);
end