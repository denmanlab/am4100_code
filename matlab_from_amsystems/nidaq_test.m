% Create a session object for NI-DAQ
s = daq.createSession('ni');

% Add digital output channels
addDigitalChannel(s, 'Dev1', 'Port0/Line6', 'OutputOnly'); % Adjust the device name and channel as necessary

% Write digital data (set line 6 high)
outputData = [1]; % Write high (1) to digital line 6
outputSingleScan(s, outputData);


% Clean up
clear s;