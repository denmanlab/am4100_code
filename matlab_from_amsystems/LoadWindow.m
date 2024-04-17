function LoadWindow()
global myAMS;
global lData;
global cntrls;
h=guidata(gcf); %get graphic data
vals=ComConstants;
    if myAMS.DoComms && myAMS.PortSuccess
        set(h.Active,'String',myAMS.Active);
        lData.PIN=myAMS.PIN;
        lData.Mode=myAMS.Mode;
        lData.Trigger=myAMS.Trigger;
        lData.Auto=myAMS.Auto;
        lData.Monitor=myAMS.Monitor;
        lData.Sync1=myAMS.Sync1;
        lData.Sync2=myAMS.Sync2;
        lData.PeriodOrFreq=myAMS.PeriodOrFreq;
        lData.TrainType=myAMS.TrainType;
        lData.TrainDelay=myAMS.TrainDelay;
        lData.TrainDur=myAMS.TrainDur;
        lData.TrainPeriod=myAMS.TrainPeriod;
        lData.TrainQuantity=myAMS.TrainQuantity;
        lData.TrainLevel=myAMS.TrainLevel;
        lData.OffsetOrHold=myAMS.OffsetOrHold;
        lData.EventList=myAMS.EventList;
        i=1;
        while(lData.EventList(i)>0 && i<21)
            i=i+1;
        end
        EventListEnd=i-1;
        lData.EventList=lData.EventList(1:i-1);
%         Eid=myAMS.EventID;
         Eid=int16(get(h.EventID,'Value'));
   
        for n=1:EventListEnd
            myAMS.LibID=n;
            pause(.05);
            lData.EventType(n)={myAMS.EventType};
            lData.EventQuantity(n)=myAMS.EventQuantity;
            lData.EventDelay(n)=myAMS.EventDelay;
            lData.EventDur1(n)=myAMS.EventDur1;
            lData.EventDur2(n)=myAMS.EventDur2;
            lData.EventDur3(n)=myAMS.EventDur3;
            lData.EventPeriod(n)=myAMS.EventPeriod;
            lData.EventAmp1(n)=myAMS.EventAmp1;
            lData.EventAmp2(n)=myAMS.EventAmp2;           
        end
        myAMS.loading=1;  % turn off start and stop
        for n=EventListEnd+1:20
            myAMS.LibID=n;
            pause(.05);
            myAMS.EventType=1;
            lData.EventType(n)={getValueNames('EventType',1)};
            myAMS.EventQuantity=1;
            lData.EventQuantity(n)=1;
            myAMS.EventDelay=0;
            lData.EventDelay(n)=0;
            myAMS.EventDur1=1;
            lData.EventDur1(n)=1;
            myAMS.EventDur2=0;
            lData.EventDur2(n)=0;          
            myAMS.EventDur3=0;
            lData.EventDur3(n)=0;            
            myAMS.EventPeriod=2;
            lData.EventPeriod(n)=2;
            myAMS.EventAmp1=0;
            lData.EventAmp1(n)=0;
            myAMS.EventAmp2=0;
            lData.EventAmp2(n)=0;
        end
        myAMS.loading=0;  % turn on start and stop
        lData.UniformNumber=myAMS.UniformNumber;
        if strcmp(lData.TrainType,'uniform')
            Lid=lData.UniformNumber;
        else
            Lid=lData.EventList(Eid);
        end
        myAMS.LibID=Lid;
    else   
        set(h.Active,'String','No Instrument');
    end
    set(h.Pin,'String',num2str(lData.PIN));
    set(h.Mode,'Value', int8(myAMS.values.mode.(lData.mode))+1); 
    set(h.Mode,'UserData',{'mode',2,get(h.Mode,'Value'),0});
    set(h.Trigger,'Value', int8(myAMS.values.trigger.(lData.Trigger))+1);
    set(h.Auto,'Value', int8(myAMS.values.auto.( lData.Auto))+1);
    set(h.Monitor,'Value', int8(myAMS.values.monitor.( lData.Monitor))+1);
    set(h.Sync1,'Value', int8(myAMS.values.sync.(lData.Sync1))+1);
    set(h.Sync2,'Value', int8(myAMS.values.sync.(lData.Sync2))+1);
    PorF=lData.PeriodOrFreq;
    set(h.PeriodOrFreq,'Value', int8(myAMS.values.periodOrFreq.(PorF))+1);
    set(h.TrainType,'Value', int8(myAMS.values.train.type.(lData.TrainType))+1);
    set(h.TrainDelay,'String', num2str(lData.TrainDelay/1000 ));  
    set(h.TrainDur,'String',  num2str(lData.TrainDur/1000 ));  
    tp= lData.TrainPeriod/1000;
    set(h.TrainPeriod,'String',num2str(tp) );  
    set(h.TrainFrequency,'string',num2str(1/tp) );

