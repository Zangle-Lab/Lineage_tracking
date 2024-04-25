function [ MI ] = ConvertA2MI( A,M, pxlsize )
%function [ MI ] = ConvertA2MI( A, pxlsize )
%fucntion to convert area to mean intensity, given area (in pixels),
%mass (in pg), and pixelsize (in mm).

K = 1./(10000).^3./100./0.0018.*1e12; %pg/um^3

MI = M./(A.*pxlsize.^2.*1000.*K);

end

