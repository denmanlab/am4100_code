%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Filename:    getTimeValues.m
%
% Copyright:   A-M Systems
%
% Author:      DHM
%
% Description:
%   This is a MATLAB script that takes the gui handle and returns
%   the the time values for graphing purposes
%   
%
%	Ensure that the location of this file is in your MATLAB Path.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Err, Tdly, Tdur, Tper, Tqty, Etype, Eqty, Edly, Edur1, Edur2, Edur3, Eper]...
    = getTimeValues(indx)
global lData;
global myAMS;
values=ComConstants;
h=guidata(gcf); %get graphic data
Err=false; 
    Tdly=str2double(get(h.TrainDelay, 'string'));
    Tdur=str2double(get(h.TrainDur, 'string'));
    Tper=str2double(get(h.TrainPeriod, 'string'));
    Tqty=str2double(get(h.TrainQuantity, 'string'));
    if get(h.TrainType,'Value') == values.train.type.mixed+1   
        Eqty=lData.EventQuantity(lData.EventList(indx));
        Edly=lData.EventDelay(lData.EventList(indx))/1000;
        Edur1=lData.EventDur1(lData.EventList(indx))/1000;
        Edur2=lData.EventDur2(lData.EventList(indx))/1000;
        Edur3=lData.EventDur3(lData.EventList(indx))/1000;
        Eper=lData.EventPeriod(lData.EventList(indx))/1000;
        Etype=int8(myAMS.values.event.type.( cell2mat(lData.EventType(lData.EventList(indx)))))+1 ;
        if strcmp( cell2mat( lData.EventType(lData.EventList(indx)) ),'biphasic' )
            Esym =1;
        else 
            Esym=0;
        end
    else
        Eqty=str2double(get(h.EventQuantity, 'string'));
        Edly=str2double(get(h.EventDelay, 'string'));
        Edur1=str2double(get(h.EventDur1, 'string'));
        Edur2=str2double(get(h.EventDur2, 'string'));
        Edur3=str2double(get(h.EventDur3, 'string'));
        Eper=str2double(get(h.EventPeriod, 'string'));
        Etype=uint16(get(h.EventType,'Value'));
    %     if Etype>2; Etype=Etype-1; end
         if Etype == values.event.type.biphasic+1 %biphasic
            Esym=1;
         else
             Esym=0;
         end   
    end
if Esym ==1
    Edur3=Edur1;
else
    if  Etype == values.event.type.monophasic+1 
        Edur2=0;
        Edur3=0;
    end
end

if get(h.Auto,'Value')==values.auto.fill+1  %Auto = fill
     if get(h.TrainType,'Value') ~= values.train.type.mixed+1   % mixed events 
         Eqty=floor((Tdur-Edly)/Eper);
       
     end 
     Tper=Tdur;       
 end
 if get(h.Auto,'Value')==values.auto.count+1  %Auto=count
    if get(h.TrainType,'Value') ~= values.train.type.mixed+1   % mixed events  
        Tdur=Eqty*Eper+Edly;
    end
    Tper=Tdur;
 end
  
end






