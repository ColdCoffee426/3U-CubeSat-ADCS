import smbus
import time
import socket

# -------------------------------
# MPU6500 Class
# -------------------------------
class mpu6500:
    # Global Variable definition
    GRAVITIY_MS2 = 9.80665  
    address = None
    bus = None

    # Scale Modifiers for dynamic adjustment if higher gs are experienced
    ACCEL_SCALE_MODIFIER_2G  = 16384.0
    ACCEL_SCALE_MODIFIER_4G  = 8192.0
    ACCEL_SCALE_MODIFIER_8G  = 4096.0
    ACCEL_SCALE_MODIFIER_16G = 2048.0

    GYRO_SCALE_MODIFIER_250DEG  = 131.0
    GYRO_SCALE_MODIFIER_500DEG  = 65.5
    GYRO_SCALE_MODIFIER_1000DEG = 32.8
    GYRO_SCALE_MODIFIER_2000DEG = 16.4

    # Setting pre defined ranges for each of the sacles
    ACCEL_RANGE_2G  = 0x00
    ACCEL_RANGE_4G  = 0x08
    ACCEL_RANGE_8G  = 0x10
    ACCEL_RANGE_16G = 0x18

    GYRO_RANGE_250DEG  = 0x00
    GYRO_RANGE_500DEG  = 0x08
    GYRO_RANGE_1000DEG = 0x10
    GYRO_RANGE_2000DEG = 0x18

    # MPU-6500 (6050) Registers
    PWR_MGMT_1   = 0x6B
    PWR_MGMT_2   = 0x6C  #power management reg2 nitialized in case auxiliary power is needed 

    ACCEL_XOUT0  = 0x3B
    ACCEL_YOUT0  = 0x3D
    ACCEL_ZOUT0  = 0x3F

    TEMP_OUT0    = 0x41

    GYRO_XOUT0   = 0x43
    GYRO_YOUT0   = 0x45
    GYRO_ZOUT0   = 0x47

    ACCEL_CONFIG = 0x1C
    GYRO_CONFIG  = 0x1B

    def __init__(self, address, bus=1):
        self.address = address
        self.bus = smbus.SMBus(bus)
        # mpu initialization
        self.bus.write_byte_data(self.address, self.PWR_MGMT_1, 0x00)
        self.ref_accel = None
        self.ref_gyro  = None

    def read_i2c_word(self, register):
        high = self.bus.read_byte_data(self.address, register)
        low  = self.bus.read_byte_data(self.address, register + 1)
        value = (high << 8) + low
        if value >= 0x8000:
            return -((65535 - value) + 1)
        else:
            return value
        #reads i2c data

# functions to get ranges of both sensors
    def read_accel_range(self, raw=False):
        raw_data = self.bus.read_byte_data(self.address, self.ACCEL_CONFIG)
        if raw:
            return raw_data
        elif raw is False:
            if raw_data == self.ACCEL_RANGE_2G:
                return 2
            elif raw_data == self.ACCEL_RANGE_4G:
                return 4
            elif raw_data == self.ACCEL_RANGE_8G:
                return 8
            elif raw_data == self.ACCEL_RANGE_16G:
                return 16
            else:
                return -1

    def get_accel_data(self, g=False):
        # Read raw accelerometer data
        x = self.read_i2c_word(self.ACCEL_XOUT0)
        y = self.read_i2c_word(self.ACCEL_YOUT0)
        z = self.read_i2c_word(self.ACCEL_ZOUT0)

        accel_range = self.read_accel_range(True)
        if accel_range == self.ACCEL_RANGE_2G:
            accel_scale_modifier = self.ACCEL_SCALE_MODIFIER_2G
        elif accel_range == self.ACCEL_RANGE_4G:
            accel_scale_modifier = self.ACCEL_SCALE_MODIFIER_4G
        elif accel_range == self.ACCEL_RANGE_8G:
            accel_scale_modifier = self.ACCEL_SCALE_MODIFIER_8G
        elif accel_range == self.ACCEL_RANGE_16G:
            accel_scale_modifier = self.ACCEL_SCALE_MODIFIER_16G
        else:
            accel_scale_modifier = self.ACCEL_SCALE_MODIFIER_2G

        # Conversion of raw value
        x = x / accel_scale_modifier
        y = y / accel_scale_modifier
        z = z / accel_scale_modifier

        # If g==True, leave the values as g, otherwise convert to m/s^2.
        if not g:
            x *= self.GRAVITIY_MS2
            y *= self.GRAVITIY_MS2
            z *= self.GRAVITIY_MS2

        # Remapping of  axes: vertical becomes x (from sensor z),
        # the axis perpendicular becomes z (from -sensor x),
        # and remaining axis is y (sensor y).
        return {'x': z, 'y': y, 'z': -x}

