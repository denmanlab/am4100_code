function error= checkTimes( )
%checkTimes - verifies AMS4100 time values are valid
%   verifies AMS4100 time values are valid and returns an error
% if they are not valid
h=guidata(gcf); %get graphic data
global lData;
values=ComConstants;

    error={0};
    error(2)={'Timing errors: '};
        [Err, Tdly, Tdur, Tper, Tqty, Etype, Eqty, Edly, Edur1, Edur2, Edur3, Eper] = ...
        getTimeValues(1); 
    InitialEventDelay=Edly;
    
    if get(h.TrainType,'Value') == values.train.type.mixed+1 % if mixed mode events
        sumEventPeriods=0;
        for i=1:size(lData.EventList,2)
            [~, ~, ~, ~, ~, Etype, Eqty, ~, Edur1, Edur2, Edur3, Eper] = ...
                   getTimeValues(i);
            sumEventPeriods=Eqty*Eper+sumEventPeriods;  % sum up all events 
        end
        if get(h.Auto,'Value')==values.auto.count+1  %Auto = count
            Tdur=sumEventPeriods+InitialEventDelay;
            Tper=Tdur;
        end
    else
        sumEventPeriods=Eqty*Eper;
    end
    if single(Tper)< single(Tdur) 
        error(1)={1};
        pos=size(error,2)+1;
        error(pos)={'Train Period must be bigger than Train Width'};
    end
    if single(Tdur) < single(InitialEventDelay+sumEventPeriods) 
        error(1)={1};
        pos=size(error,2)+1;
        error(pos)={'Train Width must be bigger than Event Periods* Event Number + Initial Delay'};
    end  
    if single(Eper) < single(Edur1+Edur2+Edur3) 
        error(1)={1};
        pos=size(error,2)+1;
         error(pos)={'Event Period must be bigger that sum of all event widths'};
    end

end

