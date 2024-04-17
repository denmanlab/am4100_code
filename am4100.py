import serial
import time

'''
this has limited utility currently but some key notes (mainly so I don't forget):

class establishes a connection with the stimulator given a com_port and then copied the baud_rate.

you can send commands directly to the stimulator with send_command_to_stimulator. 
these take strings where the notes about these strings can be found in the word document.

generally when changing parameter you need to "stop" -> change parameters -> "run" 
stop changes the stimulator to ready but not listenign to trigger. 
run changes the stimulator to listening for trigger. 

currently there is a wrapper to format the string for event amplitude but more wrappers can be
developed by decoding the string formats in the word document. 

also see poorly formated copied and pasted version below class. 

potentially helpful todo: learn the string that provides an internal trigger
'''
class AM4100:
    def __init__(self, com_port='COM4', baud_rate=115200):
        self.com_port = com_port
        self.baud_rate = baud_rate
        self.serial_port = None
        self.setup_serial_connection()

    def setup_serial_connection(self):
        try:
            self.serial_port = serial.Serial(self.com_port, self.baud_rate, timeout=10)
            self.serial_port.bytesize = serial.EIGHTBITS
            self.serial_port.stopbits = serial.STOPBITS_ONE
            self.serial_port.parity = serial.PARITY_ODD
            self.serial_port.write_timeout = 10  # Set write timeout to prevent blocking write calls
            time.sleep(1)  # Allow some time for the serial port to initialize
        except serial.SerialException as e:
            print(f"Error opening serial port: {e}")
            self.serial_port = None

    def flush_serial_port(self):
        if self.serial_port is not None:
            self.serial_port.reset_input_buffer()  # Clear input buffer
            self.serial_port.reset_output_buffer()  # Clear output buffer

    def send_command_to_stimulator(self, command):
        if self.serial_port is not None:
            try:
                self.serial_port.write(command.encode() + b'\r\n')
                print(f"Send= {command}")
                time.sleep(0.01)  # Short delay to allow command processing
                response = self.serial_port.readline().decode().strip()
                response = response.replace('\r', '').replace('\n', '~')  # Process response
                print(f"Reply= {response}")
                return response
            except serial.SerialException as e:
                print(f"Error sending command: {e}")
                return "error no data"
        else:
            print("Serial port is not open.")
            return "error no data"
    
    def set_amplitude(self, amplitude):
        command = f"1001 s m 10 7 {amplitude}"
        response = self.send_command_to_stimulator(command)
        return response
    
    def run(self): # this should set it so its waiting for trigger
        command = '1001 s a run'
        response = self.send_command_to_stimulator(command)
    def stop(self): # put it in a ready state but not able to receive trigger
        command = '1001 s a stop'
        response = self.send_command_to_stimulator(command)
        return response

    def close_connection(self):
        if self.serial_port is not open:
            self.serial_port.close()
            print("Serial port closed.")
        else:
            print("Serial port was not open.")


'''
Menu Name	Menu  #	Item   #	Item Name	Values
General	0	0	Mode	0 = Int Volt	1 = Int Current	2 = Ext 20V/V	3 = Ext 10 ma/V	4 = Ext 1 ma/V	5 = Ext 100 uA/V			
		1	Monitor	0 = 0.1V/V	1 = 1V/V	2 = 10V/V	3 = 20V/V	4 = 10uA/V	5 = 100uA/V	6 =  1mA/V	7=10mA/V	
		2	Trig	0 = Rising	1 = Falling							
		3	Auto	0 = None	1 = Count	2 = Fill						
		4	Save	Save the settings on the instrument						
		5	Output	0 = On	1 = Off	(leaves the output enabled but at 0V or 0A)				
Configuration	1	0	Rates	0 = Period	1 = Frequency							
		1	Sync1	0 = TrainDel	1 = TrainDur	2 = EvDel	3 = EvntDur1	4 = EvntDur2	5 = EvntDur3	6 = EvntTotalDur	7 = Clock-us	8 = Clock_ms
		2	Sync2	0 = TrainDel	1 = TrainDur	2 = EvDel	3 = EvntDur1	4 = EvntDur2	5 = EvntDur3	6 = EvntTotalDur	7 = Clock-us	8 = Clock_ms
UniformEvent	4	0	Library #	Integer value:	1 to 20							
Train	7	0	Type	0 = Uniform	1 = Mixed							
		1	Delay	Time value 0 to 90,000,000,000us steps of 1us					
		2	Durat	Time value 2 to 90,000,000,000us steps of 1us					
		3	Period	Time value 2 to 90,000,000,000us steps of 1us					
		4	Number	Quantity 0 to  99999 steps of 1						
		5	H/O	0 = Hold	1 = Offset							
		6	Level	Amplitude value -200,000,000 to 200,000,000 steps of 1. 1uV or 1uA				
Event List	8	5	Event 1	Library number for corresponding Event 1 to 20 steps of 1						
		6	Event 2							
		…	…							
		14	Event 10							
		23	Event 11							
		24	Event 12							
		…	…							
		32	Event 20							
Library # 1-20	10 to 30	2	Type	0 = Mono	1 = Biphase	2 = Asym	3 = Ramp					
		3	Delay	Time value 0 to 90,000,000,000us steps of 1us					
		4	Number	Quantity 0 to  99999 steps of 1					
		5	Period	Time value 2 to 90,000,000,000us steps of 1us					
		6	Duration 1	Time value 1 to 90,000,000,000us steps of 1us					
		7	Amplitude1	Amplitude value -200,000,000 to 200,000,000 steps of 1. 1uV or 1uA				
		8	Interphase	Time value 0 to 90,000,000,000us steps of 1us					
		9	Duration 2	Time value 0 to 90,000,000,000us steps of 1us					
		10	Amplitude2	Amplitude value -200,000,000 to 200,000,000 steps of 1. 1uV or 1uA				

'''