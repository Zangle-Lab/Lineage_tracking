function [CellsOut] = MergeCellObjs(CellsIn, C1, C2)
%function [CellsOut] = MergeCellObjs(CellsIn, C1, C2)
%function to merge cells C1 and C2 in the list of CellsIn Cell objects
%new list is returned in CellsOut
%Original cell numbers are not retained by this function
%method: The first cell with data (C1 or C2) is replaced by a merge of C1 and C2
%Variable handling:
%  LocNum is checked for consistency. If not consistent, function exits with an error - this is the only consistency check
%  mass,time,MI,A,x,y,ii_stored are merged and sorted by the new merged time vector
%  xshift and yshift are merged and sorted by new time vector if length > 1
%  otherwise, they are left at length 1, with value equal to that of earliest cell
%  OrigCellNum is appended to without regard to order
%  new CellNum is C1, then CellNum in each of the cell objects in CellsIn is updated to reflect the new ordering in the output array, CellsOut
%  Origin and ParentCell are taken from the cell object with the earliest time
%  Fate and DaughtCells is taken from the cell object with the latest time 
%  Treatment, FFolder, FStart, wavelength, pxlsize, and FEnd are taken from cell with earliest time series data
%  imagedata, labeldata, PQMdata, CellFList, and intdata are not handled in the current version


%find cell with earlist time series data, this becomes Cell1
t0_1 = CellsIn(C1).time(1);
t0_2 = CellsIn(C2).time(1);
%also store latest time series data
tf_1 = CellsIn(C1).time(end);
tf_2 = CellsIn(C2).time(end);

if t0_1<t0_2
    Cell1 = CellsIn(C1);
    Cell2 = CellsIn(C2);
else
    Cell1 = CellsIn(C2);
    Cell2 = CellsIn(C1);
end

%LocNum checked for consistency. If not consistent, function exits with an error
%this is the only consistency check
if Cell1.LocNum ~= Cell2.LocNum
    disp('error: Location numbers do not match')
    CellsOut = [];
    return;
end
LocNum_n = Cell1.LocNum;

%merge and sort time vector
[time_n, I_sort] = sort([Cell1.time; Cell2.time]);

%mass,time,MI,A,x,y,ii_stored merged and sorted by the new merged time vector
mass_n = [Cell1.mass; Cell2.mass];
mass_n = mass_n(I_sort);

MI_n = [Cell1.MI; Cell2.MI];
MI_n = MI_n(I_sort);

A_n = [Cell1.A; Cell2.A];
A_n = A_n(I_sort);

x_n = [Cell1.x; Cell2.x];
x_n = x_n(I_sort);

y_n = [Cell1.y; Cell2.y];
y_n = y_n(I_sort);

%TODO: fix this error, some cells have ii_stored data, others do not..
if ~isempty(Cell1.ii_stored) && ~isempty(Cell2.ii_stored)
    ii_stored_n = [Cell1.ii_stored; Cell2.ii_stored];
    ii_stored_n = ii_stored_n(I_sort);
else
    ii_stored_n = Cell1.ii_stored;
end
%xshift and yshift merged and sorted by new time vector if length > 1, otherwise, they are left at length 1, with value equal to that of Cell1
% if length(Cell1.xshift)>1 || length(Cell2.xshift)>1
%     xshift_n = [Cell1.xshift; Cell2.xshift];
%     xshift_n = xshift_n(I_sort);
%     
%     yshift_n = [Cell1.yshift; Cell2.yshift];
%     yshift_n = yshift_n(I_sort);
% else
    xshift_n = Cell1.xshift;
    yshift_n = Cell1.yshift;
% end

%OrigCellNum appended to without regard to order
OrigCellNum_n = [Cell1.OrigCellNum, Cell2.OrigCellNum];

%new CellNum is the lesser of C1 and C2
CellNum_n = C1;

%Origin and ParentCell are taken from the cell object with the earliest time
Origin_n = Cell1.Origin;
ParentCell_n = Cell1.ParentCell;

%Fate and DaughtCells is taken from the cell object with the latest time
if tf_1 > tf_2
    Fate_n = CellsIn(C1).Fate;
    DaughtCells_n = CellsIn(C1).DaughtCells;
else
    Fate_n = CellsIn(C2).Fate;
    DaughtCells_n = CellsIn(C2).DaughtCells;
end

%wavelength, pxlsize, Treatment, FFolder, FStart, and FEnd are taken from C1
wavelength_n = Cell1.wavelength;
pxlsize_n = Cell1.pxlsize;
Treatment_n = Cell1.Treatment;
FFolder_n = Cell1.FFolder;
FStart_n = Cell1.FStart;
FEnd_n = Cell1.FEnd;

%CellFList not handled
CellFList_n = '';

%make CellsOut array, put in new cell, and delete old cell
CellsOut = CellsIn;
CellNew = CellObj(mass_n,time_n,MI_n,A_n,x_n,y_n,xshift_n,yshift_n,ii_stored_n,LocNum_n,OrigCellNum_n,CellNum_n,Origin_n,Fate_n,ParentCell_n,DaughtCells_n,FFolder_n,Treatment_n,FStart_n,FEnd_n,CellFList_n,wavelength_n,pxlsize_n);
CellsOut(CellNum_n) = CellNew;
CellsOut = DeleteCellObj(CellsOut, C2);

%epdate CellNum to reflect the ordering in the output array, CellsOut
for ii = 1:length(CellsOut);
    CellsOut(ii).CellNum = ii;
end