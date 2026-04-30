import { arduinoGenerator } from './arduino_generator.js';

arduinoGenerator.forBlock['esperar_segundos'] = function(block) {
  const segundos = block.getFieldValue('SEGUNDOS');

  // convertimos a milisegundos porque nativamente el delay() de arduino trabaja con milisegundos
  const ms = Math.round(segundos * 1000);
  return `delay(${ms});\n`;
};