import { arduinoGenerator } from './arduino_generator.js';

arduinoGenerator.forBlock['leer_distancia'] = function() {

  // añadimos los include de la librería del sensor
  arduinoGenerator.definitions_['include_newping'] = '#include <NewPing.h>';
  arduinoGenerator.definitions_['sonar_pins'] =
    '#define TRIGGER_PIN 12\n#define ECHO_PIN 11\n#define MAX_DISTANCE 200';
  arduinoGenerator.definitions_['sonar_instance'] =
    'NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);';

  return ['sonar.ping_cm()', arduinoGenerator.ORDER_ATOMIC];
};

arduinoGenerator.forBlock['detectar_obstaculo'] = function(block) {
  const distancia = block.getFieldValue('DISTANCIA');

  arduinoGenerator.definitions_['include_newping'] = '#include <NewPing.h>';
  arduinoGenerator.definitions_['sonar_pins'] =
    '#define TRIGGER_PIN 12\n#define ECHO_PIN 11\n#define MAX_DISTANCE 200';
  arduinoGenerator.definitions_['sonar_instance'] =
    'NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);';

  return [`sonar.ping_cm() < ${distancia}`, arduinoGenerator.ORDER_ATOMIC];
};