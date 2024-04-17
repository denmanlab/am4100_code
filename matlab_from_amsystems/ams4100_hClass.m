classdef ams4100_hClass < matlab.mixin.SetGet    
    %ams4100 handle Class for A-M systems Model 4100
    %   a class to interface with A-M Systems Model 4100
    %   Instrument Amplifiers.
    %   
    %  Each proprtey can be written to or read from and it will send data
    %  to the instrument if connected  
    %  Rev 1.x  First released Revision
    %  Rev 2.x  Added PIN number, and included PIN in SendReceiveString
    %       .2  Changed train and event num to max 99999 Added MatlabRev
    %  Rev 3.x  Add open and close relay commands  
    %  Rev 4.x  Ethernet Communication with tcpclient instead of JAVA
    
    %%  Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Dependent)
	Active              % Active status 
    Mode              % mode type       EXAMPLE: handle.mode =3;  or handle.mode = mode.intVolt; 
    TrainType           % Train type   EXAMPLE: handle.TrainType =1;  or  handle.TrainType = tType.simple; 
    TrainDelay          % Train Delay in us	Valid values are: 0 to 9,360,000,000    EXAMPLE: handle.TrainDelay =5000;   (5ms)
    TrainDur            % Train Duration in us	Valid values are: 0 to 9,360,000,000    EXAMPLE: handle.TrainDur=5000; (5ms) 
    TrainPeriod         % Train Period in us	Valid values are: 0 to 9,360,000,000    EXAMPLE: handle.TrainPeriod =5000;  (5ms)
    TrainQuantity       % Train Quantity    Valid values are: 0 to 100    EXAMPLE: handle.TrainQuantity =11;
    TrainLevel           % Train Level in uV	Valid values are: 0 to 200,000,000    EXAMPLE: handle.TainLevel =5000;  (5mV)
    TrainFrequency      % Train Frequency in HZ	Valid values are: 1,000,000/2  to 1,000,000/9,360,000,000 Hz    EXAMPLE: handle.TrainFrequency =67; (Hz)
    OffsetOrHold        % Set train level as offset or hold     EXAMPLE: handle.OffsetOrHold =1;  or  handle.OffsetOrHold = offsetOrHold.hold; 
    EventType           % The type of event for the current LibID .   EXAMPLE: handle.EventType =1;  or   handle.EventType = eType.biphasic;
    EventDelay          % Event Delay for the current LibID in us	Valid values are: 0 to 9,360,000,000    EXAMPLE: handle.EventDelay =5000;   (5ms)
    EventDur1      % Event Duration1 for the current LibID  in us	Valid values are: 0 to 9,360,000,000    EXAMPLE: handle.EventDuration1 =5000;   (5ms)
    EventDur2     % Event Duration2 for the current LibID in us	Valid values are: 0 to 9,360,000,000    EXAMPLE: handle.EventDuration2 =5000;   (5ms)    
    EventDur3      % Event Duration3 for the current LibID in us	Valid values are: 0 to 9,360,000,000    EXAMPLE: handle.EventDur3 =5000;   (5ms)
    EventPeriod         % Event Period for the current LibID in us	Valid values are: 0 to 9,360,000,000    EXAMPLE: handle.EventPeriod =5000;   (5ms)
    EventQuantity       % Event Quantity for the current LibID    Valid values are: 0 to 100    EXAMPLE: handle.EventQuantity = 12;
    EventFrequency      % Event Frequency for the current LibID in HZ	Valid values are: 1,000,000/2  to 1,000,000/9,360,000,000 Hz    EXAMPLE: handle.EventFrequency =67; (Hz)
    EventAmp1      % Event Amplitude1 for the current LibID in uV	Valid values are: 0 to 200,000,000    EXAMPLE: handle.EventAmp1 =5000;  (5mV)
    EventAmp2     % Event Amplitude2 for the current LibID in uV	Valid values are: 0 to 200,000,000    EXAMPLE: handle.EventAmp2 =5000;  (5mV)
    EventList           % List the LibID location for mixed event types

    IsoOutput           % Sets the ISOout to zero when off or normal when on timing contiues on or off
    Auto                % Variable Auto complete 	EXAMPLE: handle.Auto =1; or  handle.Auto =auto.fixed;  
	Trigger             % Trigger type      EXAMPLE: handle.Trigger =1; or handle.Trigger =trigger.rising; 
    Monitor             % BNC Monitor mode scale   EXAMPLE: handle.Monitor =1;  or handle.Monitor = monitor.scale1VperV; 
    Sync1               % BNC Sync1 source      EXAMPLE: handle.Sync1 =1;  or handle.Sync1 =sync.eventPeriod; 
    Sync2               % BNC Sync2 source      EXAMPLE: handle.Sync2 =1;  or handle.Sync2 =sync.eventPeriod; 
    PeriodOrFreq        % Frequecy input style    EXAMPLE: handle.PeriodOrFreq =1; or  handle.PeriodOrFreq = periodOrFreq.frequency; 
    UniformNumber  
%     EventID             % loads the event data if it exists in the event list when in train type mixed.
    LibID               % loads the library into current event and updates event list for that new library position.

    HighVflag
    HighIflag
    Generating
    Running
    EnableButtonIn
    
    PIN                 % communication PIN number
    DoComms             % If true then communication with the instrument will occur, if false then no commuication

   % Libraries           % All the Event Data saved in the libraries [LibID Type Delay Dur1 Dur2 Per Quant Freq Int Amp1 Amp2 Sym] 
    end
    properties (Access=private)
    priv_PIN=1001;
	priv_Active='';
    priv_Output='intVolt';
	priv_Trigger='rising';
	priv_Auto='none';
    priv_Monitor='scale1VperV';
    priv_Sync1='trainDuration';myAMS
    priv_Sync2='eventDuration1';
    priv_PeriodOrFreq='period';
    priv_TrainType='uniform';
    priv_TrainDelay=0;
    priv_TrainDur=0;
    priv_TrainPeriod=0;
    priv_TrainQuantity=0;
    priv_TrainLevel=0;
    priv_TrainFrequency=0;
    priv_OffsetOrHold='offset';
