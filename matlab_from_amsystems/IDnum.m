%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Filename:    IDnum.m
%
% Copyright:   A-M Systems
%
% Author:      DHM
%
% Description:
%   This is a MATLAB script that takes a GUI text box for Event Number
%    or the LibID number and then finds the appropriate combination of the
%    two nubers from the library list. For EventID it must already exist,
%    for LibID it will change the current EventID to the new LibraryID
%
%	Ensure that the location of this file is in your MATLAB Path.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function outnum=IDnum(hObject)
% IDnum Converts a string gui box into a valid time number 
%   IDnum(hObject) returns a valid number
%   the train number must be from 1 to 20
%
global myAMS;
global lData;

values=ComConstants;
h=guidata(gcf); %get graphic data
EventIDNames='';
outnum = get(hObject,'Value');
bntData=get(hObject,'UserData');
btnName=cell2mat(bntData(1));
btnType=cell2mat(bntData(2));
myValue=cell2mat(bntData(3)); 
indx=cell2mat(bntData(4));
if myAMS.DoComms
    commsOK=true;
else
    commsOK=false;
end
if isnan(outnum)
    errordlg('You must enter a numeric value','Bad Input','modal')
    uicontrol(hObject)
	return
else
    if outnum < 1
        outnum=1;
    end
    for idn=1:1:20
        enb=get( h.EventList(idn),'Enable');
        if strcmp(enb,'on')
            EventListSize=idn;
        end
    end
    switch btnName
        case 'EventID'
            if outnum>EventListSize-1
                outnum=EventListSize-1;
            end
            if outnum ~= myValue
                set(h.EventID,'UserData',{btnName btnType outnum 0});
                if outnum == 1
                    set(h.LibID,'Value',get(h.EventList(outnum),'Value'));
                else
                    set(h.LibID,'Value',get(h.EventList(outnum),'Value')-1);
                end
               if commsOK
%                     myAMS.EventID=outnum;  
                    myAMS.LibID=get(h.LibID,'Value');
                end 
               UpdateEvents()   
            end
        case 'LibID'
            if outnum > 20
                outnum = 20;
            end
            if get(h.TrainType,'Value')== (values.train.type.mixed+1)% if mixed change eventlist
                if get(h.EventID,'Value') == 1 
                    set(h.EventList(get(h.EventID,'Value')),'Value',outnum);
                else
                    set(h.EventList(get(h.EventID,'Value')),'Value',outnum+1);
                end 
                 lData.EventList(get(h.EventID,'Value'))=outnum;
            end

            if commsOK
                if get(h.TrainType,'Value')== (values.train.type.mixed+1) % if mixed change eventlist
                    myAMS.EventList(get(h.EventID,'Value'))=outnum;
                else
%                     myAMS.EventList(1)=outnum;
                     myAMS.UniformNumber=get(h.LibID,'Value');
                end
                myAMS.LibID=get(h.LibID,'Value');
            end
             UpdateEvents()             
        case 'EventList'
            if outnum > 20+1
                outnum = 20+1;
            end
            if indx ==1
                outnum=outnum+1;
            end
            if outnum == 1 %decreasing the size of EventList particular spot is specified as empty
                if get(h.EventID,'Value')>=indx
                    set(h.EventID,'Value',indx-1);
                    newLibID=get(h.EventList(indx-1),'Value'); %get library number from eventlist
                    if (indx-1)==1  % if newLIB ID is the first
                        set(h.LibID,'Value', newLibID); %EventList(not EventID) Values in slot 1 have no blank
                    else
                        set(h.LibID,'Value', newLibID-1);  %Other slots have a blank first position
                    end
                end
                for dropbx=indx+1:1:EventListSize
                    set( h.EventList(dropbx), 'Value', 1 , ...
                        'Enable', 'inactive','BackgroundColor',[0.4,0.4,0.4]);
                end
                lData.EventList=lData.EventList(1:indx-1);
                if commsOK
                    myAMS.EventList=[lData.EventList zeros(1,20-size(lData.EventList,2))-1];
                end
            else
                if indx == get(h.EventID,'Value')
                    set(h.LibID,'Value',outnum-1);
                    myAMS.LibID=get(h.LibID,'Value');
%                     myAMS.UniformNumber=get(h.LibID,'Value');
                    UpdateEvents()  
                end
                if indx == EventListSize  %increasing the size of EventList
                    lData.EventList=[lData.EventList 1];
                    if commsOK
                        myAMS.LibID=get(h.LibID,'Value');
                        myAMS.EventList=[lData.EventList zeros(1,20-size(lData.EventList,2))-1];
                    end
                    set( h.EventList(indx+1), 'Enable', 'on','BackgroundColor','white');
                    for i=1:EventListSize
                        EventIDNames= strcat(EventIDNames,num2str(i));
                        if i < EventListSize
                             EventIDNames= strcat(EventIDNames,'|');
                        end
                    end
                    set( h.EventID,'string', EventIDNames); 
                end
            end
            if outnum>1
                lData.EventList(indx)=outnum-1;
                if commsOK
                    myAMS.EventList(indx)=outnum-1;
                end
            end
            if indx ==1
                outnum=outnum-1;
            end
            %             UpdateEvents(get(h.EventID,'Value),outnum)   ***********************************make this              
    end

    set(hObject,'Value',outnum)
end