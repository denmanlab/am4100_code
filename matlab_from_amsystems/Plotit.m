function Plotit(hObject, eventdata)
    h=guidata(gcf); %get graphic data
    hold(h.thingy,'off');
    global lEventList;
    global lData;
    values=ComConstants;
    colors={'b','c','y','k'};
%%  Set the Graph Y amplitude heights
% Get default hold level:
    oORh=get(h.OffsetOrHold,'Value');
    Tlev=str2double(get(h.TrainLevel,'String'));
    
    TrainCntMax=2;
    EventCntMax=TrainCntMax*20;
%Get amplitude values
    [Atp, AmpNoDur ,AmpDur1, AmpDur2, AmpDur3]=getOffsetAmps(1);
    
%figure out y graph scaling    
    ys=[  Atp, AmpNoDur ,AmpDur1, AmpDur2, AmpDur3];
    dyg=max(abs(ys))/4;
    ymaxUI=str2double(get(h.Ymax,'String'));
    yminUI=str2double(get(h.Ymin,'String'));
    ymax=max(ys)+ dyg;
    ymin=min(ys)- dyg;
    if ymaxUI < max(ys)+ dyg
        set(h.Ymax,'String',num2str(ymax));
    else
        set(h.Ymax,'String',num2str(ymaxUI));
        ymax=ymaxUI;
    end
    if yminUI > min(ys)+ dyg
        set(h.Ymin,'String',num2str(ymin));
    else
        set(h.Ymin,'String',num2str(yminUI));
        ymin=yminUI;
    end
    set(h.Ymin,'String',num2str(ymin));

%%  Set the Graph X time lengths
% Get time values from the first event in the event list also ==
% uniform event
    Errors=checkTimes();
    Err=cell2mat(Errors(1));
    if Err
        cla(h.thingy);
        cla(h.Igraph);
        cla(h.showSignal);
        msgbox(Errors(2:size(Errors,2)));
        return;
    end  % if there is an error in gettimevalues exit plot. 
    
    
    [~, Tdly, Tdur, Tper, Tqty, Etype, Eqty, Edly, Edur1, Edur2, Edur3, Eper] = ...
        getTimeValues(1);    

    InitialEventDelay=Edly;
    if get(h.TrainType,'Value') == values.train.type.mixed+1 % if mixed mode events
        sumEventPeriods=0;
        sumEventPeriodsWithDelays=0;
        for i=1:size(lData.EventList,2)
            [~, ~, ~, ~, ~, Etype, Eqty, Edly Edur1, Edur2, Edur3, Eper] = ...
                   getTimeValues(i);
            sumEventPeriods=Eqty*Eper+sumEventPeriods;  % sum up all events 
            sumEventPeriodsWithDelays=Eqty*Eper+Edly+sumEventPeriodsWithDelays;
        end
        if get(h.Auto,'Value')==values.auto.count+1  %Auto = count
            Tdur=sumEventPeriodsWithDelays;
            Tper=Tdur;
        end
    end

% get step size and time length
    vals=[Edly Edur1 Eper Edur2 Tdly];
    vals(~vals)=inf;  % makes 0 values infinity
    EtotalDur=Edur1+Edur2+Edur3;
    Ediff=Eper-Edur1-Edur2-Edur3;
    timeVals=[Tdly, Tdur, Tper, Edly, Edur1, Edur2, Edur3, Eper, Ediff] ;
     k=find(timeVals);  % finds non zero values of timeVals
    EOT=Tper*(Tqty)+Tdly+min(timeVals(k))*4;
    if EOT>2000
        EOT=2000;
    end
%% Ramp values for uniform event
%     if Etype == values.event.type.ramp+1   % get ramp values
%         R1slope=(AmpDur1-AmpNoDur)/Edur1;
%         if Edur2==0 
%             R2slope=500*10^6;
%         else
%             R2slope=(AmpDur3-AmpDur1)/Edur2;
%         end
%         if Edur3 ==0
%              R3slope=500*10^6;
%         else
%              R3slope=(AmpNoDur-AmpDur3)/Edur3;
%         end
%     end    
    
