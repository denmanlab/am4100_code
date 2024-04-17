%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Filename:    RetEamp1.m
%
% Copyright:   A-M Systems
%
% Author:      DHM
%
% Description:
%
%	Ensure that the location of this file is in your MATLAB Path.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Eamp1 =RetEamp1(A1)
% VwithOffset Converts a string gui box into a valid voltage number 
%   VwithOffset(hObject) returns a valid voltage
%   VwithOffset must be in Volt format and from -10.000 to +10.000.
%
%       minimum step size is 0.001V

h=guidata(gcf); %get graphic data
oORh=get(h.OffsetOrHold,'Value');
   
Tlev=str2double(get(h.TrainLevel, 'string'));

   switch oORh 
       case 2  % offset
            Eamp1=A1-Tlev;
       case 1   %hold
            Eamp1=A1;
       case 3   %none
            Eamp1=A1;

   end
   

end