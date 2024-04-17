%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Filename:    VorIvalue.m
%
% Copyright:   A-M Systems
%
% Author:      DHM
%
% Description:
%   This is a MATLAB script that takes a GUI text box and converts
%   the string to a decimal string from -200.000 to +200.000 in volts
%   or -100.00 to +100.00 in mA .
%
%	Ensure that the location of this file is in your MATLAB Path.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function outstr=VorIvalue(hObject)
% VorIvalue Converts a string gui box into a valid amplitude  
%   VorIvalue(hObject) returns a valid amplitude
%   volts must be in Volt format and from -10.000 to +10.000.
%   current must be in mA format from -100.00 to +100.00
%       minimum step size for V is 0.001V
%       minimum step size for I is 0.01mA

outnum = str2double(get(hObject,'string'));
values=ComConstants;
h=guidata(gcf); %get graphic data
mode=get(h.Mode,'value');
mon=get(h.Monitor,'value');
if isnan(outnum)
    errordlg('You must enter a numeric value','Bad Input','modal')
    uicontrol(hObject)
	return
else
    switch mode
        case values.mode.intVolt+1
            if outnum < -200
                outnum=-200;
            end
            if outnum > 200
               outnum = 200;
            end
            outnum=round(outnum*10^6)/10^6;
            outstr=num2str(outnum,'%.6f');
            set(hObject,'string',outstr)
        case values.mode.intCurrent+1   
            if outnum < -100
                outnum=-100;
            end
            if outnum > 100
               outnum = 100;
            end
            outnum=round(outnum*10^3)/10^3;
            outstr=num2str(outnum,'%.2f');
            set(hObject,'string',outstr)            
    end

end