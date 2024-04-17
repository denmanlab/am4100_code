function UpdateEvents()
    global myAMS;
    h=guidata(gcf); %get graphic data
    global lData;
    if myAMS.DoComms && myAMS.PortSuccess
            set(h.Active,'String',myAMS.Active);
%             Eid=myAMS.EventID;
            Eid=int16(get(h.EventID,'Value'));
            Lid=myAMS.EventList(Eid);
            lData.EventType(Lid)={myAMS.EventType};
            lData.EventQuantity(Lid)=myAMS.EventQuantity;
            lData.EventDelay(Lid)=myAMS.EventDelay;
            lData.EventDur1(Lid)=myAMS.EventDur1;
            lData.EventDur2(Lid)=myAMS.EventDur2;
            lData.EventDur3(Lid)=myAMS.EventDur3;
            lData.EventPeriod(Lid)=myAMS.EventPeriod;
            lData.EventAmp1(Lid)=myAMS.EventAmp1;
            lData.EventAmp2(Lid)=myAMS.EventAmp2;
        else   
            Lid=get(h.LibID,'Value');
            set(h.Active,'String','No Instrument');
    end   
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
end
