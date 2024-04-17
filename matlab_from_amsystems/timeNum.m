%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Filename:    timeNum.m
%
% Copyright:   A-M Systems
%
% Author:      DHM
%
% Description:
%   This is a MATLAB script that takes a GUI text box and converts
%   the string to a decimal string from 0.000 to 90,000,000.000.
%
%	Ensure that the location of this file is in your MATLAB Path.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function outstr=timeNum(hObject)
%timeNum Converts a string gui box into a valid time number 
%   timeNum(hObject) returns a valid time
%   times must be in ms format and from 0 to 900000.000ms
%
%       minimum step size is 0.001ms
outnum = str2double(get(hObject,'string'));
bntData=get(hObject,'UserData');
btnName=cell2mat(bntData(1));
if isnan(outnum)
    errordlg('You must enter a numeric value','Bad Input','modal')
    uicontrol(hObject)
	return
else
    switch btnName
        case 'EventDur1'
            if outnum < .001
                  outnum=.001;
            end
        case {'EventPeriod', 'TrainDur', 'TrainPeriod'}
            if outnum < .002
                outnum=.002;
            end
        otherwise
            if outnum < 0
                  outnum=0;
            end
    end     
    if outnum > 90000000
       outnum = 90000000;
    end
    outnum=round(outnum*10^3)/10^3;
    outstr=num2str(outnum,'%.3f');
    set(hObject,'string',outstr)
end
