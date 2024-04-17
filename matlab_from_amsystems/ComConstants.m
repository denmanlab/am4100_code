function [ values, constants ] = ComConstants( inrev )
%COMCONSTANTS the file with the instrument constants
%   Retrurns a structure of constants based on the revision of the
%   instrument
switch nargin
    case 0,
        rev=1;
    otherwise
        rev=inrev;
end

    switch rev
        case 1
            constants.menu.general= 0;
            constants.menu.config =1;
            constants.menu.IPAddr=3;
            constants.menu.uniformevent=4;
            constants.menu.train=7;
            constants.menu.eventlist=8;
            constants.menu.event=10;
            
            values.menupage.general=0;
            values.menupage.config =1;
            values.menupage.IPAddr=3;
            values.menupage.train=7;
            values.menupage.eventlist=8;
            values.menupage.event=10;
                
            constants.general.mode=0;
            constants.general.monitor=1;
            constants.general.trigger=2;
            constants.general.auto=3;
            constants.general.save=4;
            constants.general.isoOutput=5;
                        

            values.mode.intVolt=0;
            values.mode.intCurrent=1;
            values.mode.ext20VperV =2;
            values.mode.ext10mAperV =3;
            values.mode.ext1mAperV =4;
            values.mode.ext100uAperV =5;
            
            values.monitor.scale_100mVperV=0;
            values.monitor.scale_1VperV=1;
            values.monitor.scale_10VperV=2;
            values.monitor.scale_20VperV=3;
            values.monitor.scale_10uAperV =4;
            values.monitor.scale_100uAperV =5;
            values.monitor.scale_1mAperV =6;
            values.monitor.scale_10mAperV =7;
            
            values.trigger.rising=0;
            values.trigger.falling=1;
            
            values.auto.none=0;   
            values.auto.count=1; 
            values.auto.fill=2;        
            
            values.isoOutput.on=0;
            values.isoOutput.off=1;

            constants.config.periodOrFreq=0;
            constants.config.sync1=1;
            constants.config.sync2=2;
            constants.config.serialnum=6;
            
            values.periodOrFreq.period=0; 
            values.periodOrFreq.frequency=1; 
                        
            values.sync.trainDelay=0;
            values.sync.trainDuration=1;
            values.sync.eventDelay=2;
            values.sync.eventDuration1=3;
            values.sync.eventDuration2=4;
            values.sync.eventDuration3=5;
            values.sync.eventTotalDur=6;
            values.sync.clockus=7;
            values.sync.clockms=8;
            
            constants.uniformevent.number=0;
            
            constants.train.type=0;
            constants.train.delay =1;
            constants.train.duration =2;
            constants.train.period =3;
            constants.train.quantity =4;
            constants.train.offsetOrHold =5;
            constants.train.level =6;
            
            values.train.type.uniform=0;
            values.train.type.mixed=1;
            
            values.offsetOrHold.hold=0;
            values.offsetOrHold.offset=1;


            constants.event.type=2;
            constants.event.delay=3;
            constants.event.quantity=4;
            constants.event.period=5;            
            constants.event.dur1=6;
            constants.event.dur2=8;
            constants.event.dur3=9;
            constants.event.amp1=7;
            constants.event.amp2=10;       
       
            values.event.type.monophasic=0;
            values.event.type.biphasic=1;
            values.event.type.assymetric=2;
            values.event.type.ramp=3;
    end 
end



