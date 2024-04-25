function [ mx, IImx ] = sigmoidfilt(d,flag,L)
%function [ mx, IImx ] = sigmoidfilt(d,flag,length)
%applies sigmoid filter (decreasing) of length L to the signal in d. returns the
%maximum value of the filtered signal and the corresponding index in d
%flag indicates rising (1) or falling (-1) edge

if flag==1 %rising edge detector
    kern = -1./(1+exp(linspace(-4,4,L)))+0.5; %define sigmoid kernal
elseif flag==-1 %falling edge detector
    kern = -1./(1+exp(-linspace(-4,4,L)))+0.5; %define sigmoid kernal
else
    kern = 0;
end
F = imfilter(d, kern', 'replicate');
[mx, IImx] = max(F);


if 1==1
   plot(F)
   hold on
   plot(d, 'r')
   hold off
end

end