%% figure out Train Dur and TotalEventDur    
   if get(h.TrainType,'Value') == values.train.type.mixed+1 % if mixed mode events
        Eqtys=zeros(1,size(lData.EventList,2));
        sumEventPeriods=0;
        sumEventPeriodsWithDelays=0;
        sumEventQtys=0;
        for i=1:size(lData.EventList,2)
            [~, ~, ~, ~, ~, Etype, Eqty, Edly, Edur1, Edur2, Edur3, Eper] = ...
                   getTimeValues(i);
            sumEventPeriods=Eqty*Eper+sumEventPeriods;  % sum up all events 
            sumEventPeriodsWithDelays=Eqty*Eper+Edly+sumEventPeriodsWithDelays;
            sumEventQtys=sumEventQtys+Eqty;
        end
        switch get(h.Auto,'Value')
            case values.auto.none+1
                MixedEventQty=1;
            case values.auto.count+1
                MixedEventQty=1;
                Tdur=sumEventPeriodsWithDelays;
                Tper=Tdur;
            case values.auto.fill+1
                MixedEventQty=floor((Tdur-InitialEventDelay)/sumEventPeriods);
                Tper=Tdur;  
        end
         EOTcount=(Tqty*(MixedEventQty*sumEventQtys*4+1))*2+2;
   else
        switch get(h.Auto,'Value')
            case values.auto.none+1
                sumEventPeriods=Eqty*Eper;
            case values.auto.count+1
                sumEventPeriods=Eqty*Eper;
                Tdur=sumEventPeriods+InitialEventDelay;
                Tper=Tdur;
            case values.auto.fill+1
                Eqty=floor((Tdur-InitialEventDelay)/Eper);
                sumEventPeriods=Eqty*Eper;
                Tdur=sumEventPeriods+InitialEventDelay;
                Tper=Tdur;
        end
        EOTcount=(Tqty*(Eqty*4+1))*2+2;
   end  
  
%% fill main graph arrays
%     time=0:dt:EOT;
%     tsize=length(time);
%     ampOut=zeros(1,tsize);
%     if oORh == 1 
%          ampOut(:)=Tlev;
%     end
if EOTcount>2000
    EOTcount=2000;
end
ampOut=zeros(1,EOTcount);
time=zeros(1,EOTcount);
%% make graph boxes
    hold(h.thingy,'off');
    plot(h.thingy,[0,EOT],[0,0],'k');
    hold(h.thingy,'on');
    plot(h.thingy,[0,EOT],[7,7],'k');
    ylim(h.thingy,[0,7]);
    grid(h.thingy,'minor');
    plot(h.thingy,[0 0],[0 7],'k','LineWidth',2);  
    n=0;
