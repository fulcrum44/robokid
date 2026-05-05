import { arduinoGenerator } from './arduino_generator.js';

// Se inyectan una sola vez via definitions_ y setups_

function inyectarBase() {
  arduinoGenerator.definitions_['motor_pins'] =
    '#define motorPin11 15\n' +
    '#define motorPin12 2\n' +
    '#define motorPin13 0\n' +
    '#define motorPin14 13\n' +
    '#define motorPin21 12\n' +
    '#define motorPin22 14\n' +
    '#define motorPin23 4\n' +
    '#define motorPin24 5';

  arduinoGenerator.definitions_['motor_vars'] =
    'int pasos = 0;\n' +
    'int stepMotor = 1;\n' +
    'unsigned long velocidad = 50;\n' +
    'unsigned long lastTime = 0;\n' +
    'int direccion = 0;\n' +
    'int cm = 0;';

  arduinoGenerator.setups_['motor_pins_init'] =
    '  pinMode(motorPin11, OUTPUT);\n' +
    '  pinMode(motorPin12, OUTPUT);\n' +
    '  pinMode(motorPin13, OUTPUT);\n' +
    '  pinMode(motorPin14, OUTPUT);\n' +
    '  pinMode(motorPin21, OUTPUT);\n' +
    '  pinMode(motorPin22, OUTPUT);\n' +
    '  pinMode(motorPin23, OUTPUT);\n' +
    '  pinMode(motorPin24, OUTPUT);\n' +
    '  digitalWrite(motorPin11, LOW);\n' +
    '  digitalWrite(motorPin12, LOW);\n' +
    '  digitalWrite(motorPin13, LOW);\n' +
    '  digitalWrite(motorPin14, LOW);\n' +
    '  digitalWrite(motorPin21, LOW);\n' +
    '  digitalWrite(motorPin22, LOW);\n' +
    '  digitalWrite(motorPin23, LOW);\n' +
    '  digitalWrite(motorPin24, LOW);';
}

function inyectarDistancia() {
  arduinoGenerator.definitions_['func_distancia'] =
    'int distancia(int TriggerPin, int EchoPin) {\n' +
    '  long duration, distanceCm;\n' +
    '  pinMode(TriggerPin, OUTPUT);\n' +
    '  pinMode(EchoPin, INPUT);\n' +
    '  digitalWrite(TriggerPin, LOW);\n' +
    '  delayMicroseconds(4);\n' +
    '  digitalWrite(TriggerPin, HIGH);\n' +
    '  delayMicroseconds(10);\n' +
    '  digitalWrite(TriggerPin, LOW);\n' +
    '  duration = pulseIn(EchoPin, HIGH);\n' +
    '  distanceCm = duration * 10 / 292 / 2;\n' +
    '  delay(1);\n' +
    '  return distanceCm;\n' +
    '}';
}

// Bloque de inicio de cada función de movimiento (resetear pines)
function codigoInicioMovimiento() {
  return (
    '  delay(1);\n' +
    '  pinMode(motorPin11, OUTPUT); pinMode(motorPin12, OUTPUT);\n' +
    '  pinMode(motorPin13, OUTPUT); pinMode(motorPin14, OUTPUT);\n' +
    '  pinMode(motorPin21, OUTPUT); pinMode(motorPin22, OUTPUT);\n' +
    '  pinMode(motorPin23, OUTPUT); pinMode(motorPin24, OUTPUT);\n' +
    '  delay(1);\n' +
    '  digitalWrite(motorPin11, LOW); digitalWrite(motorPin12, LOW);\n' +
    '  digitalWrite(motorPin13, LOW); digitalWrite(motorPin14, LOW);\n' +
    '  digitalWrite(motorPin21, LOW); digitalWrite(motorPin22, LOW);\n' +
    '  digitalWrite(motorPin23, LOW); digitalWrite(motorPin24, LOW);\n' +
    '  delay(1);\n'
  );
}

// ─── Funciones de movimiento  ───

function inyectarAdelante() {
  inyectarBase();
  inyectarDistancia();
  arduinoGenerator.definitions_['func_adelante'] =
    'void adelante(int vuelta) {\n' +
    '  pasos = 4096 * vuelta;\n' +
    codigoInicioMovimiento() +
    '  direccion = 1;\n' +
    '  while (pasos > 0) {\n' +
    '    if (stepMotor == 1 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, HIGH); digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, HIGH); digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, HIGH);\n' +
    '      stepMotor = 2; delayMicroseconds(900); lastTime = micros(); pasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 2 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, HIGH); digitalWrite(motorPin12, HIGH);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, HIGH);\n' +
    '      stepMotor = 3; delayMicroseconds(900); lastTime = micros(); pasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 3 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, HIGH);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, HIGH);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 4; delayMicroseconds(900); lastTime = micros(); pasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 4 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, HIGH);\n' +
    '      digitalWrite(motorPin13, HIGH); digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, HIGH); digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 5; delayMicroseconds(900); lastTime = micros(); pasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 5 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, HIGH); digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, HIGH);\n' +
    '      digitalWrite(motorPin23, HIGH); digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 6; delayMicroseconds(900); lastTime = micros(); pasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 6 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, HIGH); digitalWrite(motorPin14, HIGH);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, HIGH);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 7; delayMicroseconds(900); lastTime = micros(); pasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 7 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, HIGH);\n' +
    '      digitalWrite(motorPin21, HIGH); digitalWrite(motorPin22, HIGH);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 8; delayMicroseconds(900); lastTime = micros(); pasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 8 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, HIGH); digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, HIGH);\n' +
    '      digitalWrite(motorPin21, HIGH); digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 1; delayMicroseconds(900); lastTime = micros(); pasos--; delay(1);\n' +
    '    }\n' +
    '  }\n' +
    '  cm = distancia(1, 3);\n' +
    '  cm = distancia(1, 3);\n' +
    '}';
}

