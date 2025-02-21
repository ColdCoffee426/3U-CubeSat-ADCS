# 3U CubeSat ADCS

**Authors**  
- Muhammad Qasim Bukhari (EE-20A-210401068)  
- Parwasha Gul (EE-20A-210401079)  

**Supervisor**  
- Engr. Faran Mahmood

## Overview
This repository contains the code and hardware documentation for our “Nano CubeSat Kit,” a 3U CubeSat prototype designed to demonstrate an Attitude Determination and Control System (ADCS). The system utilizes reaction wheels for precise attitude stabilization and a Raspberry Pi for onboard processing. An MPU-6050 IMU provides real-time sensor feedback, while a Complementary Filter and PID control loop manage orientation corrections.

## Key Features
- **3U CubeSat Form Factor** – Custom enclosure adhering to 10 cm x 10 cm x 30 cm dimensions.  
- **Reaction Wheel ADCS** – DC motor–driven wheels for active attitude control.  
- **IMU-Based Feedback** – MPU-6050 accelerometer + gyroscope.  
- **Raspberry Pi OBC** – Handles data fusion, PID algorithms, and future telemetry.  
- **Complementary Filter** – Combines accelerometer & gyro data to reduce noise/drift.  
- **PID Control** – Minimizes pointing error and compensates for external disturbances.


## Getting Started

1. **Clone the Repository**  
   ```bash
   git clone https://github.com/ColdCoffee426/3U-CubeSat-ADCS.git
   cd 3U-CubeSat-ADCS
   ```

2. **Hardware Setup**  
   - **Raspberry Pi** – Install Raspberry Pi OS (Raspbian), enable SSH and I2C.  
   - **MPU-6050 IMU** – Connect via I2C pins (SDA → GPIO2, SCL → GPIO3).  
   - **Reaction Wheels & Motor Driver** – Use an L298N or equivalent driver.  
   - **Power Supply** – Ensure a stable 5V for the Pi and sufficient power for motors.

3. **Install Dependencies**  
   On your Raspberry Pi:  
   ```bash
   sudo apt-get update
   sudo apt-get install python3-pip
   pip3 install smbus RPi.GPIO
   ```
   *(Add any additional libraries here, e.g., matplotlib, numpy, etc., if needed.)*

4. **Initial Tests**  
   - **GPIO / LED**  
     ```bash
     python3 Code/motor_driver_test.py
     ```
     Verifies PWM output and basic GPIO functionality.  
   - **IMU Data Acquisition**  
     ```bash
     python3 Code/imu_raw_data.py
     ```
     Prints raw accelerometer & gyro values from the MPU-6050.

5. **Run the ADCS Control Loop**  
   - **Complementary Filter & PID**  
     ```bash
     python3 Code/pid_control.py
     ```
     Starts the closed-loop control that fuses IMU data and commands reaction wheels.

## Usage & Workflow
1. **Orientation Sensing** – The MPU-6050 provides continuous gyro/accelerometer readings.  
2. **Sensor Fusion** – A complementary filter merges short-term gyro data with long-term accelerometer data to reduce drift and noise.  
3. **PID Calculation** – The script calculates motor speeds required to minimize orientation error.  
4. **Actuation** – The Raspberry Pi sends PWM signals to the motor driver, spinning the reaction wheels.  
5. **Telemetry (Future Work)** – Code will be added for RF-based real-time data transmission and remote control.

## Troubleshooting
- **No IMU Data** – Ensure I2C is enabled (`raspi-config` → Interface Options → I2C) and SDA/SCL pins are correct.  
- **Motor Won’t Spin** – Check motor driver wiring and confirm a separate power supply for motors if required.  
- **Noisy or Unstable Readings** – Adjust complementary filter constants or PID gains. Hardware damping or isolation for the IMU may be beneficial.

## References
- **Project Report** – Found in `Report`.  
- Bukhari, M.Q. & Gul, P. (2025). *Nano CubeSat Kit*, Institute of Space Technology, Islamabad.

## Contact
- **Muhammad Qasim**: [qasim-bukhari@hotmail.com]
  