%% Start Plots
  % train delay  *************************
    pTdly(1)=0;
    pTdly(2)=Tdly;
     plot(h.thingy,pTdly,[6 6],'-+m','LineWidth',4,'MarkerSize',8); %***PLOT TRAIN DELAY***
     n=n+1; time(n)=0; ampOut(n)=Atp;                              %***GRAPH TRAIN DELAY***
     n=n+1; time(n)=Tdly; ampOut(n)=Atp;
    ppp=zeros(1,2);pTw=zeros(1,2);pTp=zeros(1,2);
  % train period  **********************************************************************
  TrainForCount=0;
  breakflag=0;
  InitialDelay=1;
    for TrainCount=1:Tqty
        FirstEventInTrain=1;
        TrainForCount=TrainForCount+1;
        if TrainForCount>TrainCntMax
            breakflag=1;
            break
        end
        TrainCountShift=(TrainCount-1)*Tper;
        pEdly(1)=Tdly+TrainCountShift;
        pEdly(2)=pEdly(1)+InitialEventDelay;
        plot(h.thingy,pEdly,[3 3],'-+m','LineWidth',4,'MarkerSize',8); %***PLOT EVENT DELAY***
        pTw(1)=Tdly+TrainCountShift;
        pTw(2)=pTw(1)+Tdur;
        plot(h.thingy,pTw,[4 4],'-+r','LineWidth',4,'MarkerSize',8); %***PLOT TRAIN WIDTH***
        pTp(1)=Tdly+TrainCountShift;
        pTp(2)=pTp(1)+Tper;
        plot(h.thingy,pTp,[5 5],'-+g','LineWidth',4,'MarkerSize',8); %***PLOT TRAIN PERIOD***
        n=n+1; time(n)=pEdly(1); ampOut(n)=AmpNoDur;                %***GRAPH EVENT DELAY***
        n=n+1; time(n)=pEdly(2); ampOut(n)=AmpNoDur;   
        EventForCount=0;
        if get(h.TrainType,'Value') == values.train.type.mixed+1 % if mixed mode events
            for StimCount=1:MixedEventQty
              if TrainForCount*EventForCount>EventCntMax
                    breakflag=1;
                    break
              end
                StimCountShift=(StimCount-1)*sumEventPeriods;
                MixedEventShift=0;
                c=0;
                for MixedEid=1:size(lData.EventList,2)
                    EventForCount=EventForCount+1;
                    if TrainForCount*EventForCount>EventCntMax
                        break
                    end
                    [~, ~, ~, ~, ~, Etype, Eqty, Edly, Edur1, Edur2, Edur3, Eper] = ...
                        getTimeValues(MixedEid);
                    [Atp, AmpNoDur ,AmpDur1, AmpDur2, AmpDur3]=getOffsetAmps(MixedEid);
                    EtotalDur=Edur1+Edur2+Edur3;
                    c=c+1;
                    if c>4
                        c=1;
                    end
                    if get(h.Auto,'Value')~= values.auto.fill+1
                        if FirstEventInTrain
                            FirstEventInTrain=0;
                        else
                            pEdly(1)=Tdly+TrainCountShift+MixedEventShift;
                            pEdly(2)=pEdly(1)+Edly;
                            plot(h.thingy,pEdly,[3 3],'-+m','LineWidth',4,'MarkerSize',8); %***PLOT EVENT DELAY***
                            n=n+1; time(n)=pEdly(1); ampOut(n)=AmpNoDur;                %***GRAPH EVENT DELAY***
                            n=n+1; time(n)=pEdly(2); ampOut(n)=AmpNoDur;  
                        end 
                    else
                        if ~InitialDelay
                            pEdly(1)=Tdly+TrainCountShift+MixedEventShift;
                            pEdly(2)=pEdly(1);
                        end

                    end
                    for EventCount=1:Eqty
                        EventCountShift=(EventCount-1)*Eper;
                        pew(1)=pEdly(2)+EventCountShift+StimCountShift;
                        pew(2)=pew(1)+EtotalDur;
                        plot(h.thingy,pew,[1 1],['-+' cell2mat(colors(c))],'LineWidth',4,'MarkerSize',8); % Event Width     
                        ppp(1)=pEdly(2)+EventCountShift+StimCountShift;
                        ppp(2)=ppp(1)+Eper;
                        plot(h.thingy,ppp,[2 2],'-+g','LineWidth',4,'MarkerSize',8); % Event Period
                        if Etype == values.event.type.ramp+1
                            n=n+1; time(n)=pew(1); ampOut(n)=AmpNoDur;   %***GRAPH EVENT DUR1***
                            n=n+1; time(n)=pew(1)+Edur1; ampOut(n)=AmpDur1;
                            n=n+1; time(n)=pew(1)+Edur1; ampOut(n)=AmpDur1;   %***GRAPH EVENT DUR2***
                            n=n+1; time(n)=pew(1)+Edur1+Edur2; ampOut(n)=AmpDur3; 
                            n=n+1; time(n)=pew(1)+Edur1+Edur2; ampOut(n)=AmpDur3;   %***GRAPH EVENT DUR3***
                            n=n+1; time(n)=pew(2); ampOut(n)=AmpNoDur; 
                            n=n+1; time(n)=pew(2); ampOut(n)=AmpNoDur;   %***GRAPH EVENT POST WIDTH***
                            n=n+1; time(n)=ppp(2); ampOut(n)=AmpNoDur;                             
                        else
                            n=n+1; time(n)=pew(1); ampOut(n)=AmpDur1;   %***GRAPH EVENT DUR1***
                            n=n+1; time(n)=pew(1)+Edur1; ampOut(n)=AmpDur1;
                            if Etype == values.event.type.monophasic+1
                                n=n+1; time(n)=pew(1)+Edur1; ampOut(n)=AmpNoDur;   %***GRAPH POS MONO***
                                n=n+1; time(n)=pew(2); ampOut(n)=AmpNoDur; 
                            else
                                n=n+1; time(n)=pew(1)+Edur1; ampOut(n)=AmpDur2;   %***GRAPH EVENT DUR2***
                                n=n+1; time(n)=pew(1)+Edur1+Edur2; ampOut(n)=AmpDur2; 
                                n=n+1; time(n)=pew(1)+Edur1+Edur2; ampOut(n)=AmpDur3;   %***GRAPH EVENT DUR3***
                                n=n+1; time(n)=pew(2); ampOut(n)=AmpDur3; 
                            end
                            n=n+1; time(n)=pew(2); ampOut(n)=AmpNoDur;   %***GRAPH EVENT POST WIDTH***
                            n=n+1; time(n)=ppp(2); ampOut(n)=AmpNoDur; 
                        end

                    end
                    if get(h.Auto,'Value')~= values.auto.fill+1
                      MixedEventShift=Eper*Eqty+MixedEventShift+Edly;
                    else
                        if InitialDelay                          
                            InitialDelay=0;
                            MixedEventShift=Eper*Eqty+MixedEventShift+Edly;
                        else
                            MixedEventShift=Eper*Eqty+MixedEventShift;
                        end
                    end
                end
            end
        else
            for EventCount=1:Eqty
                EventForCount=EventForCount+1;
                if TrainForCount*EventForCount>EventCntMax
                    breakflag=1;
                    break
                end
                EventCountShift=(EventCount-1)*Eper;
                pew(1)=pEdly(2)+EventCountShift;
                pew(2)=pew(1)+EtotalDur;
                plot(h.thingy,pew,[1 1],'-+b','LineWidth',4,'MarkerSize',8); % Event Width     
                ppp(1)=pEdly(2)+EventCountShift;
                ppp(2)=ppp(1)+Eper;
                plot(h.thingy,ppp,[2 2],'-+g','LineWidth',4,'MarkerSize',8); % Event Period
                if Etype == values.event.type.ramp+1
                    n=n+1; time(n)=pew(1); ampOut(n)=AmpNoDur;   %***GRAPH EVENT DUR1***
                    n=n+1; time(n)=pew(1)+Edur1; ampOut(n)=AmpDur1;
                    n=n+1; time(n)=pew(1)+Edur1; ampOut(n)=AmpDur1;   %***GRAPH EVENT DUR2***
                    n=n+1; time(n)=pew(1)+Edur1+Edur2; ampOut(n)=AmpDur3; 
                    n=n+1; time(n)=pew(1)+Edur1+Edur2; ampOut(n)=AmpDur3;   %***GRAPH EVENT DUR3***
                    n=n+1; time(n)=pew(2); ampOut(n)=AmpNoDur; 
                    n=n+1; time(n)=pew(2); ampOut(n)=AmpNoDur;   %***GRAPH EVENT POST WIDTH***
                    n=n+1; time(n)=ppp(2); ampOut(n)=AmpNoDur;                             
                else
                    n=n+1; time(n)=pew(1); ampOut(n)=AmpDur1;   %***GRAPH EVENT DUR1***
                    n=n+1; time(n)=pew(1)+Edur1; ampOut(n)=AmpDur1;
                    if Etype == values.event.type.monophasic+1
                        n=n+1; time(n)=pew(1)+Edur1; ampOut(n)=AmpNoDur;   %***GRAPH POS MONO***
                        n=n+1; time(n)=pew(2); ampOut(n)=AmpNoDur; 
                    else
                        n=n+1; time(n)=pew(1)+Edur1; ampOut(n)=AmpDur2;   %***GRAPH EVENT DUR2***
                        n=n+1; time(n)=pew(1)+Edur1+Edur2; ampOut(n)=AmpDur2; 
                        n=n+1; time(n)=pew(1)+Edur1+Edur2; ampOut(n)=AmpDur3;   %***GRAPH EVENT DUR3***
                        n=n+1; time(n)=pew(2); ampOut(n)=AmpDur3; 
                    end                     
                    n=n+1; time(n)=pew(2); ampOut(n)=AmpNoDur;   %***GRAPH EVENT POST WIDTH***
                    n=n+1; time(n)=ppp(2); ampOut(n)=AmpNoDur; 
                end
            end
        end
       if breakflag
           EOT=time(n);
       else
            n=n+1; time(n)=ppp(2); ampOut(n)=AmpNoDur;   %***GRAPH POST EVENT PERIOD***
            n=n+1; time(n)=pTw(2); ampOut(n)=AmpNoDur;   
            n=n+1; time(n)=pTw(2); ampOut(n)=Atp;   %***GRAPH POST TRAIN WIDTH***
            n=n+1; time(n)=pTp(2); ampOut(n)=Atp;
            time=time(1:n);
            ampOut=ampOut(1:n);
       end
        EOT=time(n);
    end
    
    %% Setup Graphs
    cla(h.showSignal,'reset');
    %  time=0:dt:EOT;
