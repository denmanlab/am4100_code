%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Filename:    EXAMPLE_1_USB.m
%
% Copyright:   A-M Systems
%
% Author:      DHM
%
% Description:
%   This is a MATLAB script that goes through the basics of creating a 
%   serial connection to A-M Systems Stimulators.
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 1) Open a serial port connection that matches the port that shows up on
%    your computer when you connect A-M Systems stimulator to your computer

disp( 'Setting up the Serial port on COM3')

% 1.2) Define the port
%     The first paramter needs to match the Stimulators Port that shows up 
%     when it is connected to your computer.
%     Buad rates, data, stop, parity, and terminator needs to stay the same
sp=serialport('COM3',115200);  % port and baud rate
pause(1); % and give it a bit of time to set up
sp.Timeout=10;  %wait up to 10 seconds for a reply
sp.DataBits=8;  
sp.StopBits=1;
sp.Parity='odd';EventAmp1
configureTerminator(sp,42,'CR'); % termintor for readline,writeline

% 2) Flush old data sitting on the port
flush(sp);

% 3) Ask the Instrument what its revision is
sndStr='get rev';
writeline(sp,sndStr);
fprintf('Send= %s \n',sndStr);  %display send strring

% 4) Now read the output from the stimulator
rplStr=readline(sp);
rplStr=strcat(rplStr,'*');

fprintf('Reply= %s \n', rplStr);  %display reply

% 5) using a function for clarity to send some other commands
rplStr=Send2Stimulator(sp,'get active');
rplStr=Send2Stimulator(sp,'g n');
rplStr=Send2Stimulator(sp,'s a stop');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rplStr=Send2Stimulator(sp,'1001 s a stop');   % If you want to change values first STOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rplStr=Send2Stimulator(sp,'1001 s m 0 0 0'); % set menu=General:Mode:Internal Volts
rplStr=Send2Stimulator(sp,'1001 s m 7 0'); % set menu=Train:Type=Uniform
rplStr=Send2Stimulator(sp,'1001 s m 4 0 1'); % set menu=UniformEvent:Library:lib#
rplStr=Send2Stimulator(sp,'1001 s m 7 3 5000'); % set menu=Train:Period=5ms
rplStr=Send2Stimulator(sp,'1001 s m 7 2 4000'); % set menu=Train:duration=4ms
rplStr=Send2Stimulator(sp,'g m 7 2'); % get menu=Train:duration

rplStr=Send2Stimulator(sp,'g m 10 2'); % get menu=Library1:Type
rplStr=Send2Stimulator(sp,'1001 s m 10 2 1'); % set menu=Library1:Type:Biphasic
rplStr=Send2Stimulator(sp,'1001 s m 10 4 2'); % set menu=Library1:Quantity:2
rplStr=Send2Stimulator(sp,'1001 s m 10 5 2000'); % set menu=Library1:Period:2ms
rplStr=Send2Stimulator(sp,'1001 s m 10 6 800'); % set menu=Library1:Duration1: 0.8ms
rplStr=Send2Stimulator(sp,'1001 s m 10 8 0'); % set menu=Library1:Interphase:0ms
rplStr=Send2Stimulator(sp,'1001 s m 10 9 400'); % set menu=Library1:Dur2:0.4 ms
rplStr=Send2Stimulator(sp,'1001 s m 10 7 5000000'); % set menu=Library1:Amplitude1 5V
rplStr=Send2Stimulator(sp,'1001 s m 10 10 -4000000'); % set menu=Library1:Amplitude2 -4V
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rplStr=Send2Stimulator(sp,'1001 s a run');    % When you are done changing values RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rplStr=Send2Stimulator(sp,'1001 set trigger free');  % set the trigger to free run
pause(10); %wait 10 seconds
rplStr=Send2Stimulator(sp,'1001 s t n');  % set the trigger to free run
rplStr=Send2Stimulator(sp,'1001 s a stop');   % If you want to change values first STOP
%99) clear the port
clear sp;

clear;

function outstr=Send2Stimulator(port,instr)

    writeline(port,instr);   % write the instruction
    fprintf('Send= %s\t\t',instr);  %display the instruction strring
    lastwarn('');  % clear warnings
    rplyStr=readline(port);  % read the reply from the instrument
    if(~isempty(lastwarn))  % if a wanrning occurs read the bytes reply
        lastwarn('');  
        if port.NumBytesAvailable>0  % because we were waiting for the * end character and failed there should have been plenty of time to get data
            rplyStr=char(read(port,port.NumBytesAvailable,'uint8'));  % use a byte read instead of string read
            rplyStr=erase(rplyStr,char(13));   % remove charriage returns
            rplyStr=strrep(rplyStr,newline,'~'); %replace line feeds with ~
            rplyStr=strrep(rplyStr,'~~','~');
        else
           rplyStr='error no data';
        end
        fprintf(2,'\t \t  \t  \t  ERROR Reply= %s \n',rplyStr);
        fprintf('\n');
    else
        rplyStr=strcat(rplyStr,'*');
        rplyStr=erase(rplyStr,char(13));   % remove charriage returns
        rplyStr=strrep(rplyStr,newline,'~'); %replace line feeds with ~
        rplyStr=strrep(rplyStr,'~~','~');
        fprintf('Reply= %s \n', rplyStr);  %display reply
    end
     outstr=rplyStr;
end



