int distancia(int TriggerPin, int EchoPin) {
  long duration, distanceCm;
  pinMode(TriggerPin, OUTPUT);
  pinMode(EchoPin, INPUT);
  digitalWrite(TriggerPin, LOW);
  delayMicroseconds(4);
  digitalWrite(TriggerPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(TriggerPin, LOW);
  duration = pulseIn(EchoPin, HIGH);
  distanceCm = duration * 10 / 292 / 2;
  delay(1);
  return distanceCm;
}