function inyectarAtras() {
  inyectarBase();
  inyectarDistancia();
  arduinoGenerator.definitions_['func_atras'] =
    'void atras(int vuelta) {\n' +
    '  pasos = 4096 * vuelta;\n' +
    codigoInicioMovimiento() +
    '  direccion = 2;\n' +
    '  while (pasos > 0) {\n' +
    '    if (stepMotor == 1 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, HIGH); digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, HIGH);\n' +
    '      digitalWrite(motorPin21, HIGH); digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 2; delayMicroseconds(900); lastTime = micros(); pasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 2 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, HIGH);\n' +
    '      digitalWrite(motorPin21, HIGH); digitalWrite(motorPin22, HIGH);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 3; delayMicroseconds(900); lastTime = micros(); pasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 3 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, HIGH); digitalWrite(motorPin14, HIGH);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, HIGH);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 4; delayMicroseconds(900); lastTime = micros(); pasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 4 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, HIGH); digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, HIGH);\n' +
    '      digitalWrite(motorPin23, HIGH); digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 5; delayMicroseconds(900); lastTime = micros(); pasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 5 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, HIGH);\n' +
    '      digitalWrite(motorPin13, HIGH); digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, HIGH); digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 6; delayMicroseconds(900); lastTime = micros(); pasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 6 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, HIGH);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, HIGH); digitalWrite(motorPin24, HIGH);\n' +
    '      stepMotor = 7; delayMicroseconds(900); lastTime = micros(); pasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 7 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, HIGH); digitalWrite(motorPin12, HIGH);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, HIGH);\n' +
    '      stepMotor = 8; delayMicroseconds(900); lastTime = micros(); pasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 8 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, HIGH); digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, HIGH); digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, HIGH);\n' +
    '      stepMotor = 1; delayMicroseconds(900); lastTime = micros(); pasos--; delay(1);\n' +
    '    }\n' +
    '  }\n' +
    '  cm = distancia(1, 3);\n' +
    '  cm = distancia(1, 3);\n' +
    '}';
}

function inyectarIzquierda() {
  inyectarBase();
  inyectarDistancia();
  arduinoGenerator.definitions_['func_izquierda'] =
    'void izquierda(int numPasos) {\n' +
    codigoInicioMovimiento() +
    '  direccion = 3;\n' +
    '  while (numPasos > 0) {\n' +
    '    if (stepMotor == 1 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, HIGH); digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, HIGH); digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 2; delayMicroseconds(900); lastTime = micros(); numPasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 2 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, HIGH); digitalWrite(motorPin12, HIGH);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, HIGH); digitalWrite(motorPin22, HIGH);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 3; delayMicroseconds(900); lastTime = micros(); numPasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 3 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, HIGH);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, HIGH);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 4; delayMicroseconds(900); lastTime = micros(); numPasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 4 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, HIGH);\n' +
    '      digitalWrite(motorPin13, HIGH); digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, HIGH);\n' +
    '      digitalWrite(motorPin23, HIGH); digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 5; delayMicroseconds(900); lastTime = micros(); numPasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 5 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, HIGH); digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, HIGH); digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 6; delayMicroseconds(900); lastTime = micros(); numPasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 6 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, HIGH); digitalWrite(motorPin14, HIGH);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, HIGH); digitalWrite(motorPin24, HIGH);\n' +
    '      stepMotor = 7; delayMicroseconds(900); lastTime = micros(); numPasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 7 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, HIGH);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, HIGH);\n' +
    '      stepMotor = 8; delayMicroseconds(900); lastTime = micros(); numPasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 8 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, HIGH); digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, HIGH);\n' +
    '      digitalWrite(motorPin21, HIGH); digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, HIGH);\n' +
    '      stepMotor = 1; delayMicroseconds(900); lastTime = micros(); numPasos--; delay(1);\n' +
    '    }\n' +
    '  }\n' +
    '  cm = distancia(1, 3);\n' +
    '  cm = distancia(1, 3);\n' +
    '}';
}

