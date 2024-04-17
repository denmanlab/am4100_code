function UserOutput=processUserInput(hObject, eventdata)

global myAMS;
global OKtoGraph;
global lData;
global cntrls;

[values,idx]=ComConstants;
h=guidata(gcf); %get graphic data
% Identify the control
bntData= get(hObject,'UserData');
control=cell2mat(bntData(1));
myType=cell2mat(bntData(2));
previousValue=cell2mat(bntData(3));
eListIndex=cell2mat(bntData(4));

% tmpdsp=sprintf('ch=%d    btn=%s    type=%d    val=%s ',channel,control,cntlType,value);
% disp(tmpdsp);

if myAMS.DoComms
    commsOK = true;
else
    commsOK = false;
end
% Do something with the user input

switch control
    case 'Open file'
       ReadAMSFile(hObject);
    case 'Save file'
       WriteAMSFile();
    case {'Mode','Trigger','Monitor','Sync1', 'Sync2', ...
            'PeriodOrFreq'}
        if commsOK
            if ~(strcmp(control,'PeriodOrFreq'))    %eliminates the send to change to frequncy rates
                myAMS.(control)=  get(h.(control),'Value') -1;
            end
        end 
        lData.(control)= getValueNames(control,get(h.(control),'Value')); 
        if strcmp(control,'PeriodOrFreq')
            if get(h.PeriodOrFreq,'value') == values.periodOrFreq.period+1 
                set(h.EventFrequency,'Visible','off' );
                set(h.EventFrequencylbl,'Visible','off' ); 
                set(h.EventFrequencyUnits,'Visible','off' ); 
                set(h.EventPeriod,'Visible','on' );
                set(h.EventPeriodlbl,'Visible','on' );
                set(h.EventPeriodUnits,'Visible','on' );
                set(h.TrainFrequency,'Visible','off' );
                set(h.TrainFrequencylbl,'Visible','off' ); 
                set(h.TrainFrequencyUnits,'Visible','off' ); 
                set(h.TrainPeriod,'Visible','on' );
                set(h.TrainPeriodlbl,'Visible','on' ); 
                set(h.TrainPeriodUnits,'Visible','on' );
            else
                set(h.EventFrequency,'Visible','on' );
                set(h.EventFrequencylbl,'Visible','on' ); 
                set(h.EventFrequencyUnits,'Visible','on' ); 
                set(h.EventPeriod,'Visible','off' );
                set(h.EventPeriodlbl,'Visible','off' );
                set(h.EventPeriodUnits,'Visible','off' );
                set(h.TrainFrequency,'Visible','on' );
                set(h.TrainFrequencylbl,'Visible','on' );
                set(h.TrainFrequencyUnits,'Visible','on' );
                set(h.TrainPeriod,'Visible','off' );
                set(h.TrainPeriodlbl,'Visible','off' );
                set(h.TrainPeriodUnits,'Visible','off' ); 
            end 
        end
        val=get(hObject,'Value');
        if strcmp(control,'Mode')
            if val > values.mode.intCurrent+1
                clearscreen;
            else
                if previousValue > values.mode.intCurrent+1
                   openscreen;
                end
                if val== values.mode.intVolt+1 %voltage
                    if previousValue == values.mode.intCurrent+1
                        set(h.TrainLevel,'string','0.000');
                        set(h.EventAmp1,'string','0.00000');
                        set(h.EventAmp2,'string','0.00000');
                        libindx=get(h.LibID,'value');
                        lData.TrainLevel=0;
                        lData.EventAmp1(libindx)=0;
                        lData.EventAmp2(libindx)=0;
                        if commsOK
                            myAMS.TrainLevel=0;
                            myAMS.EventAmp1=0;
                            myAMS.EventAmp2=0;
                        end
                        set(h.TrainLevelUnits,'String','V/mA');
                        set(h.EventAmp1Units,'String','V/mA');
                        set(h.EventAmp2Units,'String','V/mA');
                    end
                else %current
                    if previousValue == values.mode.intVolt+1
                        set(h.TrainLevel,'string','0.00');
                        set(h.EventAmp1,'string','0.00000');
                        set(h.EventAmp2,'string','0.00000');
                        libindx=get(h.LibID,'value');
                        lData.TrainLevel=0;
                        lData.EventAmp1(libindx)=0;
                        lData.EventAmp2(libindx)=0;
                        if commsOK
                            myAMS.TrainLevel=0;
                            myAMS.EventAmp1=0;
                            myAMS.EventAmp2=0;
                        end
                        set(h.TrainLevelUnits,'String','mA');
                        set(h.EventAmp1Units,'String','mA');
                        set(h.EventAmp2Units,'String','mA');
                    end                    
                end 
                if OKtoGraph; Plotit(); end
            end 
            set(h.(control),'UserData',{control myType val 0});
        else
           if OKtoGraph; Plotit(); end
            set(h.(control),'UserData',{control myType val 0});       
        end
        set(h.(control),'UserData',{control myType val 0});
    case 'TrainType'
        switch get(h.TrainType,'Value')
            case values.train.type.uniform+1
                for i=1:1:20
                    set(h.EventList(i),'Visible','off' );
                end
                set(h.EventListlbl,'Visible','off' );
                set(h.EventID,'Visible','off');
                set(h.EventIDlbl,'Visible','off');
                set(h.LibID,'Visible','on');
                set(h.LibIDlbl,'Visible','on');
                if get(h.Auto,'Value') == values.auto.fill+1
                    set(h.EventQuantity,'Visible','off');
                    set(h.EventQuantityAuto,'Visible','on'); 
                end
            case values.train.type.mixed+1
                for i=1:1:20
                    set(h.EventList(i),'Visible','on' );
                end
                set(h.EventListlbl,'Visible','on' );
                set(h.EventID,'Visible','on');
                set(h.EventIDlbl,'Visible','on');
                set(h.LibID,'Visible','on');
                set(h.LibIDlbl,'Visible','on');
                Eid=get(h.EventID,'Value');
                set(h.LibID,'Value',lData.EventList(Eid));
                if get(h.Auto,'Value') == values.auto.fill+1
                    set(h.EventQuantity,'Visible','on');
                    set(h.EventQuantitylbl,'Visible','on');
                end
                UpdateEvents();  
        end
        if commsOK
            myAMS.TrainType = get(h.TrainType,'Value')-1;  
        end
        lData.(control)=getValueNames(control,get(h.(control),'Value'));
        if OKtoGraph Plotit(); end
    case 'OffsetOrHold'
        if commsOK
            myAMS.OffsetOrHold= get(h.OffsetOrHold,'Value') -1;
        end
        lData.(control)=getValueNames(control,get(h.(control),'Value'));
        if OKtoGraph Plotit(); end
    case 'Auto'
        switch (get(h.Auto,'Value'))
            case values.auto.none+1 %None
                set(h.EventQuantity,'Visible','on');
                set(h.TrainDur,'Visible','on');
                set(h.TrainDurAuto,'Visible','off');
                set(h.TrainPeriodAuto,'Visible','off'); 
                set(h.EventQuantityAuto,'Visible','off'); 
                if get(h.PeriodOrFreq,'value') == values.periodOrFreq.period+1 
                    set(h.TrainPeriod,'Visible','on' );
                else
                    set(h.TrainFrequency,'Visible','on' );     
                end
            case values.auto.count+1
                set(h.TrainDur,'Visible','off');   %turn train duration off
                set(h.TrainDurAuto,'Visible','on');
                set(h.EventQuantity,'Visible','on'); %turn event quantity on
                set(h.EventQuantityAuto,'Visible','off');
                
                set(h.TrainPeriodAuto,'Visible','on'); %turn train per & freq off
                set(h.TrainPeriod,'Visible','off' );
                set(h.TrainFrequency,'Visible','off' );   
            case values.auto.fill+1
                set(h.TrainDur,'Visible','on');    % turn train duration on
                set(h.TrainDurAuto,'Visible','off');
                set(h.EventQuantity,'Visible','on'); %turn event quantity on for mixed
                set(h.EventQuantityAuto,'Visible','off');
                
                set(h.TrainPeriodAuto,'Visible','on'); %turn train per & freq off
                set(h.TrainPeriod,'Visible','off' );
                set(h.TrainFrequency,'Visible','off' ); 
                                              %turn event quantity off for uniform
                if get(h.TrainType,'Value') == values.train.type.uniform+1
                    set(h.EventQuantity,'Visible','off');
                    set(h.EventQuantityAuto,'Visible','on'); 
                end
        end
        if commsOK
            myAMS.Auto= get(h.Auto,'Value') -1;
        end
         if OKtoGraph, Plotit(); end
    case {'EventDelay' ,'EventDur1', 'EventDur2','EventDur3', ...
           'TrainDelay','TrainDur' }
            outnum = round(1000*str2double(timeNum(h.(control))));
            if commsOK
                myAMS.(control)=outnum;
            end
            if control(1)== 'E'
                libindx=get(h.LibID,'value');
                lData.(control)(libindx)=outnum;
            else
                lData.(control)=outnum;
            end
            if OKtoGraph Plotit(); end
    case {'EventAmp1' ,'EventAmp2', 'TrainLevel'}
            mode=get(h.Mode,'value');
            if mode == values.mode.intVolt+1
                outnum = round(1000000*str2double(VorIvalue(h.(control))));

            else
                outnum = round(1000*str2double(VorIvalue(h.(control))));

            end
            if commsOK
                myAMS.(control)=outnum;
            end
            if control(1)== 'E'
                libindx=get(h.LibID,'value');
                lData.(control)(libindx)=outnum;
            else
                lData.(control)=outnum;
            end
            if OKtoGraph Plotit(); end
    case {'TrainQuantity' , 'EventQuantity'}
            outnum=trainNum(h.(control));
            if commsOK
                myAMS.(control)=outnum;
            end
            if control(1)== 'E'
                libindx=get(h.LibID,'value');
                lData.(control)(libindx)=outnum;
            else
                lData.(control)=outnum;
            end
            if OKtoGraph Plotit(); end
    case 'Pin'
            outnum=round(str2double(get(h.Pin,'string')));
            if isnan(outnum)
                outnum=1001;
            end 
            if outnum < 1
                outnum=1;
            end
            if outnum > 99999
               outnum = 99999;
            end           
            myAMS.PIN=outnum;
            outstr=num2str(outnum,'%d');
            set(h.Pin,'string',outstr)
    case {'EventID', 'LibID' }
        IDnum(h.(control));
        if OKtoGraph Plotit(); end
    case 'EventList'
        IDnum(h.EventList(eListIndex));
        if OKtoGraph Plotit(); end
    case 'EventFrequency'
        ef=str2double(get(h.EventFrequency,'String'));
        ep=1/ef;
        epstr=sprintf('%0.3f',ep);
        set(h.EventPeriod,'String',epstr)
        outnum = round(1000*str2double(timeNum(h.EventPeriod)));
        if commsOK
            myAMS.EventPeriod=outnum; 
        end
        libindx=get(h.LibID,'value');          
        lData.EventPeriod(libindx)=outnum;
        if OKtoGraph Plotit(); end
    case 'EventPeriod'   
        outnum = round(1000*str2double(timeNum(h.EventPeriod)));
        ef=1000/outnum;
        efstr=sprintf('%0.3f',ef);
        set(h.EventFrequency,'String',efstr)
        if commsOK
            myAMS.EventPeriod=outnum;
        end
        libindx=get(h.LibID,'value');
        lData.EventPeriod(libindx)=outnum;    
        if OKtoGraph Plotit(); end
    case 'TrainPeriod'  
        outnum = round(1000*str2double(timeNum(h.TrainPeriod)));
        tf=1000/outnum;
        tfstr=sprintf('%0.3f',tf);
        set(h.TrainFrequency,'String',tfstr)
        if commsOK
            myAMS.TrainPeriod=outnum;
        end
        lData.TrainPeriod=outnum;           
        if OKtoGraph Plotit(); end
    case 'TrainFrequency'
        tf=str2double(get(h.TrainFrequency,'String'));
        tp=1/tf;
        tpstr=sprintf('%0.3f',tp);
        set(h.TrainPeriod,'String',tpstr)
        outnum = round(1000*str2double(timeNum(h.TrainPeriod)));
        if commsOK
            myAMS.TrainPeriod=outnum;
        end
        lData.TrainPeriod=outnum;       
        if OKtoGraph Plotit(); end
    case 'EventType'  %************************************************* **************************************
        if commsOK
             myAMS.(control)=get(h.(control),'Value') -1; 
        end
        libindx=get(h.LibID,'value');
        lData.EventType(libindx)={getValueNames(control,get(h.(control),'Value'))};  
        if OKtoGraph, Plotit(); end
    case {'Ymin', 'Ymax'}
        if OKtoGraph, Plotit(); end   
    case 'menupage'
        if commsOK
            contents=get(h.menupage,'String');
            mystr=contents{get(h.(control),'Value')};
            tmpval= values.menupage.(mystr);  
            myAMS.DisplayMenuPage(tmpval);
        end
    otherwise
         UserOutput=0;
