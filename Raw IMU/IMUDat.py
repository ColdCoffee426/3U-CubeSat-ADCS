#raw data part 2 
mport mpu6050
import time
import socket

# Create a new Mpu6050 object
sensor = mpu6050.mpu6050(0x68)

def read_sensor_data():
    accelerometer_data = sensor.get_accel_data()
    gyroscope_data = sensor.get_gyro_data()
    return accelerometer_data, gyroscope_data

# Calibration: Take the initial reading as reference
print("Calibrating sensor... Please keep it stable.")
time.sleep(2)  # Wait before calibration

accel_ref, gyro_ref = read_sensor_data()

print("Calibration complete. Reference values:")
print(f"Accel: {accel_ref}, Gyro: {gyro_ref}")

HOST = ''
PORT = 5000

# Create and configure the socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)  # Allow immediate reuse
s.bind((HOST, PORT))
s.listen(1)

print("Server listening on port", PORT)
conn, addr = s.accept()
print("Connected by", addr)

try:
    while True:
        accel, gyro = read_sensor_data()

        # Subtract reference values to calibrate
        accel_calibrated = {
            'x': accel['x'] - accel_ref['x'],
            'y': accel['y'] - accel_ref['y'],
            'z': accel['z'] - accel_ref['z']
        }
        gyro_calibrated = {
            'x': gyro['x'] - gyro_ref['x'],
            'y': gyro['y'] - gyro_ref['y'],
            'z': gyro['z'] - gyro_ref['z']
        }
