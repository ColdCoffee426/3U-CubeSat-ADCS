from gpiozero import LED
import time
led=LED(16)
for _ in range (5):
    led.on()
    time.sleep(0.5)
    led.off()
    time.sleep(0.6)