%%

    if strcmp(PorF,'period')
        set(h.TrainFrequency,'Visible','off' );
        set(h.TrainFrequencylbl,'Visible','off' ); 
        set(h.TrainFrequencyUnits,'Visible','off' ); 
        set(h.TrainPeriod,'Visible','on' );
        set(h.TrainPeriodlbl,'Visible','on' );
        set(h.TrainPeriodUnits,'Visible','on' ); 
        set(h.EventFrequency,'Visible','off' );
        set(h.EventFrequencylbl,'Visible','off' ); 
        set(h.EventFrequencyUnits,'Visible','off' );
        set(h.EventPeriod,'Visible','on' );
        set(h.EventPeriodlbl,'Visible','on' );
        set(h.EventPeriodUnits,'Visible','on' );
    else
        set(h.TrainFrequency,'Visible','on' );
        set(h.TrainFrequencylbl,'Visible','on' ); 
        set(h.TrainFrequencyUnits,'Visible','on' ); 
        set(h.TrainPeriod,'Visible','off' );
        set(h.TrainPeriodlbl,'Visible','off' );
        set(h.TrainPeriodUnits,'Visible','off' );
        set(h.EventFrequency,'Visible','on' );
        set(h.EventFrequencylbl,'Visible','on' );
        set(h.EventFrequencyUnits,'Visible','on' );
        set(h.EventPeriod,'Visible','off' );
        set(h.EventPeriodlbl,'Visible','off' );
        set(h.EventPeriodUnits,'Visible','off' );
    end
    set(h.TrainQuantity,'String', num2str(lData.TrainQuantity));  
    set(h.TrainLevel,'String', num2str( lData.TrainLevel/1000000 ));  
    set(h.OffsetOrHold,'Value', int8(myAMS.values.offsetOrHold.( lData.OffsetOrHold ))+1);  
    Eid=get(h.EventID,'Value');
    if strcmp(lData.TrainType,'uniform')
        Lid=lData.UniformNumber; %AMS.LibID=AMS.EventList(Eid);
    else
        Lid=lData.EventList(Eid); %AMS.LibID=AMS.EventList(Eid);
    end
             
    set(h.LibID,'Value',Lid);
    EventIDNames='';
    for n=1:size(lData.EventList,2)
        set(h.EventList(n), 'Enable', 'on','BackgroundColor','white');
        if n == 1
        	set(h.EventList(n),'Value', lData.EventList(n))
        else
            set(h.EventList(n),'Value', lData.EventList(n)+1)
        end

        EventIDNames= strcat(EventIDNames,num2str(n));
        if n < size(lData.EventList,2)
             EventIDNames= strcat(EventIDNames,'|');
        end  
    end
    if n<20
       set(h.EventList(n+1), 'Enable', 'on','BackgroundColor','white');
    end

    set(h.EventListlbl,'Visible','on');
    if get(h.TrainType,'value') == vals.train.type.uniform
        for i=1:1:20
            set(h.EventList(i),'Visible','off' );
        end      
        set(h.Eventlistlbl,'Visible','off');
         set(h.EventID,'Visible','off' );       
         set(h.EvnetIDlbl,'Visible','off');
    end
    set( h.EventID,'string', EventIDNames);   
    TempType=int8(myAMS.values.event.type.(cell2mat(lData.EventType(Lid))))+1;
     set(h.EventType,'Value',TempType );
    set(h.EventQuantity,'String', num2str(lData.EventQuantity(Lid) ) );
    set(h.EventDelay,'String', num2str(lData.EventDelay(Lid)/1000 ) );
    set(h.EventDur1,'String', num2str(lData.EventDur1(Lid)/1000 ) );
    set(h.EventDur2,'String', num2str(lData.EventDur2(Lid)/1000 ) );
    set(h.EventDur3,'String', num2str(lData.EventDur3(Lid)/1000 ) );
    ep= lData.EventPeriod(Lid)/1000 ;
    set(h.EventPeriod,'String', num2str(ep) );
    set(h.EventFrequency,'string',num2str(1/ep) );
    set(h.EventAmp1,'String', num2str( lData.EventAmp1(Lid)/1000000 ) );
    set(h.EventAmp2,'String', num2str( lData.EventAmp2(Lid)/1000000 ) );
%     timeValues=[ str2double(get(h.TrainDelay,'String')), ...
%             str2double(get(h.TrainDur,'String')), ...
%             str2double(get(h.TrainPeriod,'String')), ...
%             str2double(get(h.EventDelay,'String')), ...
%             str2double(get(h.EventDur1,'String')), ...
%             str2double(get(h.EventDur2,'String')), ...
%             str2double(get(h.EventDur3,'String')), ...
%             str2double(get(h.EventPeriod,'String')) ];
%     k=find(timeValues);
%     stepmax=min(timeValues(k))/10;
%     ss= str2double(get(h.StepSize,'String'));
%     if ss>stepmax
%         set(h.StepSize,'String',num2str(stepmax));
%     else
%         set(h.StepSize,'String',num2str(ss));
%     end
    
       switch get(h.TrainType,'Value')
            case vals.train.type.uniform+1
                for i=1:1:20
                    set(h.EventList(i),'Visible','off' );
                end
                set(h.EventListlbl,'Visible','off' );
                set(h.EventID,'Visible','off');
                set(h.EventIDlbl,'Visible','off');
                set(h.LibID,'Visible','on');
                set(h.LibIDlbl,'Visible','on');
            case vals.train.type.mixed+1
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
        end
    
end