%     priv_EventID=1;
    priv_LibID=1;
    priv_EventType='monophasic';
    priv_EventDelay=0;
    priv_EventDur1=0;
    priv_EventDur3=0;
    priv_EventPeriod=0;
    priv_EventQuantity=0;
    priv_EventFrequency=0;
    priv_EventDur2=0;
    priv_EventAmp1=0;
    priv_EventAmp2=0;
    priv_EventList=[1:20];
    priv_IsoOutput=0;  % 0 is on
    priv_UniformNumber=1;
    priv_HighVflag=0;
    priv_HighIflag=0;
    priv_Generating=0;
    priv_Running=0;
    priv_EnableButtonIn=0;
    PortEthernet=0; % 1 for ethernet
    PortSerial=0;  % 1 for serial
    etherfctr=100;  %how much faster the ethernet should be compared to USB
    CONST;
    priv_DoComms = true;
   % [LibID Type Delay Dur1 Dur2 Dur3 Quant Per Freq Amp1 Amp2 Sym] Note
   % priv_Libraries=[(1:20)' zeros(20,1,'uint8') zeros(20,4,'uint64') zeros(20,1,'uint8') zeros(20,4,'uint64') zeros(20,1,'uint8')];
end
    properties (SetAccess=protected)
        PortSuccess=0;
        Revision='';
        Network='';
        SerialNumber='';
        values;
        MCUrev=0;
        MatlabRev='4.0';
    end
    properties
        loading=0;  % a variable that is set to 1 if the entire library data set is being loaded. turns off start and stop
        Port;       %
        PortInfo;   %
        ActiveComms=0; %  a flag that goes high during active communication to the instrument
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Public Methods
methods 
%% costructor
function obj = ams4100_hClass(amsPort,amsPIN,startCOMS)
        % ams4100 - Constructor for the class
        %
        %   obj = AMS4100(amsPort) creates a handle to an
        %   instance of the AMS4100 Class. The instance is set to be
        %   associated with the Instrument that is paired with the com port
        %   defined in the input amsPort.
        %
        %   SYNOPSIS: obj =AMS4100(amsPort)
        %
        %   INPUT: amsPort - string value defining the numeric value of the
        %                    desired Com Port or IP address
        %         amsPIN  - a pin number up to 5 digits set on the instrument to allow setting values
        %         startCOMS - if false then there will be no communication with instrument
        %
        %   mode: obj - handle to the instance of the
        %                         AMS4100 Class
        %
        %   EXAMPLE: handle = AMS4100('COM7');
        %
        [obj.values, obj.CONST]=ComConstants; % load default rev constants
        switch nargin
            case 2,
                 obj.Port=amsPort;
                 obj.PIN=amsPIN;
                 obj.DoComms=true;  
            case 1,
                obj.Port=amsPort;
                 obj.PIN=1001;
                 obj.DoComms=true;                          
            case 0,
                %[obj.PortSuccess, obj.PortInfo]=testams(obj,amsPort);
                %             comports=cellstr(serialportlist);
                %            obj.Port=cell2mat(comports(1));
             obj.Port='COMNONE';
             obj.PIN=1001;
             obj.DoComms=false;
            otherwise
                obj.Port=amsPort;
                obj.PIN=amsPIN;
                obj.DoComms=startCOMS;
        end
        if iscell(obj.Port)
            obj.Port=cell2mat(obj.Port);
        end
        if length(obj.Port)<3
            obj.Port='COMnone';
        end
     try
         if strcmpi(obj.Port(1:3),'COM')   % IF COM PORT
            fprintf('setting up port %s with pin %i\r' ,obj.Port, obj.PIN);
            obj.PortEthernet=0;  
            if ~strcmp(obj.Port,'COMNONE')
                obj.PortInfo=serialport(obj.Port,115200);  % port and baud rate
                pause(1); % and give it a bit of time to set up
                obj.PortInfo.Timeout=10;  %wait up to 10 seconds for a reply
                obj.PortInfo.DataBits=8;  
                obj.PortInfo.StopBits=1;
                obj.PortInfo.Parity='odd';
                configureTerminator(obj.PortInfo,42,'CR'); % termintor for readline,writeline
                flush(obj.PortInfo);
                writeline(obj.PortInfo,'get rev');
                pause(0.1);  % wait for transmission]
                count=obj.PortInfo.NumBytesAvailable;
                if( count>10) obj.PortSerial=1; else obj.PortSerial=0; end
            else
                count=0;
                obj.PortSerial=0;
                obj.PortInfo=[];
            end     
         else  % ELSE IT IS TELNET
            disp('setting up TCP client');
            t=tcpclient(obj.Port,23,"Timeout",20,"ConnectTimeout",30);
            if exist('t','var')
                obj.PortInfo=t;
                pause(0.5);  % wait for wakeup and get ready to clear buffer
                clear t;
                read(obj.PortInfo);   % empties buffer
                write(obj.PortInfo,uint8(sprintf('get rev \r')))
                pause(0.1);  % wait for transmission]
                count=obj.PortInfo.BytesAvailable;
                if( count>10) obj.PortEthernet=1; else obj.PortEthernet=0; end
            else
                count=0;
                obj.PortEthernet=0;
                obj.PortInfo=[];
            end
         end
         %****************************************
        if count > 12
            obj.PortSuccess=1;
            outStr=readReply(obj);
            lines=strfind(outStr,'~');
            if length(lines)>1
                outStr=outStr(lines(1)+1:lines(2)-1);
            end
            obj.Revision=outStr;
            obj.MCUrev=getMCUrev(obj);  % gets a the single digit number after the 'M'
            obj.Network=SendReceiveString(obj,'g n');
            obj.SerialNumber=SendReceiveString(obj,'g m 1 6');
            UpdateEventList(obj);
        else
           obj.PortSuccess=0;
           disp('No data connection was obtained')
        end   
         
    catch ME
        if obj.PortEthernet
            % no need for ethernet close
        else
            % no need for serialport close
        end
        obj.PortEthernet=0;
        obj.PortSerial=0;
        obj.PortSuccess=0;
        warning('No Instrument communication')
       error(ME.identifier, 'Connection Error: %s', ME.message)
     end
end
%% destructor
function delete(obj)
         if obj.PortEthernet
                % destroying the object should clear the ethernet port
         else
                % destroying the object should clear the serialport
        end   

end
%% Get/Set Properties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.DoComms(obj)
    % The DoComm property 
    %
    % Valid values are:
    % False= no communication with instrument
    % True = communication with instrumet
    %
    out=obj.priv_DoComms;
