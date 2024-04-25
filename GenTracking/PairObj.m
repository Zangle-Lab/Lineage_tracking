%class definition for cell pair object
%TAZ September 17, 2013

classdef PairObj
    properties
       Parent = CellObj; %parent cell object
       Daught1 = CellObj; %cell object of daughter 1 (should be cell with larger initial mass)
       Daught2 = CellObj; %cell object of daughter 2

       %optional image data
       imagedata %phase image data, should be single type
       labeldata %label matrix data, should define daughter cells and parent cells differently, int type
    end %properties
    properties (Dependent = true, SetAccess = private)
       m_p; %mass of parent cell over time
       m_d1; %mass of daughter 1 cell over time
       m_d2; %mass of daughter 2 cell over time
       t_p; %time for plotting parent cell mass
       t_d1; %time for plotting daughter 1 cell mass
       t_d2; %time for plotting daughter 2 cell mass
       tdiv; %cell division time
    end %properties (Dependent = true, SetAccess = private)

    methods
        function PO = PairObj(Parent, Daught1, Daught2)
            if nargin >0 %support calling with 0 arguments
                PO.Parent = Parent;
                PO.Daught1 = Daught1;
                PO.Daught2 = Daught2;
            end
        end %PairObj

        function mass = get.m_p(obj)
            if isempty(obj.Parent.mass)
                error('parent mass data required')
            else
                mass = obj.Parent.mass;
            end
        end %m_p get method

        function mass = get.m_d1(obj)
            if isempty(obj.Daught1.mass)
                error('daughter 1 mass data required')
            else
                mass = obj.Daught1.mass;
            end
        end %m_d1 get method

        function mass = get.m_d2(obj)
            if isempty(obj.Daught2.mass)
                error('daughter 2 mass data required')
            else
                mass = obj.Daught2.mass;
            end
        end %m_d2 get method

        function time = get.t_p(obj)
            if isempty(obj.Parent.time)
                error('parent time data required')
            else
                time = obj.Parent.time;
            end
        end %t_p get method

        function time = get.t_d1(obj)
            if isempty(obj.Daught1.time)
                error('daughter 1 time data required')
            else
                time = obj.Daught1.time;
            end
        end %t_d1 get method

        function time = get.t_d2(obj)
            if isempty(obj.Daught2.time)
                error('daughter 2 time data required')
            else
                time = obj.Daught2.time;
            end
        end %t_d2 get method

        function time = get.tdiv(obj)
            if isempty(obj.Parent.time)
                error('parent time data required')
            else
                time = obj.Parent.time(end);
            end
        end %tdiv get method

        % TODO, maybe: implement property set methods, ex: function obj = set.GRate(obj,~) error('You cannot set GRate explicitly'); end
        % TODO, maybe: implement disp and plot functions, more info here: http://www.mathworks.com/help/matlab/matlab_oop/example--representing-structured-data.html

    end %methods
end %classdef
