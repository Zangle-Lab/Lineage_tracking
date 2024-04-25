%script to find cell pairs and load them into CellObj structures
clc; clear; close all;

num_loc = 19; %number of locations
num_frame_2 = 2881; %number of frames

%%
%general settings
minpairpath =100; %min path length before looking for cells
deltat = 2.5; %time between frames (min)
founderthresh = 20; %only cells starting within these first frames will count as 'founders'
survivorthresh = 20; %only cells starting within these first frames will count as 'survivors'

%division detection settings
pairthresh= 20; %max difference in distance/mass for tracking daughter cells
pairmassthresh = 0.6; %total mass of daughter cells must be within this fraction of parent cell mass
pairgap = 100; %max number of frames to skip between mother and daughter cell

%death detection settings
DeathL = 500; %length of sigmoid filter used to detect cell death
DeathThresh = 20; %threshold value of sigmoid patter match filter as positive indication of death

load('G:\Data\Jingzhou\slpeen_imaging\020720_run1\dividing_well_list.mat')
for oo = 1:num_loc
    num_well = length(L_{oo});    
    for o = 1:num_well

        savefolder_2 = 'G:\Data\Jingzhou\slpeen_imaging\020720_run1\aligned_images\croped_images\gen_track_results\';

        kk = L_{oo}(o);

        froot_2 = 'G:\Data\Jingzhou\slpeen_imaging\020720_run1\aligned_images\croped_images\mass_track_data_2\';

        filename1 = sprintf ('Loc_%d_well_%d_data_allframes.mat',oo,kk);

        load([froot_2, filename1]);

        tlim = tracks(:,4) <= 2700/60;
        tracks = tracks(tlim,:);

        Treatment = 'Ctrl';
        col6 = 'Ar'; %whether column 6 in tracks array is mean intensity ('MI') or area ('Ar')

        %%
        %initialize variables
        totalt = 0; %total time (will be updated during tracking)
        CellPairs = PairObj;
        cumCellNum = 0; %cumulative cell number, used to reassign cells new numbers across all locations

        %first, make new cell object for each cell in the dataset
        for Loc = 1:numLoc
            if ~isempty(tracks)                
                [num, indices] = track_numpart(tracks,3); %find all tracks >= length 20

                for ii = 1:num
                    cumCellNum = cumCellNum+1;
                    currentnumP = tracks(indices(ii),5);

                    Cells(cumCellNum) = makeCellObj( currentnumP, cumCellNum, froot_2, Loc, col6, Treatment, oo, kk);
                    totalt = max([totalt, Cells(cumCellNum).time(end)]);
                    figure(2)
                    plot(Cells(cumCellNum));
                    hold on
                end
            end
        end
        hold off


        CellsOrig = Cells;

        %%
        %merge Cells
        max_disp2 = 20;
        massfact2 = 100;%100; %mass is scaled by mass of current cell, so max difference is
        maxdeltat = 40;%100;%40; %min, max difference between times
        Cells = FixCellObjTracks(CellsOrig, max_disp2, massfact2, maxdeltat);
        cumCellNum = length(Cells);
        %%
        %then check origin and fate of each cell
        numpairs = 0;
        numdead = 0;
        numfound = 0;
        numsurv = 0;
        for ii = 1:length(Cells)
            %first check if current cell is a founder cell
            if Cells(ii).time(1) < deltat*founderthresh %founder cell!
                numfound = numfound + 1;
                Cells(ii).Origin = 'f';
            end

            %then check if current cell is a parent cell
            if length(Cells(ii).x) > minpairpath
                daughtnums = [];
                x = Cells(ii).x;
                y = Cells(ii).y;
                z = Cells(ii).mass;
                t = Cells(ii).time;
                for jj = 1:length(Cells) %loop through all other possible cells
                    if Cells(jj).LocNum == Cells(ii).LocNum %only go further if cells were in the same imaging location
                        x2 = Cells(jj).x;
                        y2 = Cells(jj).y;
                        z2 = Cells(jj).mass;
                        t2 = Cells(jj).time;
                        if abs(t2(1) - t(end)) < (1.1 + pairgap)*deltat && length(x2) > minpairpath %only look at tracks which start at the right time and are the right length
                            if norm([x2(1)-x(end), y2(1)-y(end)]) < pairthresh && 2*(z2(1)-z(end)./2)./z(end) < pairmassthresh %its a daughter cell if it is within the threshold distance and mass of the parent cell
                                daughtnums = [daughtnums, jj]; %found a daughter!
                            end
                        end
                    end
                end
                if length(daughtnums)~=2 && ~isempty(daughtnums) %something went wrong
                    disp(['weird daughter cell event at cell ', num2str(ii), ' , ', num2str(length(daughtnums)), ' daughter(s) detected'])
                end

                %if more than 2 daughters detected, take two with min initial error
                if length(daughtnums) > 2
                    daughtscores = [];
                    for jj = 1:length(daughtnums)
                        daughtscores(jj) = norm([Cells(ii).x(end)-Cells(daughtnums(jj)).x(1),Cells(ii).y(end)-Cells(daughtnums(jj)).y(1),massfact.*(Cells(ii).mass(end)./2-Cells(daughtnums(jj)).mass(1))]);
                    end
                    [~,SortJJ] = sort(daughtscores);
                    daughtnums = [daughtnums(SortJJ(1)), daughtnums(SortJJ(2))];
                end

                if length(daughtnums) == 2 %found a good parent/daughter combo!
                    numpairs = numpairs + 1;

                    %fate/origin tagging
                    Cells(ii).Fate = 'p';
                    Cells(daughtnums(1)).Origin = 'd';
                    Cells(daughtnums(2)).Origin = 'd';

                    %link CellObjects;
                    Cells(ii).DaughtCells = daughtnums;
                    Cells(daughtnums(1)).ParentCell = ii;
                    Cells(daughtnums(2)).ParentCell = ii;

                end
            end

            %then check if current cell died
            if strcmp(Cells(ii).Fate, 'u') && length(Cells(ii).time) > DeathL
                if sigmoidfilt(Cells(ii).mass,-1,DeathL) > DeathThresh %dying cell!
                    numdead = numdead+1;
                    Cells(ii).Fate = 'x';
                end
            end

            %then check if current cell made it to the end
            if abs(Cells(ii).time(end) - totalt) < deltat*survivorthresh && strcmp(Cells(ii).Fate,'u') %survivor cell!
                numsurv = numsurv + 1;
                Cells(ii).Fate = 's';
            end
        end

        %%
        %check results
        numunknF = 0;
        numunknO = 0;

        for ii = 1:cumCellNum
            if strcmp(Cells(ii).Fate, 'u')
                numunknF = numunknF + 1;
            end

            if strcmp(Cells(ii).Origin, 'u')
                numunknF = numunknO + 1;
            end
        end

        %%
        %plot tree results
        treedat = [];
        fatedat = [];
        fatelabels = [];
        cellnumlabels = [];
        maxord = 0;
        for ii = 1:cumCellNum
            if strcmp(Cells(ii).Origin, 'f') || strcmp(Cells(ii).Origin, 'u')
                disp(['founder cell, ii ', num2str(ii)])
                [treedattemp, fatedattemp, fatelabelstemp, cellnumlabelstemp] = GenTrackTree(Cells, ii);
                treedattemp(1,:) = treedattemp(1,:) + maxord;
                fatedattemp(1,:) = fatedattemp(1,:) + maxord;
                maxord = max(treedattemp(1,:));
                treedat = [treedat, treedattemp];
                fatedat = [fatedat, fatedattemp];
                fatelabels = [fatelabels, fatelabelstemp];
                cellnumlabels = [cellnumlabels, cellnumlabelstemp];
            end
        end

        %%
        figure(1)
        plot(treedat(2,:), treedat(1,:), '.', 'MarkerSize', 8)
        hold on
        for ii = 1:length(fatelabels)
            plot(fatedat(2,ii), fatedat(1,ii), ['r' fatelabels(ii)], 'LineWidth', 2, 'MarkerSize', 15)
            text(fatedat(2,ii)+100, fatedat(1,ii), num2str(cellnumlabels(ii)),'FontSize',24)
        end
        hold off
        box off
        set(gca,'FontSize', 24)
        xlabel('time (min)')
        ylabel('track ID')


        savefigname_1 = sprintf('Loc_%d_well_%d_generation_track.fig',oo,kk);
        file_1 = ([savefolder_2 savefigname_1]);
        saveas(gcf,file_1)

        %%
        savefile_name = sprintf ('Loc_%d_well_%d_CellObjData.mat',oo,kk);
        save([savefolder_2, savefile_name], 'Cells')
    end
end