end
function obj=set.DoComms(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >1 || min(value)<0
         error('DoComms must be between 0 and 1');
     else
             obj.priv_DoComms=value;
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.PIN(obj)
    % The PIN property 
    %
    % Valid values are:
    % 0 to 9999
    %
    out=obj.priv_PIN;
end
function obj=set.PIN(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >9999 || min(value)<1
         error('DoComms must be between 1 and 9999');
     else
             obj.priv_PIN=value;
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.Mode(obj)
    % The mode property sets the mode type
    %
    % Valid values are from ComConstants.m:
    %   EXAMPLE: handle.mode =3;  
    %   EXAMPLE: handle.mode = handle.values.mode.intVolt;  
    %
    obj.priv_Output=obj.GetInfo(obj.CONST.menu.general,obj.CONST.general.mode,obj.priv_Output);
    out=obj.priv_Output;
end
function obj=set.Mode(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >6 || min(value)<0
         error('Mode must be between 0 and 6');
     else
         Stop(obj);
         obj.priv_Output=obj.getfieldstr(obj.values.mode, value);
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.general,obj.CONST.general.mode,value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = get.IsoOutput(obj)
    % The Trigger property 
    %
    % Valid values are from ComConstants.m:
    %   EXAMPLE: handle.Trigger =1;  
    %   EXAMPLE: handle.Trigger =handle.values.trigger.rising; 
    %   
    obj.priv_IsoOutput=obj.GetInfo(obj.CONST.menu.general,obj.CONST.general.isoOutput,obj.priv_IsoOutput);        
    out=obj.priv_IsoOutput;
end
function obj=set.IsoOutput(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >1 || min(value)<0
         error('Trigger must be 0 or 1');
     else
%          Stop(obj);
         obj.priv_IsoOutput=obj.getfieldstr(obj.values.isoOutput,value);
       %  sprintf('s m %d %d %d',uint8(obj.CONST.menu.general),uint8(obj.CONST.general.trigger),uint64(trigger(value)))
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.general,obj.CONST.general.isoOutput ,value);
%          Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = get.Active(obj)
% The Active property gets the mode status
% function obj=set.Active(obj,value)
%  if strcmp(value,'run') || strcmp(value,'stop')
%         if obj.PortSuccess  ==  1 &&  obj.DoComms
%             if strcmp(value,'run')
%               strOut=obj.SendReceiveString('s a run');
%               obj.PortSuccess =strcmp(strOut,'*');
%             else
%               strOut=obj.SendReceiveString('s a stop');
%               obj.PortSuccess =strcmp(strOut,'*');
%             end
%             value=obj.SendReceiveString('g a');
%             obj.priv_Active=value;
%         else
%             if obj.DoComms warning('No Instrument communication ams4100 values will change, but the instrument settings are not changed'); end
%         end
%  else
%     error('The value must be "run" or "stop"');
%  end  
% end
    obj.priv_Active=obj.SendReceiveString('g a');
    out=obj.priv_Active;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.Trigger(obj)
    % The Trigger property 
    %
    % Valid values are from ComConstants.m:
    %   EXAMPLE: handle.Trigger =1;  
    %   EXAMPLE: handle.Trigger =handle.values.trigger.rising; 
    %   
    obj.priv_Trigger=obj.GetInfo(obj.CONST.menu.general,obj.CONST.general.trigger,obj.priv_Trigger);        
    out=obj.priv_Trigger;
end
function obj=set.Trigger(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >1 || min(value)<0
         error('Trigger must be 0 or 1');
     else
         Stop(obj);
         obj.priv_Trigger=obj.getfieldstr(obj.values.trigger,value);
       %  sprintf('s m %d %d %d',uint8(obj.CONST.menu.general),uint8(obj.CONST.general.trigger),uint64(trigger(value)))
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.general,obj.CONST.general.trigger ,value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.Auto(obj)
    % The Auto property 
    %
    % Valid values are from ComConstants.m:
    %   EXAMPLE: handle.Auto =1;  
    %   EXAMPLE: handle.Auto =handle.values.auto.fixed;  
    %
    obj.priv_Auto=obj.GetInfo(obj.CONST.menu.general,obj.CONST.general.auto,obj.priv_Auto);
    out=obj.priv_Auto;
end
function obj=set.Auto(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >2 || min(value)<0
         error('Auto must be between 0 and 2');
     else
         Stop(obj);
         obj.priv_Auto=obj.getfieldstr( obj.values.auto , value );
         obj.PortSuccess=obj.SetInfo( obj.CONST.menu.general,obj.CONST.general.auto , value );
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.Monitor(obj)
    % The Monitor property 
    %
    % Valid values are from ComConstants.m:
    %   EXAMPLE: handle.Monitor =1;  
    %   EXAMPLE: handle.Monitor = handle.values.monitor.scale1VperV; 
    %
    obj.priv_Monitor=obj.GetInfo(obj.CONST.menu.general,obj.CONST.general.monitor,obj.priv_Monitor);
    out=obj.priv_Monitor;  
end
function obj=set.Monitor(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >7 || min(value)<0
         error('Monitor must be from 0 to 5');
     else
         Stop(obj);
         obj.priv_Monitor=obj.getfieldstr( obj.values.monitor , value );
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.general,obj.CONST.general.monitor ,value);
         Run(obj);
     end
 end  
end        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.Sync1(obj)
    % The Sync1 property 
    %
    % Valid values are from ComConstants.m:
    %   EXAMPLE: handle.Sync1 =1;  
    %   EXAMPLE: handle.Sync1 =handle.values.sync.eventPeriod; 
    %
    obj.priv_Sync1=obj.GetInfo(obj.CONST.menu.config,obj.CONST.config.sync1,obj.priv_Sync1);        
    out=obj.priv_Sync1;
end
function obj=set.Sync1(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >8 || min(value)<0
         error('Sync1 must be from 0 to 8');
     else
         Stop(obj);
         obj.priv_Sync1=obj.getfieldstr( obj.values.sync , value );
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.config, obj.CONST.config.sync1, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.Sync2(obj)
    % The Sync2 property 
    %
    % Valid values are from ComConstants.m:
    %   EXAMPLE: handle.Sync2 =1;  
    %   EXAMPLE: handle.Sync2 =handle.values.sync.eventPeriod; 
    %
    obj.priv_Sync2=obj.GetInfo(obj.CONST.menu.config,obj.CONST.config.sync2,obj.priv_Sync2);     
    out=obj.priv_Sync2;
end
function obj=set.Sync2(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >3 || min(value)<0
         error('Sync2 must be from 0 to 3');
     else
         Stop(obj);
         obj.priv_Sync2=obj.getfieldstr( obj.values.sync , value );
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.config, obj.CONST.config.sync2, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.PeriodOrFreq(obj)
    % The PeriodOrFreq property 
    %
    % Valid values are from ComConstants.m:
    %   EXAMPLE: handle.PeriodOrFreq =1;  
    %   EXAMPLE: handle.PeriodOrFreq = handle.values.periodOrFreq.frequency; 
    %
    obj.priv_PeriodOrFreq=obj.GetInfo(obj.CONST.menu.config,obj.CONST.config.periodOrFreq,obj.priv_PeriodOrFreq);    
    out=obj.priv_PeriodOrFreq;
end
function obj=set.PeriodOrFreq(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >1 || min(value)<0
         error('PeriodOrFreq must be 0 or 1');
     else
         Stop(obj);
         obj.priv_PeriodOrFreq=obj.getfieldstr( obj.values.periodOrFreq, value);
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.config,obj.CONST.config.periodOrFreq,value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.TrainType(obj)
    % The TrainType property 
    %
    % Valid values are from ComConstants.m:
    %   EXAMPLE: handle.TrainType =2;  
    %   EXAMPLE: handle.TrainType = handle.values.train.type.uniform; 
    %
    obj.priv_TrainType=obj.GetInfo(obj.CONST.menu.train,obj.CONST.train.type,obj.priv_TrainType);       
    out=obj.priv_TrainType;
end
function obj=set.TrainType(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >1 || min(value)<0
         error('TrainType must be from 0 to 2');
     else
         Stop(obj);
         obj.priv_TrainType=obj.getfieldstr( obj.values.train.type , value );
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.train,obj.CONST.train.type, value );
        Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.TrainDelay(obj)
    % The TrainDelay property 
    %
    % Valid values are:
    % 0  to 9,360,000,000 us
    %   EXAMPLE: handle.TrainDelay =5000 (5ms);  
    %
    obj.priv_TrainDelay=obj.GetInfo(obj.CONST.menu.train,obj.CONST.train.delay,obj.priv_TrainDelay);    
    out=obj.priv_TrainDelay;
end
function obj=set.TrainDelay(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >9360000000 || min(value)<0 || not(isnumeric(value)) || not( rem(value,1)==0)
         error('TrainDelay must be an integer from 0 to 9360000000');
     else
         Stop(obj);
         obj.priv_TrainDelay=value;
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.train, obj.CONST.train.delay, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.UniformNumber(obj)
    % The UniformNumber property 
    obj.priv_UniformNumber= obj.GetInfo(obj.CONST.menu.uniformevent , ...
                                        obj.CONST.uniformevent.number, ...
                                        obj.priv_UniformNumber);
    out=obj.priv_UniformNumber;
end
function obj=set.UniformNumber(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >20 || min(value)<1 || not(isnumeric(value)) || not( rem(value,1)==0)
         error('UniformNumber must be an integer from 1 to 20');
     else
         Stop(obj);
         obj.priv_UniformNumber=value;
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.uniformevent , ...
                                     obj.CONST.uniformevent.number, ...
                                     value);
        %AMS_UpdateEventTable();
        %AMS_UpdateEvents();
        Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.HighVflag(obj)
    % The HighVflag property 
    tmp=SendReceiveString(obj,'g c');
    bitPos=4;
    obj.priv_HighVflag=bitand(bitshift(double(tmp(1)),-bitPos),1);
    out=obj.priv_HighVflag;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.HighIflag(obj)
    % The HighVflag property 
    tmp=SendReceiveString(obj,'g c');
    bitPos=3;
    obj.priv_HighIflag=bitand(bitshift(double(tmp(1)),-bitPos),1);
    out=obj.priv_HighIflag;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.Generating(obj)
    % The HighVflag property 
    tmp=SendReceiveString(obj,'g c');
    bitPos=2;
    obj.priv_Generating=bitand(bitshift(double(tmp(1)),-bitPos),1);
    out=obj.priv_Generating;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.Running(obj)
    % The HighVflag property 
    tmp=SendReceiveString(obj,'g c');
    bitPos=1;
    obj.priv_Running=bitand(bitshift(double(tmp(1)),-bitPos),1);
    out=obj.priv_Running;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.EnableButtonIn(obj)
    % The HighVflag property 
    tmp=SendReceiveString(obj,'g c');
    bitPos=0;
    obj.priv_EnableButtonIn=bitand(bitshift(double(tmp(1)),-bitPos),1);
    out=obj.priv_EnableButtonIn;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.TrainDur(obj)
    %TrainDur- train duration in us
    % The TrainDurproperty 
    %
    % Valid values are:
    % 2  to 9,360,000,000 us
    %   EXAMPLE: handle.TrainDur=5000 (5ms);  
    %
    obj.priv_TrainDur=obj.GetInfo(obj.CONST.menu.train,obj.CONST.train.duration,obj.priv_TrainDur);  
    out=obj.priv_TrainDur;
end
function obj=set.TrainDur(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >9360000000 || min(value)<2 || not(isnumeric(value)) || not( rem(value,1)==0)
         error('TrainDur must be an integer from 2 to 9360000000');
     else
         Stop(obj);
         obj.priv_TrainDur=value;
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.train, obj.CONST.train.duration, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.TrainPeriod(obj)
    % The TrainPeriod property 
    %
    % Valid values are:
    % 2  to 9,360,000,000 us
    %   EXAMPLE: handle.TrainPeriod =5000 (5ms);  
    %
    obj.priv_TrainPeriod=obj.GetInfo(obj.CONST.menu.train,obj.CONST.train.period,obj.priv_TrainPeriod);      
    out=obj.priv_TrainPeriod;
end
function obj=set.TrainPeriod(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >9360000000 || min(value)<2 || not(isnumeric(value)) || not( rem(value,1)==0)
         error('TrainPeriod must be an integer from 2 to 9360000000');
     else
         Stop(obj);
         obj.priv_TrainPeriod=value;
         freq=round(1000000/value);
         obj.priv_TrainFrequency=freq;
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.train, obj.CONST.train.period, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.TrainQuantity(obj)
    % The TrainQuantity property 
    %
    % Valid values are:
    % 1  to 100
    %   EXAMPLE: handle.TrainQuantity =22 ;  
    %
    obj.priv_TrainQuantity=obj.GetInfo(obj.CONST.menu.train,obj.CONST.train.quantity,obj.priv_TrainQuantity);  
    out=obj.priv_TrainQuantity;
end
function obj=set.TrainQuantity(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >100 || min(value)<1 || not(isnumeric(value)) || not( rem(value,1)==0)
         error('TrainQuantity must be an integer from 1 to 100');
     else
         Stop(obj);
         obj.priv_TrainQuantity=value;
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.train, obj.CONST.train.quantity, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.TrainLevel(obj)
    % The TainLevel property 
    %
    % Valid values are:
    % 0  to 200000000
    %   EXAMPLE: handle.TainLevel =10000;  (this is 10mV)  
    %
    obj.priv_TrainLevel=obj.GetInfo(obj.CONST.menu.train,obj.CONST.train.level,obj.priv_TrainLevel);   
    out=obj.priv_TrainLevel;
end
function obj=set.TrainLevel(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >200000000 || min(value)< -200000000 || not(isnumeric(value)) || not( rem(value,1)==0)
         error('TainLevel must be an integer from 0 to 200000000');
     else
         Stop(obj);
         obj.priv_TrainLevel=value;
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.train, obj.CONST.train.level, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.TrainFrequency(obj)
    % The TrainFrequency property 
    %
    % Valid values are:
    % 1,000,000/2  to 1,000,000/9,360,000,000 Hz
    %   EXAMPLE: handle.TrainPeriod =67; (Hz)  
    % 
    out=obj.priv_TrainFrequency;
end
function obj=set.TrainFrequency(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if isnumeric(value) 
         period=round(1000000/value);
         if max(period) >9360000000 || min(period)<0 
             error('TrainFrequency must be floats from 1.0684e-04 to 500,000');
         else
             Stop(obj);
             obj.priv_TrainFrequency=value;
             obj.priv_TrainPeriod=period;
             obj.PortSuccess=obj.SetInfo(obj.CONST.menu.train, obj.CONST.train.period, period);
             Run(obj);
         end
     else
          error('Values must be numeric');
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.OffsetOrHold(obj)
    % The OffsetOrHold property 
    %
    % Valid values are from ComConstants.m:
    %   EXAMPLE: handle.OffsetOrHold =1;  
    %   EXAMPLE: handle.OffsetOrHold = handle.values.offsetOrHold.hold; 
    %
    obj.priv_OffsetOrHold=obj.GetInfo(obj.CONST.menu.train,obj.CONST.train.offsetOrHold,obj.priv_OffsetOrHold);       
    out=obj.priv_OffsetOrHold;
end
function obj=set.OffsetOrHold(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >2 || min(value)<0
         error('OffsetOrHold must be from 0 to 2');
     else
         Stop(obj);
         obj.priv_OffsetOrHold=obj.getfieldstr( obj.values.offsetOrHold, value);
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.train, obj.CONST.train.offsetOrHold, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function out = get.EventID(obj)
%     % The EventID property 
%     %
%     % If EventID changes it will update the event fields (in event.m) using
%     % the function AMS_UpdateEvents.  This is only active for mixed train
%     % types
%     % Valid values are:
%     % 1  to 20
%     %   EXAMPLE: handle.EventID =1 ;  
%     %
%     out=obj.priv_EventID;
% end
% function obj=set.EventID(obj,value)
%  if size(value,2) ~= 1 || size(value,1)~= 1
%      error('Must be a 1 by 1 byte array.');
%  else
%      if max(value) >20 || min(value)<1 || not(isnumeric(value)) || not( rem(value,1)==0)
%          error('EventID must be an integer from 1 to 20');
%      else
%          obj.priv_EventID=value;
%          %obj.PortSuccess=obj.SetInfo(obj.CONST.menu.event, event.eventID, value);
%          %AMS_UpdateEvents();
%      end
%  end  
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.LibID(obj)
    % The LibID property 
    %
    % If LibID can only change in train type uniform, or mixed. In mixed
    % when LibID changes that library will be loaded into Event 1. In mixed
    % when LibID changes that library will be loaded into the current
    % Event, and the Event List will change that library Position.
    % Valid values are:
    % 1  to 20
    %   EXAMPLE: handle.LibID =1 ;  
    %
    out=obj.priv_LibID;
end
function obj=set.LibID(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >20 || min(value)<1 || not(isnumeric(value)) || not( rem(value,1)==0)
         error('LibID must be an integer from 1 to 20');
     else
         obj.priv_LibID=value;
        %obj.PortSuccess=obj.SetInfo(obj.CONST.menu.event, event.libID, value);
        %AMS_UpdateEventTable();
        %AMS_UpdateEvents();
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.EventType(obj)
    % The EventType property 
    %
    % Valid values are from ComConstants.m:
    %   EXAMPLE: handle.EventType =1;  
    %   EXAMPLE: handle.EventType = handle.values.event.type.biphasic; 
    %
    obj.priv_EventType=obj.GetInfo(obj.CONST.menu.event+obj.LibID-1,obj.CONST.event.type,obj.priv_EventType);
    out=obj.priv_EventType;
end
function obj=set.EventType(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >3 || min(value)<0
         error('EventType must be from 0 to 3');
     else
         Stop(obj);
         obj.priv_EventType=obj.getfieldstr( obj.values.event.type , value );
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.event+obj.LibID-1, obj.CONST.event.type, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.EventDelay(obj)
    % The EventDelay property 
    %
    % Valid values are:
    % 0  to 9,360,000,000 us
    %   EXAMPLE: handle.EventDelay =5000 (5ms);  
    %
    obj.priv_EventDelay=obj.GetInfo(obj.CONST.menu.event+obj.LibID-1,obj.CONST.event.delay,obj.priv_EventDelay);     
    out=obj.priv_EventDelay;
end
function obj=set.EventDelay(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >9360000000 || min(value)<0 || not(isnumeric(value)) || not( rem(value,1)==0)
         error('EventDelay must be an integer from 0 to 9360000000');
     else
         Stop(obj);
         obj.priv_EventDelay=value;
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.event+obj.LibID-1,obj.CONST.event.delay, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.EventDur1(obj)
    % The EventDuration1 property 
    %
    % Valid values are:
    % 1  to 9,360,000,000 us
    %   EXAMPLE: handle.EventDuration1 =5000 (5ms);  
    %
    obj.priv_EventDur1=obj.GetInfo(obj.CONST.menu.event+obj.LibID-1,obj.CONST.event.dur1,obj.priv_EventDur1);
    out=obj.priv_EventDur1;
end
function obj=set.EventDur1(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >9360000000 || min(value)<1 || not(isnumeric(value)) || not( rem(value,1)==0)
         error('EventDuration1 must be an integer from 1 to 9360000000');
     else
         Stop(obj);
         obj.priv_EventDur1=value;
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.event+obj.LibID-1,obj.CONST.event.dur1, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.EventDur2(obj)
    % The EventDuration2 property 
    %
    % Valid values are:
    % 0  to 9,360,000,000 us
    %   EXAMPLE: handle.EventDuration2 =5000 (5ms);  
    %
    obj.priv_EventDur2=obj.GetInfo(obj.CONST.menu.event+obj.LibID-1,obj.CONST.event.dur2,obj.priv_EventDur2);    
    out=obj.priv_EventDur2;
end
function obj=set.EventDur2(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >9360000000 || min(value)<0 || not(isnumeric(value)) || not( rem(value,1)==0)
         error('EventDuration2 must be an integer from 0 to 9360000000');
     else
         Stop(obj);
         obj.priv_EventDur2=value;
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.event+obj.LibID-1,obj.CONST.event.dur2, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.EventDur3(obj)
    % The EventDuration2 property 
    %
    % Valid values are:
    % 1  to 9,360,000,000 us
    %   EXAMPLE: handle.EventDur3 =5000 (5ms);  
    %
    obj.priv_EventDur3=obj.GetInfo(obj.CONST.menu.event+obj.LibID-1,obj.CONST.event.dur3,obj.priv_EventDur3);
    out=obj.priv_EventDur3;
end
function obj=set.EventDur3(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >9360000000 || min(value)<0 || not(isnumeric(value)) || not( rem(value,1)==0)
         error('EventDuration3 must be an integer from 0 to 9360000000');
     else
         Stop(obj);
         obj.priv_EventDur3=value;
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.event+obj.LibID-1,obj.CONST.event.dur3, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.EventPeriod(obj)
    % The EventPeriod property 
    %
    % Valid values are:
    % 2  to 9,360,000,000 us
    %   EXAMPLE: handle.EventPeriod =5000 (5ms);  
    %
    obj.priv_EventPeriod=obj.GetInfo(obj.CONST.menu.event+obj.LibID-1,obj.CONST.event.period,obj.priv_EventPeriod);
    out=obj.priv_EventPeriod;
end
function obj=set.EventPeriod(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >9360000000 || min(value)<2 || not(isnumeric(value)) || not( rem(value,1)==0)
         error('EventPeriod must be an integer from 2 to 9360000000');
     else
         Stop(obj);
         freq=round(1000000/value);
         obj.priv_EventPeriod=value;
         obj.priv_EventFrequency=freq;
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.event+obj.LibID-1,obj.CONST.event.period, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.EventQuantity(obj)
    % The EventQuantity property 
    %
    % Valid values are:
    % 1  to 99999 
    %   EXAMPLE: handle.EventQuantity =22 ;  
    %
    obj.priv_EventQuantity=obj.GetInfo(obj.CONST.menu.event+obj.LibID-1,obj.CONST.event.quantity,obj.priv_EventQuantity);    
    out=obj.priv_EventQuantity;
end
function obj=set.EventQuantity(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) > 99999  || min(value)<1 || not(isnumeric(value)) || not( rem(value,1)==0)
         error('EventQuantity must be an integer from 1 to 99999 ');
     else
         Stop(obj);
         obj.priv_EventQuantity=value;
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.event+obj.LibID-1, obj.CONST.event.quantity, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.EventFrequency(obj)
    % The EventFrequency property 
    %
    % Valid values are:
    % 1,000,000/2  to 1,000,000/9,360,000,000 Hz
    %   EXAMPLE: handle.EventFrequency =67; (Hz)  
    %
    out=obj.priv_EventFrequency;
end
function obj=set.EventFrequency(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if isnumeric(value) 
         period=round(1000000/value);
         if max(period) >9360000000 || min(period)<0 
             error('EventFrequency must be a float from 1.0684e-04 to 500,000');
         else
             Stop(obj);
             obj.priv_EventFrequency=value;
             obj.priv_EventPeriod=period;
             obj.PortSuccess=obj.SetInfo(obj.CONST.menu.event+obj.LibID-1, obj.CONST.event.period, period);
             Run(obj);
         end
     else
          error('Values must be numeric');
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.EventAmp1(obj)
    % The EventAmp1 property 
    %
    % Valid values are:
    % 0  to 200000000
    %   EXAMPLE: handle.EventAmp1 =10000;  (this is 10mV)  
    %
    obj.priv_EventAmp1=obj.GetInfo(obj.CONST.menu.event+obj.LibID-1, obj.CONST.event.amp1,obj.priv_EventAmp1);    
    out=obj.priv_EventAmp1;
end
function obj=set.EventAmp1(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >200000000 || min(value)<-200000000 || not(isnumeric(value)) || not( rem(value,1)==0)
         error('EventAmp1 must be an integer from 0 to 200000000');
     else
         Stop(obj);
         obj.priv_EventAmp1=value;
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.event+obj.LibID-1, obj.CONST.event.amp1, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.EventAmp2(obj)
    % The EventAmplitude property 
    %
    % Valid values are:
    % 0  to 200000000
    %   EXAMPLE: handle.EventAmplitude =10000;  (this is 10mV)  
    %
    obj.priv_EventAmp2=obj.GetInfo(obj.CONST.menu.event+obj.LibID-1, obj.CONST.event.amp2,obj.priv_EventAmp2);   
    out=obj.priv_EventAmp2;
end
function obj=set.EventAmp2(obj,value)
 if size(value,2) ~= 1 || size(value,1)~= 1
     error('Must be a 1 by 1 byte array.');
 else
     if max(value) >200000000 || min(value)<-200000000 || not(isnumeric(value)) || not( rem(value,1)==0)
         error('EventAmp2 must be an integer from 0 to 200000000');
     else
         Stop(obj);
         obj.priv_EventAmp2=value;
         obj.PortSuccess=obj.SetInfo(obj.CONST.menu.event+obj.LibID-1, obj.CONST.event.amp2, value);
         Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = get.EventList(obj)
    % The EventList property 
    %
    % Valid values are:
    %   1 to 20 
    %   EXAMPLE: handle.EventList(3) =1;  
    %   EXAMPLE: handle.EventList=                            
    %            [1 2 3 4 5 6 7 8 9 0 11 12 13 14 15 16 17 18 19 20];
    %
    % Note I made this a non communication get to save process time. To
    % update the PC values with the Instument values the UpdateEventList()
    % function must be called.  This could be done with all variables to
    % speed up PC time.
   % UpdateEventList(obj);  overkill?
    out=obj.priv_EventList;
end
function obj=set.EventList(obj,value)
 if size(value,2) > 20 || size(value,1)~= 1
     error('Must be a 1 by 20 byte array.');
 else
     if max(value) >20 || min(value)<-1
         error('EventType must be from 1 to 20');
     else
        value=[value (zeros(1,19-size(value,2))-1)];
        Stop(obj);
        for i=1:size(value,2)
            obj.priv_EventList(i)=uint8(value(i));
            if i<11
                slot=i+4;
            else
                slot=i+12;
            end
            obj.PortSuccess=obj.SetInfo(obj.CONST.menu.eventlist,slot,value(i));   
        end
        Run(obj);
     end
 end  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateEventList(obj)
        % The Gets each library number in the eventlist
        % EventList on the computer is 1 to 20, but on the instrument it is
        % 5 to 14 and 23 to 32
        
    for i=1:20
        if i<11
            slot=i+4;
        else
            slot=i+12;
        end
        tmp=obj.GetInfo(obj.CONST.menu.eventlist, slot, obj.priv_EventList(i));   
        if tmp<=0
            obj.priv_EventList(i)=-1;
            for j=i:20
                obj.priv_EventList(j)=-1;
            end
            break
        else
            obj.priv_EventList(i)=tmp;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Action Methods   
function Run(obj)
    %Run - Enable the mode
    %
    %   Run will put the instrument in free run
    %
    %   SYNOPSIS: obj.Run()
    %
    %   EXAMPLE:    handle.Run;
    %
    if ~obj.loading
    try     
        strOut=obj.SendReceiveString('s a run');    
        obj.PortSuccess=strcmp(strOut,'*');
    catch
        obj.PortSuccess=0;
        warning('No Instrument communication')
    end
    end
end
%%%%%
function DisplayMenuPage(obj, page)
    %DisplayMenuPage - Has the instrument display a page
    %
    %   DisplayMenuPage will change what menu is shown on the instrument
    %
    %   SYNOPSIS: obj.DisplayMenuPage(page)
    %
    %   EXAMPLE:    handle.DisplayMenuPage(1);
    %
    if ~obj.loading
    try     
        instr=sprintf('s d %d',uint8(page));
        outstr=obj.SendReceiveString(instr);
        obj.PortSuccess=strcmp(outstr,'*');   
    catch
        obj.PortSuccess=0;
        warning('No Instrument communication')
    end
    end
end
%%%%%
function Stop(obj)
    %Stop - Stops the mode
    %
    %   Stop will end free run
    %
    %   SYNOPSIS: obj.Stop()
    %
    %   EXAMPLE:    handle.Stop;
    %
    if ~obj.loading
    try     
        strOut=obj.SendReceiveString('s a stop');    
        obj.PortSuccess=strcmp(strOut,'*');
    catch exception
        obj.PortSuccess=0;
        msgText=getReport(exception);
        msgText = ['No Instrument communication' msgText ];
        warning(msgText)
    end
    end
end
%%%%%
function GoOnce(obj)
    %GoOnce - Start the mode
    %
    %   GoOnce will send a single trigger to the instrument
    %
    %   SYNOPSIS: obj.GoOnce()
    %
    %   EXAMPLE:    handle.GoOnce;
    %
    if ~obj.loading
    try     
        strOut=obj.SendReceiveString('s t one');    
        obj.PortSuccess=strcmp(strOut,'*');
    catch
        obj.PortSuccess=0;
        warning('No Instrument communication')
    end
    end
end
%%%%%
function StopFreeRun(obj)
    %StopFreeRun - Stop Free run
    %
    %   StopFreeRun will send a continous trigger to the instrument
    %
    %   SYNOPSIS: obj.StopFreeRun()
    %
    %   EXAMPLE:    handle.StopFreeRun;
    %
    if ~obj.loading
    try     
        strOut=obj.SendReceiveString('s t none');    
        obj.PortSuccess=strcmp(strOut,'*');
    catch
        obj.PortSuccess=0;
        warning('No Instrument communication')
    end
    end
end
%%%%%
function GoFreeRun(obj)
    %GoFreeRun - Start Free run
    %
    %   GoFreeRun will send a continous trigger to the instrument
    %
    %   SYNOPSIS: obj.GoFreeRun()
    %
    %   EXAMPLE:    handle.GoFreeRun;
    %
    if ~obj.loading
    try     
        strOut=obj.SendReceiveString('s t free');    
        obj.PortSuccess=strcmp(strOut,'*');
    catch
        obj.PortSuccess=0;
        warning('No Instrument communication')
    end
    end
end
%%%%%
%%%%%
function OpenRelay(obj)
    % OpenRelay - Open the output Relay
    %
    %   OpenRelay will force the output relay to open, but it will not
    %   stop timing
    %
    %   SYNOPSIS: obj.OpenRelay()
    %
    %   EXAMPLE:    handle.OpenRelay;
    %
    if ~obj.loading
    try     
        strOut=obj.SendReceiveString('s r o');    
        obj.PortSuccess=strcmp(strOut,'*');
    catch
        obj.PortSuccess=0;
        warning('No Instrument communication')
    end
    end
end
%%%%%
%%%%%
function CloseRelay(obj)
    % CloseRelay - Close the output Relay
    %
    %   CloseRelay will force the output relay to close, but it will not
    %   start timing
    %
    %   SYNOPSIS: obj.CloseRelay()
    %
    %   EXAMPLE:    handle.CloseRelay;
    %
    if ~obj.loading
    try     
        strOut=obj.SendReceiveString('s r c');    
        obj.PortSuccess=strcmp(strOut,'*');
    catch
        obj.PortSuccess=0;
        warning('No Instrument communication')
    end
    end
end
%%%%%
end % methods public
      
    %%    Private Methods
methods
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

function [outStr, goodresult] = SendReceiveString(obj, inStr)
        %SendReceive - Sends a command to the instrument and receives the reply
        %
        %   [ outStr ] = SendReceive(command) 
        %                          Communicates with the instrument to 
        %                          apply or query a setting.
        %
        %   SYNOPSIS: [string] = 
        %                       obj.SendReceive(command, delay)
        %
        %   INPUT: inStr       -  The Command string with the five word commands
        %                         in a string instrument 
        %
        %   mode: outStr  - the mode string
        %
        %   EXAMPLE:   reply
        %       = SendReceive(thisAMS,commandString);
        %   

    obj.ActiveComms=1;
    if nargin==1,cmd='g a'; end
    if nargin==2,cmd=inStr; end
    if(obj.PortSerial || obj.PortEthernet)
        try    
            if obj.MCUrev > 1 && cmd(1)=='s'   % Add pin in necessary
                cmd=sprintf('%d %s',obj.PIN,cmd);
            end
            fprintf('out=: %s     ',cmd);  % display output    
            if obj.PortEthernet 
                read(obj.PortInfo);  % empties the port
                write(obj.PortInfo,uint8(sprintf('%s\r',cmd)))
            else
                flush(obj.PortInfo); %empties the port
                writeline(obj.PortInfo,cmd);  % was fprintf(obj.PortInfo,toStr,'async');
            end
            % pause(delay);  % wait for transmission
            outStr=readReply(obj); 
            if(contains(outStr,'Bad','IgnoreCase',true) || contains(outStr,'?','IgnoreCase',true) )
                fprintf(2,'reply = %s \n', outStr);  %display reply
            else
                fprintf('reply = %s \n', outStr);  %display reply
            end
            lns=length(outStr);
            if lns ~=0
                if strcmp(outStr(lns),'*')
                    goodresult=true;
                    if lns ~= 1
                        if (outStr(1)=='~') 
                            outStr=outStr(2:lns);
                            lns=length(outStr);
                        end
                        lines=strfind(outStr,'~');
                        if length(lines)>1 
                            outStr=outStr(lines(1)+1:lines(2)-1);
                        else
                            outStr=outStr(lns);
                        end
                    end
                else
                    goodresult=false;
                end
            else
                goodresult=false;
            end         
        catch exception
            obj.PortSuccess=0;
            obj.ActiveComms=0;
            msgText = ['No Instrument communication' getReport(exception)];
            warning(msgText)
        end        
    end
    obj.ActiveComms=0;
    end  
    
function outGI = GetInfo(obj,ID, field, curVal)
    if obj.PortSuccess  ==  1 &&  obj.DoComms
        instr=sprintf('g m %d %d',uint8(ID),uint8(field));
        outstr=obj.SendReceiveString(instr);
        idx=str2num(outstr);
        switch (ID)
            case obj.CONST.menu.general
                switch(field)
                    case obj.CONST.general.mode
                        outGI=obj.getfieldstr(obj.values.mode, idx);
                    case obj.CONST.general.monitor
                        outGI=obj.getfieldstr(obj.values.monitor , idx);
                    case obj.CONST.general.trigger
                        outGI=obj.getfieldstr(obj.values.trigger , idx);
                    case obj.CONST.general.auto
                        outGI=obj.getfieldstr(obj.values.auto , idx);
                    case obj.CONST.general.isoOutput
                        outGI=obj.getfieldstr(obj.values.isoOutput , idx);
                end    
            case obj.CONST.menu.config
                switch(field)
                    case {obj.CONST.config.sync1 , obj.CONST.config.sync2}
                        outGI=obj.getfieldstr(obj.values.sync ,idx);
                    case obj.CONST.config.periodOrFreq
                        outGI=obj.getfieldstr(obj.values.periodOrFreq , idx);
                    case obj.CONST.config.durOrCount
                        outGI=obj.getfieldstr(obj.values.durOrCount , idx);
                end
            case obj.CONST.menu.train
                switch(field)
                    case obj.CONST.train.offsetOrHold
                        outGI=obj.getfieldstr(obj.values.offsetOrHold , idx);
                    case obj.CONST.train.type
                        outGI=obj.getfieldstr(obj.values.train.type , idx);
                    otherwise
                        outGI=str2double(outstr);
                end
           case obj.CONST.menu.eventlist
                        outGI=str2num(outstr);
                        if outGI <0
                            outGI=-1;
                        end
                        if isempty(outGI)
                            outGI=-1;
                        end
           otherwise % obj.CONST.menu.event
                switch(field)
                    case obj.CONST.event.type
                        outGI=obj.getfieldstr(obj.values.event.type , idx );
%                     case obj.CONST.event.symmetry
%                         outGI=obj.getfieldstr(obj.values.event.symmetry , idx );
                    otherwise
                        outGI=str2double(outstr);
                end
        end
    else 
      outGI=curVal;
      if obj.DoComms && ~(strcmp(obj.Port,'COMNONE'))
          warning('No Instrument communication ams4100 values will change, but the instrument settings are not changed');
      end
    end
end
    
function success = SetInfo(obj,ID, field,value)
%     if not(isfloat(value))
%           value=uint8(value);
%     end
    if obj.PortSuccess  ==  1 &&  obj.DoComms
        instr=sprintf('s m %d %d %d',uint8(ID),uint8(field),int64(value)); 
        [outstr, success]=obj.SendReceiveString(instr);      
    else
        success=0;
        if obj.DoComms && ~(strcmp(obj.Port,'COMNONE'))
            warning('No Instrument communication ams4100 values will change, but the instrument settings are not changed');
        end
    end

end

function strout=readReply(obj)
    c=0;
    if obj.PortSerial    % Serial Port
        lastwarn('');  % clear warnings
        rplyStr=readline(obj.PortInfo);
        if(~isempty(lastwarn))
            lastwarn('');
            if obj.PortInfo.NumBytesAvailable>0
                rplyStr=char(read(obj.PortInfo,obj.PortInfo.NumBytesAvailable,'uint8'));
            else
               rplyStr='?';
            end
        else
            rplyStr=strcat(rplyStr,'*');
        end
    else  %Ethernet Port
        while(obj.PortInfo.BytesAvailable <1 && c<10000)
            c=c+1;
            pause(0.00001);
        end   
       rplyStr=read(obj.PortInfo,obj.PortInfo.BytesAvailable,'char'); 
    end
    rplyStr=erase(rplyStr,char(13));   % remove charriage returns
    rplyStr=strrep(rplyStr,newline,'~'); %replace line feeds with ~
    rplyStr=strrep(rplyStr,'~~','~');
    strout=convertStringsToChars(rplyStr); 
    if contains(strout,'*')
        strout=strout(1:strfind(strout,'*'));
    end
end

function strout=getfieldstr( ~, thestructure, value)
    snames=fieldnames(thestructure);
    strout=snames{value+1};
end

function revnum = getMCUrev(obj)    % gets a the single digit number after the 'M'
   if(contains(obj.Revision,','))   % original rev versions "m##,F##"
        k = strfind(obj.Revision,'M');
        revnum=str2double(obj.Revision(k,k+1));
   else      % new rev versions “Model 41## AtmelYYDDD FPGA## PSoC##”
       k = strfind(obj.Revision,'Atmel');
       revnum=str2double(revs(k+5:k+10)); %the string Atmel is 5 long, the rev # is 5 digits long
   end

end
    
end  % end private methods

end  %end class