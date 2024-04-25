import serial

def monitor_serial(port, baudrate=115200, timeout=None):
    try:
        # Open the serial port
        ser = serial.Serial(port, baudrate, timeout=timeout)
        print(f"Monitoring serial port {port}... Press Ctrl+C to stop.")

        # Continuously monitor the serial port
        while True:
            # Read a line from the serial port
            line = ser.readline().decode().strip()
            print("Received:", line)

    except KeyboardInterrupt:
        print("\nMonitoring stopped by user.")
    except serial.SerialException as e:
        print("Serial error:", e)
    finally:
        if ser.is_open:
            # Close the serial port
            ser.close()
            print("Serial port closed.")

# Replace 'COM1' with the appropriate port name for your device
monitor_serial('COM3')