void izquierda(int numPasos) {
  delay(1);
  pinMode(motorPin11, OUTPUT); pinMode(motorPin12, OUTPUT);
  pinMode(motorPin13, OUTPUT); pinMode(motorPin14, OUTPUT);
  pinMode(motorPin21, OUTPUT); pinMode(motorPin22, OUTPUT);
  pinMode(motorPin23, OUTPUT); pinMode(motorPin24, OUTPUT);
  delay(1);
  digitalWrite(motorPin11, LOW); digitalWrite(motorPin12, LOW);
  digitalWrite(motorPin13, LOW); digitalWrite(motorPin14, LOW);
  digitalWrite(motorPin21, LOW); digitalWrite(motorPin22, LOW);
  digitalWrite(motorPin23, LOW); digitalWrite(motorPin24, LOW);
  delay(1);
  direccion = 3;
  while (numPasos > 0) {
    if (stepMotor == 1 && micros() - lastTime > velocidad) {
      digitalWrite(motorPin11, HIGH); digitalWrite(motorPin12, LOW);
      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, LOW);
      digitalWrite(motorPin21, HIGH); digitalWrite(motorPin22, LOW);
      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);
      stepMotor = 2; delayMicroseconds(900); lastTime = micros(); numPasos--;
    }
    if (stepMotor == 2 && micros() - lastTime > velocidad) {
      digitalWrite(motorPin11, HIGH); digitalWrite(motorPin12, HIGH);
      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, LOW);
      digitalWrite(motorPin21, HIGH); digitalWrite(motorPin22, HIGH);
      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);
      stepMotor = 3; delayMicroseconds(900); lastTime = micros(); numPasos--;
    }
    if (stepMotor == 3 && micros() - lastTime > velocidad) {
      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, HIGH);
      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, LOW);
      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, HIGH);
      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);
      stepMotor = 4; delayMicroseconds(900); lastTime = micros(); numPasos--;
    }
    if (stepMotor == 4 && micros() - lastTime > velocidad) {
      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, HIGH);
      digitalWrite(motorPin13, HIGH); digitalWrite(motorPin14, LOW);
      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, HIGH);
      digitalWrite(motorPin23, HIGH); digitalWrite(motorPin24, LOW);
      stepMotor = 5; delayMicroseconds(900); lastTime = micros(); numPasos--;
    }
    if (stepMotor == 5 && micros() - lastTime > velocidad) {
      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, LOW);
      digitalWrite(motorPin13, HIGH); digitalWrite(motorPin14, LOW);
      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, LOW);
      digitalWrite(motorPin23, HIGH); digitalWrite(motorPin24, LOW);
      stepMotor = 6; delayMicroseconds(900); lastTime = micros(); numPasos--;
    }
    if (stepMotor == 6 && micros() - lastTime > velocidad) {
      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, LOW);
      digitalWrite(motorPin13, HIGH); digitalWrite(motorPin14, HIGH);
      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, LOW);
      digitalWrite(motorPin23, HIGH); digitalWrite(motorPin24, HIGH);
      stepMotor = 7; delayMicroseconds(900); lastTime = micros(); numPasos--;
    }
    if (stepMotor == 7 && micros() - lastTime > velocidad) {
      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, LOW);
      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, HIGH);
      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, LOW);
      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, HIGH);
      stepMotor = 8; delayMicroseconds(900); lastTime = micros(); numPasos--;
    }
    if (stepMotor == 8 && micros() - lastTime > velocidad) {
      digitalWrite(motorPin11, HIGH); digitalWrite(motorPin12, LOW);
      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, HIGH);
      digitalWrite(motorPin21, HIGH); digitalWrite(motorPin22, LOW);
      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, HIGH);
      stepMotor = 1; delayMicroseconds(900); lastTime = micros(); numPasos--; delay(1);
    }
  }
  cm = distancia(1, 3);
  cm = distancia(1, 3);
}
