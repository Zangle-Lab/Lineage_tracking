function [treedat, fatedat, fatelabels, cellnumlabels] = GenTrackTree(Cells, foundernum)
%function [treedat, fatedat, fatelabels, cellnumlabels] = GenTrackTree(Cells, foundernum)
%function to traverse fate tree stored in the objects in Cells
%inputs:
%Cells - array of cell objects
%foundernum - the cell in Cells to start with
%outputs:
%treedat - data for tree plotting, treedat(1,:) is the number of the cell
%order within the tree, treedat(2,:) is the time. plot(treedat(2,:),treedat(1,:))
%will plot the basic tree
%fatedat - cell fate data (order, time)
%fatelabels - cell fate labels, plot(fatedat(2,:),fatedat(1,:),fatelabels)
%will plot the fates onto the basic tree
%cellnumlabels can be used to plot cell numbers on the tree

stack = foundernum;
currL = 0; %current order label

treetimes = [];
treeord = [];
fatetimes = [];
fateord = [];
fatelabels = [];
cellnumlabels = [];

while ~isempty(stack)
    %pop the stack
    currnum = stack(end);
    stack(end) = [];
    
    %get data for treedat
    currL = currL + 1;
    treetimes = [treetimes, Cells(currnum).time'];
    treeord = [treeord, currL + zeros(size(Cells(currnum).time'))];
    
    %check fates
    if strcmp(Cells(currnum).Fate,'x') %cell died
        fateord = [fateord, currL];
        fatetimes = [fatetimes, Cells(currnum).time(end)];
        fatelabels = [fatelabels, 'x'];
    elseif strcmp(Cells(currnum).Fate,'u') %unknown fate
        fateord = [fateord, currL];
        fatetimes = [fatetimes, Cells(currnum).time(end)];
        fatelabels = [fatelabels, 'o'];
    elseif strcmp(Cells(currnum).Fate,'s') %survived
        fateord = [fateord, currL];
        fatetimes = [fatetimes, Cells(currnum).time(end)];
        fatelabels = [fatelabels, 's'];
    elseif strcmp(Cells(currnum).Fate,'p') %cell divided, add to stack
        fateord = [fateord, currL];
        fatetimes = [fatetimes, Cells(currnum).time(end)];
        fatelabels = [fatelabels, '+'];
        stack = [stack, Cells(currnum).DaughtCells];
    end
    cellnumlabels = [cellnumlabels, currnum];
end

treedat = [treeord; treetimes];
fatedat = [fateord; fatetimes];