import { arduinoGenerator } from './arduino_generator.js';

// configuracion hardware
import BASE_DEFINITIONS from '../../../firmware/base_definitions.ino?raw';
import BASE_SETUP from '../../../firmware/base_setup.ino?raw';
import FUNC_DISTANCIA from '../../../firmware/func_distancia.ino?raw';
import FUNC_ADELANTE from '../../../firmware/func_adelante.ino?raw';
import FUNC_ATRAS from '../../../firmware/func_atras.ino?raw';
import FUNC_IZQUIERDA from '../../../firmware/func_izquierda.ino?raw';
import FUNC_DERECHA from '../../../firmware/func_derecha.ino?raw';

// ─── Funciones de inyección ───
function inyectarBase() {
  arduinoGenerator.definitions_['base_config'] = BASE_DEFINITIONS;
  arduinoGenerator.setups_['motor_pins_init'] = BASE_SETUP;
}

function inyectarDistancia() {
  arduinoGenerator.definitions_['func_distancia'] = FUNC_DISTANCIA;
}

function inyectarAdelante() {
  inyectarBase();
  inyectarDistancia();
  arduinoGenerator.definitions_['func_adelante'] = FUNC_ADELANTE;
}

function inyectarAtras() {
  inyectarBase();
  inyectarDistancia();
  arduinoGenerator.definitions_['func_atras'] = FUNC_ATRAS;
}

function inyectarIzquierda() {
  inyectarBase();
  inyectarDistancia();
  arduinoGenerator.definitions_['func_izquierda'] = FUNC_IZQUIERDA;
}

function inyectarDerecha() {
  inyectarBase();
  inyectarDistancia();
  arduinoGenerator.definitions_['func_derecha'] = FUNC_DERECHA;
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
