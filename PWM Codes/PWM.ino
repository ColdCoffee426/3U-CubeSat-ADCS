const int pwmPin = 9;  

void setup() {
  Serial.begin(300);
  pinMode(pwmPin, INPUT);
}

void loop() {
  int pwmState = digitalRead(pwmPin);  // Read if HIGH (1) or LOW (0)
  Serial.println(pwmState);  // Send to Serial Plotter
  delay(1);  
}