end

guidata(hObject,h) ;%save graphic data

    function clearscreen()
        handlearray = findobj('-regexp','Tag','[A-z]');
        set( handlearray, 'visible', 'off')
        
        f=get(h.Igraph,'Parent');  % get the parent window.
        set(f,'WindowButtonMotionFcn', '');        
        set (f, 'WindowButtonUpFcn', '');       
        cla(h.thingy);
        cla(h.Igraph);
        cla(h.showSignal);
        set(h.thingy,'visible','off');
        set(h.Igraph,'visible','off');
        set(h.showSignal,'visible','off');
        set(h.Mode,'visible','on');
        set(h.Outputlbl,'visible','on');
    end
    function openscreen()
        handlearray = findobj('-regexp','Tag','[A-z]');
        set( handlearray, 'visible', 'on')
        set(h.thingy,'visible','on');
        set(h.Igraph,'visible','on');
        set(h.showSignal,'visible','on');
        if get(h.PeriodOrFreq,'value') == values.periodOrFreq.period+1 
            set(h.EventFrequency,'Visible','off' );
            set(h.EventFrequencylbl,'Visible','off' ); 
            set(h.EventFrequencyUnits,'Visible','off' ); 
            set(h.EventPeriod,'Visible','on' );
            set(h.EventPeriodlbl,'Visible','on' );
            set(h.EventPeriodUnits,'Visible','on' );
            set(h.TrainFrequency,'Visible','off' );
            set(h.TrainFrequencylbl,'Visible','off' ); 
            set(h.TrainFrequencyUnits,'Visible','off' ); 
            set(h.TrainPeriod,'Visible','on' );
            set(h.TrainPeriodlbl,'Visible','on' ); 
            set(h.TrainPeriodUnits,'Visible','on' );
        else
            set(h.EventFrequency,'Visible','on' );
            set(h.EventFrequencylbl,'Visible','on' ); 
            set(h.EventFrequencyUnits,'Visible','on' ); 
            set(h.EventPeriod,'Visible','off' );
            set(h.EventPeriodlbl,'Visible','off' );
            set(h.EventPeriodUnits,'Visible','off' );
            set(h.TrainFrequency,'Visible','on' );
            set(h.TrainFrequencylbl,'Visible','on' );
            set(h.TrainFrequencyUnits,'Visible','on' );
            set(h.TrainPeriod,'Visible','off' );
            set(h.TrainPeriodlbl,'Visible','off' );
            set(h.TrainPeriodUnits,'Visible','off' ); 
        end        
        
        switch get(h.TrainType,'Value')
            case values.train.type.uniform+1
                for i=1:1:20
                    set(h.EventList(i),'Visible','off' );
                end
                set(h.EventListlbl,'Visible','off' );
                set(h.EventID,'Visible','off');
                set(h.EventIDlbl,'Visible','off');
                set(h.LibID,'Visible','on');
                set(h.LibIDlbl,'Visible','on');
                if get(h.Auto,'Value') == values.auto.fill+1
                    set(h.EventQuantity,'Visible','off');
                    set(h.EventQuantityAuto,'Visible','on'); 
                end
            case values.train.type.mixed+1
                for i=1:1:20
                    set(h.EventList(i),'Visible','on' );
                end
                set(h.EventListlbl,'Visible','on' );
                set(h.EventID,'Visible','on');
                set(h.EventIDlbl,'Visible','on');
                set(h.LibID,'Visible','on');
                set(h.LibIDlbl,'Visible','on');
                Eid=get(h.EventID,'Value');
                set(h.LibID,'Value',lData.EventList(Eid));
                if get(h.Auto,'Value') == values.auto.fill+1
                    set(h.EventQuantity,'Visible','on');
                    set(h.EventQuantitylbl,'Visible','on');
                end
                UpdateEvents();  
        end        
        
        if OKtoGraph; Plotit(); end
    end

end