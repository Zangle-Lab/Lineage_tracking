function [] = tracking_function(froot, fstart, num_frame, time, oo, kk)
%function to run cell tracking code
%first section: define image processing parameters (file locations,
%processing options, etc.)
%second section: load images and detect cells
%third section: track cells

%% This section is for some basic parameters
wavelength = 623; %nm
pxlsize = 1.19e-3; %mm/pixel

overwrite = 1; %set to 1 to enable overwrite of pre-stored data files
savefolder = froot;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Define image analysis parameters

%%% define min and max area and mean intensity (MI) thresholds
%%% only objects which fall between these values will be counted as "cells"
%%% These parameters should be adjusted for each sample to capture the
%%% objects of interest. See Figure 11 to evaluate where these values fall
%%% relative to the properties of the image. See figures 12 and 13 to see
%%% which objects in the first and last frames are counted as "cells"
minAreathresh = 50;
maxAreathresh = 500;
minMIthresh = 50;
maxMIthresh = 500;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Define tracking software parameters

minpathlength = 10; %min path length to use in plotting results. only paths
%                    of this length or longer will be displayed. this does
%                    not affect the tracking software (tracks shorter than
%                    minpathlength will still be computed and stored)


massfact = 0.35; %factor to multiply mass by in tracking step. use this to  
%account for differences in how much the cell moves vs. how
%much mass changes over time

%%% tracking parameters below affect the tracking software itself
max_disp = 6;  %max displacement for particle tracking 
%               max_disp is an estimate of the maximum distance that a
%               particle would move in a single time interval. It should be
%               set to a value somewhat less than the mean spacing between
%               the particles
param.mem = 5; %this is the number of time steps that a particle can be
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

%% define which files the function will work on
fext = '.mat'; %file extension

[LocList, numLoc] = getloclist(froot, fstart, fext);

