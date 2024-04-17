
function SetCom(hObject, eventdata)
global myAMS;
global lData;
myfig=gcf;

h=guidata(gcf); %get graphic data
% handlearray = findobj('-regexp','Tag','[^'']');
handlearray = findobj('-regexp','Tag','[A-z]');
set( handlearray, 'Enable', 'off')
% set( findall(h.Controls2, '-property', 'Enable'), 'Enable', 'off')
pause(0.02);
strlist=get(h.Sport,'String');
val=get(h.Sport,'Value');
if val ~= 1
    if ~isempty(myAMS.PortInfo)
        myAMS.PortInfo=[];
    end
    if strcmp(strlist(val),'Ethernet')
        mynet=get(h.Ethernet,'String');
        myAMS=ams4100_hClass(mynet);
    else
        myAMS=ams4100_hClass(strlist(val));
    end
    set(myfig,'Name',['AMS4100 Revision:' myAMS.Revision '  Serial Number:' myAMS.SerialNumber  '   Matlab Revision:' myAMS.MatlabRev ] );
    pause(.1);
%% *******************************************************************************************************    
%    LoadLibrary();           %**************** write over the first 4 libraries and mains.  ******** 
%% *******************************************************************************************************    
    LoadWindow();
    Plotit();
    processUserInput(h.TrainType);
    if myAMS.PortSuccess
        a=get(h.TimerA,'Running');
        if strcmp(a,'off')
             start(h.TimerA);
        end
    end
else
    if strcmp(myAMS.Port(1:3),'COM')
        clear obj.PortInfo 
    end
    myAMS.Port='COMNONE';
end


set( handlearray, 'Enable', 'on')
firstNullevent=1;
for n = 1:20
    if myAMS.EventList(n)>0
        set(h.EventList(n), 'Enable', 'on','BackgroundColor','white');
    else
        if firstNullevent
            firstNullevent=0;
            set(h.EventList(n), 'Enable', 'on','BackgroundColor','white');
        else
        set(h.EventList(n), 'Value', 1 , ...
                    'Enable', 'inactive','BackgroundColor',[0.4,0.4,0.4])                
        end 
    end  
end


% set( findall(h.Controls2, '-property', 'Enable'), 'Enable', 'on')
%  
end
