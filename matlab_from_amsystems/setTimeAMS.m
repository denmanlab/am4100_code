%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Filename:    setTimeAMS.m
%
% Copyright:   A-M Systems
%
% Author:      DHM
%
% Description:
%   This is a MATLAB script that takes a Model 4100 time value and converts
%   it into a decimal string from 0.000 to 90,000,000.000.
%
%	Ensure that the location of this file is in your MATLAB Path.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function setTimeAMS(hObject, val)
h=guidata(hObject); %get graphic data
bntData=get(hObject,'UserData');
  % UserData= name, type, myValue, previous_value_from_instrument
btnName=cell2mat(bntData(1));
% cntlType=cell2mat(bntData(2));
% myValue=cell2mat(bntData(3));
% pVal=cell2mat(bntData(4));
val=val/1000;

 switch btnName
         case 'EventDur1'
            if val < .001
                  val=.001;
            end
        case {'EventPeriod', 'TrainDur', 'TrainPeriod'}
            if val < .002
                val=.002;
            end
        otherwise
            if val < 0
                  val=0;
            end
 end
 
 set(h.(bntName),'Value', num2str( val ));  

end