%pre-processing and variable initialization before loop begins:
Loc = 1;
filelist = dir([froot, 'QPM20X_', char(LocList(Loc)), '_*', fext]);
fileNames = char(sort_nat({filelist.name}'));

%% loop over all locations
for Loc = 1:numLoc
    if ~exist([savefolder, 'Tdata', num2str(Loc), '.mat']) || overwrite
        filelist = dir([froot, 'QPM20X_', char(LocList(Loc)), '_*', fext]);
        fileNames = char(sort_nat({filelist.name}'));
        numf = length(fileNames(:,1));
        numf = min([length(fileNames(:,1)), num_frame]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% grab first frame for analysis and detection of the correct cell
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fname = strtrim([froot, fileNames(1,:)]);
        
        [D1,L1] = LoadSegment(fname, wavelength);
        D1s = zeros([size(D1),numLoc], 'single');
        
        
        %preallocate variables for speed
        yshift_store = zeros(numf);
        xshift_store = zeros(numf);
        t_stored = zeros(numf);
        
        D_stored = zeros([size(D1),numf], 'single');
        L_stored = zeros([size(D1),numf], 'uint16');
        
        
        D1s(:,:,Loc) = single(D1);
        
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% loop through first numf file names stored in fnum and store analysis results
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        tt = 1; %initialize tt, the index of the tracking array
        T_array = [];
        
        xshift_old = 0;
        yshift_old = 0;
        D_old = D1;
        
        for jj = 1:numf
            
            fname = strtrim([froot, fileNames(jj,:)]);
            disp(fname)
            
            [D, L] = LoadSegment(fname, wavelength);
            
            [V, M, A, MI, P, SF] = imageprops_SF(L, D, pxlsize); %compute image properties based on the regions stored in L
            if std(D(:))~=0 %skip if blank image
               
                xshift = 0;
                yshift = 0;

                D_old = D;
                xshift_old = xshift;
                yshift_old = yshift;
                
                yshift_store(jj,Loc) = yshift;
                xshift_store(jj,Loc) = xshift;
                D_stored(:,:,jj) = single(D(:,:));
                L_stored(:,:,jj) = uint16(L(:,:));
                t_stored(jj,Loc) = time(jj);
                
                %next, loop through all items identified in V and find only the ones
                %which meet area and mean intensity requirements
                for ii = 1:length(V)
                    %first, check that 1) there is something at index ii, 2) that
                    if(~isnan(P(ii).Centroid(1)) && A(ii) > minAreathresh && A(ii) < maxAreathresh && MI(ii) > minMIthresh && MI(ii) < maxMIthresh)
                        T_array(tt,1:2) = P(ii).Centroid; %store position in first two columns of T_array
                        T_array(tt,1:2) = T_array(tt,1:2) - [xshift, yshift]; %remove shift due to movement of the entire frame
                        T_array(tt,3)   = M(ii);          %store mass in third column
                        T_array(tt,4)   = time(jj);           %store time from first frame in seconds in 4th column
                        T_array(tt,5)   = A(ii); %store area in fifth column
                        T_array(tt,6)   = SF(ii); %store shape factor in sixth column
                        tt = tt+1;                        %increment T_array index
                    end
                end
            end
        end
        
        if ~isempty(T_array) && sum(T_array(:,4) ~= T_array(1,4))>0
            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Cell tracking using the track function
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %T_array starts as [x, y, m, t, A, SF]
            T_array(:,3) = T_array(:,3).*massfact; %change mass weighting in T_array
            T_array = sortrows(T_array, 4); %sort T_array based on time vectors
            minTx =  min(T_array(:,1));
            T_array(:,1) = T_array(:,1) -minTx +1; %make sure all x positions are positive\
            minTy =  min(T_array(:,2));
            T_array(:,2) = T_array(:,2) -minTy +1; %make sure all y positions are positive, new with rev6
            %move time to last column, T_array will now be [x, y, m, A, SF, t]
            T_array_temp = [T_array(:,1:3), T_array(:,5:6), T_array(:,4)];
            
            tracks = track(T_array_temp,max_disp,param);
            
            %move area back to 5th column, T_array will now be [x, y, m, t, A, SF] and
            %tracks will now be [x, y, m, t, cellnum, A, SF]
            tracks_temp = [tracks(:,1:3), tracks(:,6:7), tracks(:,4:5)];
            tracks = tracks_temp;
            
            T_array(:,3) = T_array(:,3)./massfact; %adjust mass weighting back to the way it was
            T_array(:,1) = T_array(:,1) + minTx -1; %set all x positions back to the way they were
            T_array(:,1) = T_array(:,2) + minTy -1; %set all y positions back to the way they were
            tracks(:,3) = tracks(:,3)./massfact; %adjust for mass weighting in the tracks array as well
            tracks(:,1) = tracks(:,1) +minTx -1; %set all x positions back to the way they were
            tracks(:,2) = tracks(:,2) +minTy -1; %set all y positions back to the way they were
        else
            tracks = [];
        end
        
        %save D_stored and L_stored in a separate .mat file to save memory
        parsave([savefolder 'data', num2str(Loc), '.mat'], D_stored, 'D_stored', 0)
        parsave([savefolder 'data', num2str(Loc), '.mat'], L_stored, 'L_stored', 1)
        
        %save tracks data
        parsave([savefolder 'Tdata', num2str(Loc), '.mat'], tracks, 'tracks', 0)
        parsave([savefolder 'Tdata', num2str(Loc), '.mat'], T_array, 'T_array', 1)
        parsave([savefolder 'Tdata', num2str(Loc), '.mat'], xshift_store, 'xshift_store', 1)
        parsave([savefolder 'Tdata', num2str(Loc), '.mat'], yshift_store, 'yshift_store', 1)
        parsave([savefolder 'Tdata', num2str(Loc), '.mat'], t_stored, 't_stored', 1)
        
    end %close if statement looking for stored data
end %close rows for loop

clear tracks T_array xshift_store yshift_store t_stored D_stored L_stored T_array_temp tracks_temp

%%
%reconstitute tracks vector
tracks_comp = [];
xshift_store_c = [];
yshift_store_c = [];
t_stored_c = [];
ii_stored = [];
maxindex = 0;
Loc_stored_c = [];
for Loc = 1:numLoc
    
    load([savefolder 'Tdata', num2str(Loc), '.mat']);
    if ~isempty(tracks)
        tracks(:,5) = tracks(:,5)+maxindex;
    end
    
    tracks_comp = [tracks_comp; tracks];
    xshift_store_c = [xshift_store_c; xshift_store(:,Loc)];
    yshift_store_c = [yshift_store_c; yshift_store(:,Loc)];
    t_stored_c = [t_stored_c; t_stored(:,Loc)];
    ii_stored = [ii_stored, 1:length(t_stored(:,Loc))'];
    Loc_stored_c = [Loc_stored_c, (1:length(t_stored(:,Loc))').*0 + Loc];
    
    if ~isempty(tracks_comp)
        maxindex = max(tracks_comp(:,5));
    end
    
    clear tracks xshift_store yshift_store t_stored
    
end

Loc_stored = Loc_stored_c;
tracks = tracks_comp;
xshift_store = xshift_store_c;
yshift_store= yshift_store_c;
t_stored = t_stored_c;
ii_stored = ii_stored';
clear tracks_comp xshift_store_c yshift_store_c t_stored_c maxindex Loc_stored_c

T0=min(tracks(:,4)); %find time of first image in the set
tracks(:,4) = (tracks(:,4)-T0);
t_stored = t_stored - T0;

%%
figure 
[num, indices] = track_numpart(tracks,minpathlength); %find tracks >= minpathlength

%plot tracks of mass over time
for ii = 1:num
    currentnum = tracks(indices(ii),5);
    [x,y,z,t] = track_partn_SF(tracks,currentnum);
    plot(t, z, '.-')
    hold on

end
hold off 

ylabel('Mass (pg)', 'FontSize', 14)
xlabel('time (h)', 'FontSize', 14)
set(gca, 'FontSize', 14)

title('Cell Mass track ', 'FontSize', 10)

savefilename = sprintf('Mass_track_loc_%d_well_%d.fig',oo,kk);
file = ([savefolder savefilename]);
saveas(gcf,file)

%%
%save data
if ~exist([savefolder 'data_allframes']) || overwrite
    save([savefolder 'data_allframes'])
end

