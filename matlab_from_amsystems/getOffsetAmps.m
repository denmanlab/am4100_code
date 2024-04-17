%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Filename:    GetOffetAmps.m
%
% Copyright:   A-M Systems
%
% Author:      DHM
%
% Description:
%   This is a MATLAB script that takes the gui handle and returns
%   the the four differnt amplitudes for graphing purposes
%   1) Amplitude for pulse period and pulse delay and tw with no signal
%   2) The amplitude for duration 1(or ending amp for ramp)
%   3) The amplitude for duration 2 (or interphase, now same as 1)
%   4) The amplitude for duration 3 (or ramp 2nd amp)
%   
%
%	Ensure that the location of this file is in your MATLAB Path.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Atp, Atw, A1, A2, A3] =getOffsetAmps(indx)
% VwithOffset Converts a string gui box into a valid voltage number 
%   VwithOffset(hObject) returns a valid voltage
%   VwithOffset must be in Volt format and from -10.000 to +10.000.
%
%       minimum step size is 0.001V
global lData;
 values=ComConstants;
 
if nargin == 0
    indx=1;
end

h=guidata(gcf); %get graphic data
oORh=get(h.OffsetOrHold,'Value');

Esym=0;
Tlev=str2double(get(h.TrainLevel, 'string'));
if get(h.TrainType,'Value') == values.train.type.mixed+1;  % used to be 3

    Eamp1=lData.EventAmp1(lData.EventList(indx))/1000000;
    Eamp2=lData.EventAmp2(lData.EventList(indx))/1000000;
    if strcmp( cell2mat( lData.EventType(lData.EventList(indx)) ),'biphasic' )
        Esym =1;
    end
else
    Eamp1=str2double(get(h.EventAmp1, 'string'));
    Eamp2=str2double(get(h.EventAmp2, 'string'));  
    if get(h.EventType,'Value') == values.event.type.biphasic+1; %biphasic
        Esym=1;
    end
end
if Esym ==1 %Symmetic=1 2= not symetric
  Eamp2=-Eamp1;
end
   switch oORh 
       case 2  % offset
            Atp=0;
            Atw=Tlev;
            A1=Eamp1+Tlev;
            A2=Tlev;
            A3=Eamp2+Tlev;
       case 1   %hold
            Atp=Tlev;
            Atw=Tlev;
            A1=Eamp1;
            A2=Tlev;
            A3=Eamp2;
       case 3   %none
            Atp=0;           
            Atw=0;
            A1=Eamp1;
            A2=0;
            A3=Eamp2;
   end
%    if Esym==1 %Symmetic=1 2= not symetric
%       A3=-(A1-Atw)+Atw;
%   end  
   
end