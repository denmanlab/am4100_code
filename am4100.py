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
import serial
import time

class AM4100:
    def __init__(self, com_port='COM3', baud_rate=115200):
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

    # def send_command_to_stimulator(self, command):
    #     if self.serial_port is not None:
    #         try:
    #             self.serial_port.write(command.encode() + b'\r\n')
    #             print(f"Send= {command}")
    #             #time.sleep(0.1)  # Short delay to allow command processing
    #             response = self.serial_port.readline().decode().strip()
    #             response = response.replace('\r', '').replace('\n', '~')  # Process response
    #             print(f"Reply= {response}")
    #             return response
    #         except serial.SerialException as e:
    #             print(f"Error sending command: {e}")
    #             return "error no data"
    #     else:
    #         print("Serial port is not open.")
    #         return "error no data"
    def send_command_to_stimulator(self, command, terminator=b'\n'):
        if self.serial_port is not None:
            try:
                self.serial_port.write(command.encode() + b'\r\n')  # Send the command with CR+LF
                print(f"Send= {command}")
                response = self.serial_port.read_until().decode().strip()  # Read until the terminator
                
                response = response.replace('\r', '').replace('\n', '~')  # Process response to replace CR and LF with tilde
                print(f"Reply= {response}")
                return response
            except serial.SerialException as e:
                print(f"Error sending command: {e}")
                return "error no data"
        else:
            print("Serial port is not open.")
            return "error no data"
    
    def send_command_and_read_response(self, command):
        if self.serial_port is not None:
            try:
                # Send command
                full_command = command.encode() + b'\r\n'
                self.serial_port.write(full_command)
                print(f"Send= {command}")

                # Read response until the expected terminator
                response = self.serial_port.read_until(b'*\r\n')
                decoded_response = response.decode().strip()
                # Process and extract the relevant part of the response
                # The value after the last newline and before the '*'
                relevant_part = decoded_response.split('\r\n')[-2]  # Get the second last item after split which should be `-25`
                return relevant_part
            except serial.SerialException as e:
                print(f"Error sending command or reading response: {e}")
                return "error no data"
        else:
            print("Serial port is not open.")
            return "error no data"
    
    def set_amplitude(self, amplitude):
        command = f"1001 s m 10 7 {amplitude}"
        response = self.send_command_and_read_response(command)
        return response
    def get_amplitude(self):
        self.serial_port.write('g m 10 7'.encode())
        response = self.serial_port.readline().decode().strip()
        print(f'reply= {response}')
    def get_params(self):
        amp = self.send_command_and_read_response('g m 10 7')
        pulse_width = self.send_command_and_read_response('g m 10 6')
        pulse_quantity = self.send_command_and_read_response('g m 10 4')
        train_number = self.send_command_and_read_response('g m 7 4')
        train_duration = self.send_command_and_read_response('g m 7 2') # everything in microseconds
        train_period = self.send_command_and_read_response('g m 7 3')
        params = {'amplitude': amp, 
                  'pulse_width': pulse_width, 
                  'pulse_quantity': pulse_quantity,
                  'train_number': train_number, 
                  'train_duration': train_duration, 
                  'train_period': train_period}
        return params    
    
    def read(self):
        response = self.serial_port.read_until()
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