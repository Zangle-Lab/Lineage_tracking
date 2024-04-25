function [ A ] = ConvertMI2A( MI,M, pxlsize )
%function [ MI ] = ConvertA2MI( A, pxlsize )
%fucntion to convert area to mean intensity, given area (in pixels),
%mass (in pg), and pixelsize (in mm).

K = 1./(10000).^3./100./0.0018.*1e12; %pg/um^3

A = M./(MI.*pxlsize.^2.*1000.*K);


end

