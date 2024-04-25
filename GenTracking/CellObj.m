%class definition for cell object
%uses handle definition so that data is not copied over again in
%  higher-level classes
%TAZ September 16, 2013

classdef CellObj < handle
    properties
       mass %mass data over time (pg)
       time %time vector (minutes)
       MI %mean intensity over time
       A %area over time (micron)
       x %x location from tracking array
       y %y location from tracking array
       xshift %xshift from cros-correlation method
       yshift %yshift from cros-correlation method
       ii_stored %stored indices in the D_stored matrix

       LocNum %location number
       OrigCellNum %cell number from original tracking algorithm run
       CellNum %cell number from new loading into CellObj

       Origin = 'u'; %origin of cell (u - unknown, f - founder cell, d - daughter cell, s - survivor cell (makes it to end of tracking))
       Fate = 'u'; %fate of cell (u - unknown, p - parent cell, x - dead cell
       ParentCell %cell number of parent cell object, if known
       DaughtCells %cell numbers of daughter cell objects, if known


       FFolder = ''; %file folder location
       Treatment = ''; %string for treatment identifier
       FStart = ''; %start of filename
       FEnd = '.opd'; %end of filename
       FNameList = cell(0); %cell array of filenames

       wavelength
       pxlsize

       %optional image data
       imagedata %phase image data, should be single type
       labeldata %label matrix data, should be 1 where cell is, 0 elsewhere, bool or int type
       PQMdata %phase quality magnitude data, single or double
       intdata %intensity image data, should be single

    end %properties
    properties (Dependent = true, SetAccess = private)
       GRate %growth rate from linear fit
       Mass0 %initial mass from linear fit
    end %properties (Dependent = true, SetAccess = private)

    methods
        %CellObj constructor function
        function CO = CellObj(mass, time, MI,A,x,y,xshift,yshift,ii_stored,LocNum,OrigCellNum,CellNum,Origin,Fate,ParentCell,DaughtCells,FFolder,Treatment,FStart,FEnd,FNameList,wavelength,pxlsize)
            if nargin >0 %support calling with 0 arguments
                CO.mass = mass; %mass data over time (pg)
                CO.time = time;%time vector (minutes)
                CO.MI = MI; %mean intensity over time
                CO.A  = A; %area over time (micron)
                CO.x = x; %x location from tracking array
                CO.y = y; %y location from tracking array
                CO.xshift = xshift; %xshift from cros-correlation method
                CO.yshift = yshift; %yshift from cros-correlation method
                CO.ii_stored = ii_stored; %stored indices in the D_stored matrix

                CO.LocNum = LocNum; %location number
                CO.OrigCellNum = OrigCellNum; %cell number from original tracking algorithm run
                CO.CellNum = CellNum; %new cell number

                CO.Origin = Origin;
                CO.Fate = Fate;
                CO.ParentCell = ParentCell;
                CO.DaughtCells = DaughtCells;

                CO.FFolder = FFolder; %file folder location
                CO.Treatment = Treatment; %string for treatment identifier
                CO.FStart = FStart; %start of filename
                CO.FEnd = FEnd; %end of filename
                CO.FNameList = FNameList; %cell array of filenames

                CO.wavelength = wavelength;
                CO.pxlsize = pxlsize;
            end
        end %CellObj

        function grate = get.GRate(obj)
            if isempty(obj.mass)
                error('mass data required for growth rate calculation')
            else
                P = polyfit(obj.time, obj.mass,1);
                grate = P(1);
            end
        end %GRate get method

        function mass0 = get.Mass0(obj)
            if isempty(obj.mass)
                error('mass data required for initial mass calculation')
            else
                P = polyfit(obj.time, obj.mass,1);
                mass0 = P(2);
            end
        end %Mass0 get method

        function H = plot(obj,varargin)
            H = plot(obj.time,obj.mass,varargin{:});
            set(gca, 'FontSize', 14)
            ylabel('mass (pg)')
            xlabel('time (min)')
            box off
        end % plot

        % TODO, maybe: implement property set methods, ex: function obj = set.GRate(obj,~) error('You cannot set GRate explicitly'); end
        % TODO, maybe: implement disp and plot functions, more info here: http://www.mathworks.com/help/matlab/matlab_oop/example--representing-structured-data.html

    end %methods
end %classdef
