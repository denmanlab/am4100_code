%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Filename:    EXAMPLE_2_Ethernet.m
%
% Copyright:   A-M Systems
%
% Author:      DHM
%
% Description:
%   This is a MATLAB script that goes through the basics of creating a 
%   tcpclient connection to A-M Systems Stimulators.
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 1) Open a tcpclient connection that matches the IP Adr on your stimulator
% (in the General:Net front panel page

disp( 'Setting up tcpclient to 10.0.0.86')

% 1.2) Define the client

t=tcpclient('10.0.0.86',23,"Timeout",20,"ConnectTimeout",30); %port 23
pause(1); % and give it a bit of time to set up
% 2) Flush old data sitting on the port
read(t);   % empties buffer
% 3) Ask the Instrument what its revision is
sndStr='get rev';
write(t,uint8(sprintf('%s\r',sndStr)));
fprintf('Send= %s \n',sndStr);  %display send strring
pause(0.01); % and give it a bit of time to reply
% 4) Now read the output from the stimulator
rplStr=read(t,t.BytesAvailable,'string');
fprintf('Reply= %s \n', rplStr);  %display reply


rplStr=Send2Stimulator(t,'get active');

rplStr=Send2Stimulator(t,'g n');
rplStr=Send2Stimulator(t,'s a stop');

rplStr=Send2Stimulator(t,'g r');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rplStr=Send2Stimulator(t,'1001 s a stop');   % If you want to change values first STOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rplStr=Send2Stimulator(t,'1001 s m 0 0 0'); % set menu=General:Mode:Internal Volts
rplStr=Send2Stimulator(t,'1001 s m 7 0'); % set menu=Train:Type=Uniform
rplStr=Send2Stimulator(t,'1001 s m 4 0 1'); % set menu=UniformEvent:Library:lib#
rplStr=Send2Stimulator(t,'1001 s m 7 3 5000'); % set menu=Train:Period=5ms
rplStr=Send2Stimulator(t,'1001 s m 7 2 4000'); % set menu=Train:duration=4ms
rplStr=Send2Stimulator(t,'g m 7 2'); % get menu=Train:duration

rplStr=Send2Stimulator(t,'g m 10 2'); % get menu=Library1:Type
rplStr=Send2Stimulator(t,'1001 s m 10 2 1'); % set menu=Library1:Type:Biphasic
rplStr=Send2Stimulator(t,'1001 s m 10 4 2'); % set menu=Library1:Quantity:2
rplStr=Send2Stimulator(t,'1001 s m 10 5 2000'); % set menu=Library1:Period:2ms
rplStr=Send2Stimulator(t,'1001 s m 10 6 800'); % set menu=Library1:Duration1: 0.8ms
rplStr=Send2Stimulator(t,'1001 s m 10 8 0'); % set menu=Library1:Interphase:0ms
rplStr=Send2Stimulator(t,'1001 s m 10 9 400'); % set menu=Library1:Dur2:0.4 ms
rplStr=Send2Stimulator(t,'1001 s m 10 7 5000000'); % set menu=Library1:Amplitude1 5V
rplStr=Send2Stimulator(t,'1001 s m 10 10 -4000000'); % set menu=Library1:Amplitude2 -4V
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rplStr=Send2Stimulator(t,'1001 s a run');    % When you are done changing values RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rplStr=Send2Stimulator(t,'1001 set trigger free');  % set the trigger to free run
pause(10); %wait 10 seconds
rplStr=Send2Stimulator(t,'1001 s t n');  % set the trigger to free run
rplStr=Send2Stimulator(t,'1001 s a stop');   % If you want to change values first STOP

pause(5);

% clear the port
clear t;
clear;

function outstr=Send2Stimulator(port,instr)
    if(port.BytesAvailable>0)
        read(port); %empties the buffer
    end
    write(port,uint8(sprintf('%s\r',instr)));
    fprintf('Send= %s\t\t',instr);  %display send strring
    c=0;
    while(port.BytesAvailable<1)
        c=c+1;
        pause(0.00001);
    end   
    rplyStr=read(port,port.BytesAvailable,'char');
    
    rplyStr=erase(rplyStr,char(13));   % remove charriage returns
    rplyStr=strrep(rplyStr,newline,'~'); %replace line feeds with ~
    rplyStr=strrep(rplyStr,'~~','~');
    if contains(rplyStr,'*')
        rplyStr=rplyStr(1:strfind(rplyStr,'*'));
    end
    if(contains(rplyStr,'Bad','IgnoreCase',true) || contains(rplyStr,'?','IgnoreCase',true) )
        fprintf(2,'  %i Reply= %s \n', c,rplyStr);  %display reply
    else
        fprintf('  %i Reply= %s \n', c,rplyStr);  %display reply
    end
     outstr=rplyStr;
end



