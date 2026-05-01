import { arduinoGenerator } from './arduino_generator.js';

arduinoGenerator.forBlock['mover_motores'] = function(block) {
  const direccion = block.getFieldValue('DIRECCION');

  // Includes y objetos globales (solo se añaden una vez)
  arduinoGenerator.definitions_['include_accelstepper'] = '#include <AccelStepper.h>';
  arduinoGenerator.definitions_['motor_izq'] =
    'AccelStepper motorIzq(AccelStepper::HALF4WIRE, 8, 10, 9, 11);';
  arduinoGenerator.definitions_['motor_der'] =
    'AccelStepper motorDer(AccelStepper::HALF4WIRE, 4, 6, 5, 7);';

  // Setup
  arduinoGenerator.setups_['motor_izq_speed'] = 'motorIzq.setMaxSpeed(500);';
  arduinoGenerator.setups_['motor_der_speed'] = 'motorDer.setMaxSpeed(500);';

  // Mapeo de dirección a código C++
  const movimientos = {
    FORWARD:  'motorIzq.move(100); motorDer.move(100);',
    BACKWARD: 'motorIzq.move(-100); motorDer.move(-100);',
    LEFT:     'motorIzq.move(-100); motorDer.move(100);',
    RIGHT:    'motorIzq.move(100); motorDer.move(-100);',
    STOP:     'motorIzq.stop(); motorDer.stop();',
  };

  const code = `${movimientos[direccion]}
  motorIzq.runToPosition();
  motorDer.runToPosition();\n`;

  return code;
};

arduinoGenerator.forBlock['mover_motor_grados'] = function(block) {
  const angulo = block.getFieldValue('ANGULO');

  // include y variable global
  arduinoGenerator.definitions_['include_servo'] = '#include <Servo.h>';
  arduinoGenerator.definitions_['servo_instance'] = 'Servo miServo;';

  arduinoGenerator.setups_['servo_attach'] = 'miServo.attach(9);';

  const code = `miServo.write(${angulo});\n`;
  return code;
};

arduinoGenerator.forBlock['cambiar_velocidad'] = function(block) {
  const porcentaje = block.getFieldValue('VELOCIDAD');

  arduinoGenerator.definitions_['include_accelstepper'] = '#include <AccelStepper.h>';
  arduinoGenerator.definitions_['motor_izq'] =
    'AccelStepper motorIzq(AccelStepper::HALF4WIRE, 8, 10, 9, 11);';
  arduinoGenerator.definitions_['motor_der'] =
    'AccelStepper motorDer(AccelStepper::HALF4WIRE, 4, 6, 5, 7);';

  arduinoGenerator.setups_['motor_izq_speed'] = 'motorIzq.setMaxSpeed(500);';
  arduinoGenerator.setups_['motor_der_speed'] = 'motorDer.setMaxSpeed(500);';

  // El 28BYJ-48 trabaja bien entre 0 y 500 pasos/segundo
  // hacemos la conversión del porcentaje a ese rango
  const velocidad = Math.round((porcentaje / 100) * 500);

  return `motorIzq.setMaxSpeed(${velocidad});\nmotorDer.setMaxSpeed(${velocidad});\n`;
};