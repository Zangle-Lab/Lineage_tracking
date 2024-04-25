function [CellsOut] = DeleteCellObj(CellsIn, C)
%function [CellsOut] = DeleteCellObj(CellsIn, C)
%deletes Cell number C from cell list CellsIn, returns the remainder
CellsOut = CellsIn([1:C-1,C+1:end]);