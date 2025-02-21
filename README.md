# Nano CubeSat Kit – Final Year Project

**Authors**:  
- Muhammad Qasim Bukhari (EE-20A-210401068)  
- Parwasha Gul (EE-20A-210401079)  

**Supervisor**:  
- Engr. Faran Mahmood

## Overview
This repository contains the code and hardware documentation for our “Nano CubeSat Kit,” a 3U CubeSat prototype designed to demonstrate an Attitude Determination and Control System (ADCS) using reaction wheels, along with a Raspberry Pi as the On-Board Computer (OBC) and an MPU-6050 IMU for sensor feedback. The goal is to achieve precise attitude stabilization in real-time by rejecting external disturbances—laying the groundwork for further research and educational use in small satellite technology.

## Key Features
- **3U CubeSat Form Factor**: Custom enclosure designed to fit standard 3U CubeSat dimensions (10cm x 10cm x 30cm).
- **Reaction Wheel ADCS**: Uses DC motors and reaction wheels to actively stabilize orientation.
- **IMU-Based Feedback**: An MPU-6050 for real-time measurement of angular velocity and linear acceleration.
- **Raspberry Pi OBC**: Handles sensor fusion, executes PID control, and manages telemetry/communication.
- **Complementary Filter**: Fuses gyroscope and accelerometer data to improve attitude estimation.
- **PID Control**: Minimizes pointing error and compensates for external disturbances.

## Project Structure
```
├── Code/
│   ├── imu_raw_data.py         # Reads raw data from MPU-6050
│   ├── complementary_filter.py # Implements complementary filtering for sensor fusion
│   ├── pid_control.py          # PID control logic for reaction wheels
│   ├── motor_driver_test.py    # Verifies PWM signals and motor-driver interface
│   └── ...
├── Hardware/
│   ├── Schematics/             # Circuit diagrams and Fritzing schematics
│   ├── CubeSat_3U_Enclosure/   # CAD or mechanical drawings of the enclosure
│   └── ...
├── Docs/
│   ├── FYP-Report/             # Project report source files (if you choose to share them)
│   └── ...
└── README.md
```
- **Code/**: All scripts related to data acquisition, filtering, and control.  
- **Hardware/**: Contains circuit diagrams, part lists, and mechanical enclosure details.  
- **Docs/**: Optional folder for final project documentation, slides, or figures.

## Getting Started

1. **Clone the Repository**  
   ```bash
   git clone https://github.com/ColdCoffee426/Final-Year-Project.git
   cd Final-Year-Project
   ```

2. **Hardware Setup**  
   - **Raspberry Pi**: Set up the Raspbian/Raspberry Pi OS, enable SSH, I2C, and VNC (optional).  
   - **Connections**: 
     - Connect the MPU-6050 via I2C pins.  
     - Connect the reaction wheels (DC motors) via an L298N (or similar) motor driver.  
     - Ensure you have a suitable power supply for both the Raspberry Pi and the motors.  

3. **Install Dependencies**  
   - **Python Libraries** (on Raspberry Pi):  
     ```bash
     sudo apt-get update
     sudo apt-get install python3-pip
     pip3 install smbus RPi.GPIO
     ```
   - (Optional) If you’re using any additional libraries for plotting or advanced math, include them here.

4. **Run Initial Tests**  
   - **LED/GPIO Test**:  
     ```bash
     python3 Code/motor_driver_test.py
     ```
     Confirms basic GPIO and PWM functionality.  
   - **IMU Test**:  
     ```bash
     python3 Code/imu_raw_data.py
     ```
     Prints raw accelerometer/gyro data to confirm the MPU-6050 is working properly.

5. **Launch the ADCS Control Loop**  
   - **Complementary Filter & PID**:  
     ```bash
     python3 Code/pid_control.py
     ```
     This starts the main loop that fuses raw IMU data and calculates necessary PWM signals for the reaction wheels.

## Usage and Workflow
1. **Orientation Estimation**: The script reads accelerometer and gyroscope data from the MPU-6050 at a fixed interval.  
2. **Filtering**: A complementary filter combines short-term gyroscope data (good for quick changes) with long-term accelerometer data (good for drift correction).  
3. **PID Control**: A PID controller calculates the required motor speeds to reject disturbances and align with the desired orientation.  
4. **Telemetry (Planned Extension)**: Future enhancements include RF-based wireless telemetry for real-time status and remote configuration.  

## Troubleshooting
- **No IMU Data**: Make sure I2C is enabled (using `sudo raspi-config` → Interface Options → I2C). Double-check SDA and SCL pin wiring.  
- **Motor Not Spinning**: Verify that the L298N driver is properly connected to power, ground, and the correct GPIO pins. Check the motor power supply.  
- **High Noise / Drift**: Tweak the complementary filter constants or PID gains. You can also physically isolate the IMU from excessive vibration.

## Contributing
Contributions, pull requests, and suggestions are welcome! If you find a bug or have an idea to enhance the ADCS design or software, feel free to open an issue or submit a pull request.

## License
You may add the appropriate open-source license (e.g., MIT, GPL) or a custom license statement as preferred for your project.  
*(If your university requires a specific intellectual property notice, include it here.)*

## References
For an in-depth explanation of the project objectives, design methodology, and results, please refer to the **FYP Report** in the `Docs/FYP-Report` folder.  
- Bukhari, M.Q., & Gul, P. (2025). *Nano CubeSat Kit*. Department of Electrical Engineering, Institute of Space Technology, Islamabad.

## Contact
For questions or collaboration:  
- **Muhammad Qasim**: [qasim-bukhari@hotmail.com]  
