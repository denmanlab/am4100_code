function LoadLibrary()
%Send the Local Data to the instrument for the first four library positions
global myAMS;
global lData;
h=guidata(gcf); %get graphic data

[values,idx]=ComConstants;

%%
    if myAMS.DoComms && myAMS.PortSuccess
        myAMS.loading=1;
        set(h.Active,'String',myAMS.Active);
        myAMS.Mode=values.mode.(lData.mode);
        myAMS.Trigger=values.trigger.(lData.Trigger);
        myAMS.Auto=values.auto.( lData.Auto);
        myAMS.Monitor=values.monitor.( lData.Monitor);
        myAMS.Sync1=values.sync.( lData.Sync1);
        myAMS.Sync2=values.sync.(lData.Sync2);
        myAMS.PeriodOrFreq=values.periodOrFreq.( lData.PeriodOrFreq);
        myAMS.TrainType=values.train.type.(lData.TrainType);
        myAMS.TrainDelay=lData.TrainDelay;
        myAMS.TrainDur=lData.TrainDur;
        myAMS.TrainPeriod=lData.TrainPeriod;
        myAMS.TrainQuantity=lData.TrainQuantity;
        myAMS.TrainLevel=lData.TrainLevel;
        myAMS.OffsetOrHold=values.offsetOrHold.( lData.OffsetOrHold);
        myAMS.EventList=[lData.EventList zeros(1,20-size(lData.EventList,2))-1];
        myAMS.UniformNumber=lData.UniformNumber;
        for Lid = 1:4
            myAMS.LibID=Lid;
            myAMS.EventType=values.event.type.(cell2mat(lData.EventType(Lid)));
            myAMS.EventQuantity=lData.EventQuantity(Lid);
            myAMS.EventDelay=lData.EventDelay(Lid);
            myAMS.EventDur1=lData.EventDur1(Lid);
            myAMS.EventDur2=lData.EventDur1(Lid);
            myAMS.EventDur3=lData.EventDur3(Lid);
            myAMS.EventPeriod=lData.EventPeriod(Lid);
            myAMS.EventAmp1=lData.EventAmp1(Lid);
            myAMS.EventAmp2=lData.EventAmp2(Lid);          
        end

        myAMS.loading=0;
    end

end
