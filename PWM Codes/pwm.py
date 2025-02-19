import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BCM)
GPIO.setup(13, GPIO.OUT)

pwm = GPIO.PWM(13, 1)  # 1Hz freq
pwm.start(50)  # Start with 50% duty cycle

try:
    while True:
        for dc in range(0, 101, 10):  # Increase duty cycle in larger steps
            pwm.ChangeDutyCycle(dc)
            print(f"PWM Duty Cycle: {dc}%")
            time.sleep(1)  # Hold each duty cycle for 1 second
        for dc in range(100, -1, -10):  # Decrease duty cycle
            pwm.ChangeDutyCycle(dc)
            print(f"PWM Duty Cycle: {dc}%")
            time.sleep(1)
except KeyboardInterrupt:
    pwm.stop()
    GPIO.cleanup()
