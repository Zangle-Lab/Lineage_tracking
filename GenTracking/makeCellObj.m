function [ Cell ] = makeCellObj( cellnum, newcellnum, Folder, LocIn, col6, Treatment, oo, kk )
%function to make a cell object

%%
%load saved data used to create cell object

file_1 = sprintf ('Loc_%d_well_%d_data_allframes.mat',oo,kk);
file_2 = sprintf ('Loc_%d_well_%d_Tdata1.mat',oo,kk);

load([Folder, file_1], 'ii_stored', 't_stored', 'xshift_store', 'yshift_store', 'fstart', 'fext', 'pxlsize', 'wavelength');
try
    load([Folder, file_1], 'time0');
end

load([Folder, file_2], 'T_array');
load([Folder, file_2], 'tracks');

tlim = tracks(:,4) <= 2700/60;
tracks = tracks(tlim,:);
%% median filter the tracks

  maxID = max(tracks(:,5));

  for ID = 1:maxID
      bb = [];
      [row, col] = find(tracks(:,5)== ID);
      bb = [bb, row];
     tracks(bb,3) = medfilt2(tracks(bb,3),[10 1],'symmetric');
  end
%%

if exist('time0', 'var') && ~ischar(time0)
    t_stored = (t_stored-time0)*60; %account for any corrections to t_stored, if they were made
else
    t_stored = t_stored*60;
end

[x,y,z,t,mu] = track_partn_MI(tracks,cellnum); %find track for potential parent cell
t = t.*60; %convert time from hours to minutes

%make mean intensity and area arrays
if strcmp(col6, 'Ar') %switch from Area to mean intensity
    MI = ConvertA2MI(mu,z,pxlsize); %compute mean intensity, in pixels
    A = mu;
else
    MI = mu;
    A = ConvertMI2A(mu,z,pxlsize);
end

%create Cellxshift,Cellyshift,CellFList,CellIIStore data
IndexBool = ismember(t_stored,t);
CellIIStore = ii_stored(IndexBool);
Cellxshift = xshift_store(IndexBool);
Cellyshift = yshift_store(IndexBool);
% CellFList = fileNames(CellIIStore,:); %file name was not stored, so this will be blank for now
CellFList = '';


Cell = CellObj(z,t,MI,A,x,y,Cellxshift,Cellyshift,CellIIStore,LocIn,cellnum,newcellnum,'u','u',[],[],Folder,Treatment,fstart,fext,CellFList,wavelength,pxlsize);

end