#doing all the same fo gyroscope
    def read_gyro_range(self, raw=False):
        raw_data = self.bus.read_byte_data(self.address, self.GYRO_CONFIG)
        if raw:
            return raw_data
        elif raw is False:
            if raw_data == self.GYRO_RANGE_250DEG:
                return 250
            elif raw_data == self.GYRO_RANGE_500DEG:
                return 500
            elif raw_data == self.GYRO_RANGE_1000DEG:
                return 1000
            elif raw_data == self.GYRO_RANGE_2000DEG:
                return 2000
            else:
                return -1

    def get_gyro_data(self):
        x = self.read_i2c_word(self.GYRO_XOUT0)
        y = self.read_i2c_word(self.GYRO_YOUT0)
        z = self.read_i2c_word(self.GYRO_ZOUT0)

        gyro_range = self.read_gyro_range(True)
        if gyro_range == self.GYRO_RANGE_250DEG:
            gyro_scale_modifier = self.GYRO_SCALE_MODIFIER_250DEG
        elif gyro_range == self.GYRO_RANGE_500DEG:
            gyro_scale_modifier = self.GYRO_SCALE_MODIFIER_500DEG
        elif gyro_range == self.GYRO_RANGE_1000DEG:
            gyro_scale_modifier = self.GYRO_SCALE_MODIFIER_1000DEG
        elif gyro_range == self.GYRO_RANGE_2000DEG:
            gyro_scale_modifier = self.GYRO_SCALE_MODIFIER_2000DEG
        else:
            gyro_scale_modifier = self.GYRO_SCALE_MODIFIER_250DEG

        x = x / gyro_scale_modifier
        y = y / gyro_scale_modifier
        z = z / gyro_scale_modifier

        # Remap axes similarly
        return {'x': z, 'y': y, 'z': -x}

    def get_relative_accel_data(self, g=False):
        current = self.get_accel_data(g)
        if self.ref_accel is None:
            self.ref_accel = current
            return {'x': 0.0, 'y': 0.0, 'z': 0.0}
        return {'x': current['x'] - self.ref_accel['x'],
                'y': current['y'] - self.ref_accel['y'],
                'z': current['z'] - self.ref_accel['z']}

    def get_relative_gyro_data(self):
        current = self.get_gyro_data()
        if self.ref_gyro is None:
            self.ref_gyro = current
            return {'x': 0.0, 'y': 0.0, 'z': 0.0}
        return {'x': current['x'] - self.ref_gyro['x'],
                'y': current['y'] - self.ref_gyro['y'],
                'z': current['z'] - self.ref_gyro['z']}

# -------------------------------
# Sensor Data Server for Processing
# -------------------------------
def sensor_server():
    # Create an instance of the sensor.
    mpu = mpu6500(0x68)
    HOST = ''    # Listen on all interfaces.
    PORT = 5000  # Port for socket communication.
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((HOST, PORT))
    s.listen(1)
    print("Server listening on port", PORT)
    conn, addr = s.accept()
    print("Connected by", addr)
    try:
        while True:
            # getting relative sensor data
            accel = mpu.get_relative_accel_data()  
            gyro  = mpu.get_relative_gyro_data() 
            # Format: ax,ay,az,gx,gy,gz csv 
            data_str = "{:.4f},{:.4f},{:.4f},{:.4f},{:.4f},{:.4f}\n".format(
                accel['x'], accel['y'], accel['z'],
                gyro['x'], gyro['y'], gyro['z']
            )
            conn.sendall(data_str.encode('utf-8'))
            time.sleep(0.5)
    except Exception as e:
        print("Error:", e)
    finally:
        conn.close()
        s.close()

if __name__ == "__main__":
    sensor_server()
