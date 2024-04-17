%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Filename:    trainNum.m
%
% Copyright:   A-M Systems
%
% Author:      DHM
%
% Description:
%   This is a MATLAB script that takes a GUI text box and converts
%   the string to a integer number from 1 to 100.
%
%	Ensure that the location of this file is in your MATLAB Path.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function outnum=trainNum(hObject)
% trainNum Converts a string gui box into a valid time number 
%   trainNum(hObject) returns a valid number
%   the train number must be from 1 to 99999 
%
outnum = str2double(get(hObject,'string'));
if isnan(outnum)
    errordlg('You must enter a numeric value','Bad Input','modal')
    uicontrol(hObject)
	return
else
    if outnum < 1
        outnum=1;
    end
    if outnum > 99999
       outnum = 99999;
    end
    outnum=round(outnum);
    outstr=num2str(outnum,'%d');
    set(hObject,'string',outstr)
end