%     time=0:dt:length(ampOut)*dt;
%     EOT=time(length(ampOut))+time(length(ampOut))/20;
    plot(h.showSignal,time,ampOut);
    xlim(h.showSignal,[-min(vals)*2, EOT]);
    ylim(h.showSignal,[ymin,ymax]);
    grid(h.showSignal,'minor');
    hold(h.showSignal,'on');
    plot(h.showSignal,[0 0],[ymin ymax],'k','LineWidth',2);  
    hold(h.showSignal,'off');
    xlim(h.thingy,[-min(vals)*2, EOT]);
   if breakflag
       text(EOT/2,ymax-ymax/10,'FORCE GRAPH QUIT','Color','red','FontSize',14)
   end
    
    %% Start Event Graph   
    switch get(h.EventType,'value')
        case values.event.type.monophasic+1   %monophasic
            set(h.EventDur2,'Visible','off');
            set(h.EventDur2lbl,'Visible','off');
            set(h.EventDur2Units,'Visible','off');
            set(h.EventDur3,'Visible','off');
            set(h.EventDur3lbl,'Visible','off');
            set(h.EventDur3Units,'Visible','off');
            set(h.EventAmp2,'Visible','off');
            set(h.EventAmp2lbl,'Visible','off');  
            set(h.EventAmp2Units,'Visible','off');
            DrawMonophasic();
        case values.event.type.biphasic+1
            set(h.EventDur2,'Visible','on');
            set(h.EventDur2lbl,'Visible','on');
            set(h.EventDur2Units,'Visible','on');
            set(h.EventDur3,'Visible','off'); %off *********************************************************
            set(h.EventDur3lbl,'Visible','off');  %off
            set(h.EventDur3Units,'Visible','off');
            set(h.EventAmp2,'Visible','off'); %off
            set(h.EventAmp2lbl,'Visible','off');  %off 
            set(h.EventAmp2Units,'Visible','off');
            DrawBiphasic();
        case values.event.type.assymetric+1
            set(h.EventDur2,'Visible','on');
            set(h.EventDur2lbl,'Visible','on');
            set(h.EventDur2Units,'Visible','on');
            set(h.EventDur3,'Visible','on');
            set(h.EventDur3lbl,'Visible','on');
            set(h.EventDur3Units,'Visible','on');
            set(h.EventAmp2,'Visible','on');
            set(h.EventAmp2lbl,'Visible','on');  
            set(h.EventAmp2Units,'Visible','on');
            DrawBiphasic();
        case values.event.type.ramp+1%ramp
            set(h.EventDur2,'Visible','on');
            set(h.EventDur2lbl,'Visible','on');
            set(h.EventDur3,'Visible','on');
            set(h.EventDur3lbl,'Visible','on');
            set(h.EventDur3Units,'Visible','on');
            set(h.EventAmp2,'Visible','on');
            set(h.EventAmp2lbl,'Visible','on');  
            set(h.EventAmp2Units,'Visible','on');
            DrawRamp();
    end
 
    
end