function inyectarDerecha() {
  inyectarBase();
  inyectarDistancia();
  arduinoGenerator.definitions_['func_derecha'] =
    'void derecha(int numPasos) {\n' +
    codigoInicioMovimiento() +
    '  direccion = 4;\n' +
    '  while (numPasos > 0) {\n' +
    '    if (stepMotor == 1 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, HIGH); digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, HIGH);\n' +
    '      digitalWrite(motorPin21, HIGH); digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, HIGH);\n' +
    '      stepMotor = 2; delayMicroseconds(900); lastTime = micros(); numPasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 2 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, HIGH);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, HIGH);\n' +
    '      stepMotor = 3; delayMicroseconds(900); lastTime = micros(); numPasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 3 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, HIGH); digitalWrite(motorPin14, HIGH);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, HIGH); digitalWrite(motorPin24, HIGH);\n' +
    '      stepMotor = 4; delayMicroseconds(900); lastTime = micros(); numPasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 4 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, HIGH); digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, HIGH); digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 5; delayMicroseconds(900); lastTime = micros(); numPasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 5 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, HIGH);\n' +
    '      digitalWrite(motorPin13, HIGH); digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, HIGH);\n' +
    '      digitalWrite(motorPin23, HIGH); digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 6; delayMicroseconds(900); lastTime = micros(); numPasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 6 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, LOW);  digitalWrite(motorPin12, HIGH);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, LOW);  digitalWrite(motorPin22, HIGH);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 7; delayMicroseconds(900); lastTime = micros(); numPasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 7 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, HIGH); digitalWrite(motorPin12, HIGH);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, HIGH); digitalWrite(motorPin22, HIGH);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 8; delayMicroseconds(900); lastTime = micros(); numPasos--;\n' +
    '    }\n' +
    '    if (stepMotor == 8 && micros() - lastTime > velocidad) {\n' +
    '      digitalWrite(motorPin11, HIGH); digitalWrite(motorPin12, LOW);\n' +
    '      digitalWrite(motorPin13, LOW);  digitalWrite(motorPin14, LOW);\n' +
    '      digitalWrite(motorPin21, HIGH); digitalWrite(motorPin22, LOW);\n' +
    '      digitalWrite(motorPin23, LOW);  digitalWrite(motorPin24, LOW);\n' +
    '      stepMotor = 1; delayMicroseconds(900); lastTime = micros(); numPasos--; delay(1);\n' +
    '    }\n' +
    '  }\n' +
    '  cm = distancia(1, 3);\n' +
    '  cm = distancia(1, 3);\n' +
    '}';
}

// ─── GENERADORES DE BLOQUES ───

// Bloque mover_motores (adelante, atrás, izquierda, derecha, parar)
arduinoGenerator.forBlock['mover_motores'] = function (block) {
  const direccion = block.getFieldValue('DIRECCION');

  const movimientos = {
    FORWARD: () => { inyectarAdelante(); return 'adelante(2);\n'; },
    BACKWARD: () => { inyectarAtras(); return 'atras(2);\n'; },
    LEFT: () => { inyectarIzquierda(); return 'izquierda(2000);\n'; },
    RIGHT: () => { inyectarDerecha(); return 'derecha(2000);\n'; },
    STOP: () => {
      inyectarBase();
      return (
        'digitalWrite(motorPin11, LOW); digitalWrite(motorPin12, LOW);\n' +
        'digitalWrite(motorPin13, LOW); digitalWrite(motorPin14, LOW);\n' +
        'digitalWrite(motorPin21, LOW); digitalWrite(motorPin22, LOW);\n' +
        'digitalWrite(motorPin23, LOW); digitalWrite(motorPin24, LOW);\n'
      );
    },
  };

  return movimientos[direccion]();
};

arduinoGenerator.forBlock['mover_motor_grados'] = function (block) {
  const angulo = block.getFieldValue('ANGULO');

  arduinoGenerator.definitions_['include_servo'] = '#include <Servo.h>';
  arduinoGenerator.definitions_['servo_obj'] = 'Servo servoMotor;';
  arduinoGenerator.setups_['servo_attach'] = '  servoMotor.attach(16);'; // Pin D0 = GPIO16

  return `servoMotor.write(${angulo});\ndelay(500);\n`;
};

// Bloque leer_distancia (devuelve la distancia en cm)
arduinoGenerator.forBlock['leer_distancia'] = function (block) {
  inyectarDistancia();
  return ['distancia(1, 3)', arduinoGenerator.ORDER_ATOMIC];
};

// Bloque detectar_obstaculo (devuelve true si hay obstáculo cerca)
arduinoGenerator.forBlock['detectar_obstaculo'] = function (block) {
  inyectarDistancia();
  return ['(distancia(1, 3) < 10)', arduinoGenerator.ORDER_ATOMIC];
};

arduinoGenerator.forBlock['cambiar_velocidad'] = function (block) {
  const vel = block.getFieldValue('VELOCIDAD');
  inyectarBase();
  return `velocidad = ${vel};\n`;
};

arduinoGenerator.forBlock['esperar_segundos'] = function (block) {
  const segundos = block.getFieldValue('SEGUNDOS');
  return `delay(${segundos * 1000});\n`;
};
