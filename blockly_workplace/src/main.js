import * as Blockly from 'blockly';
import { moverRobot } from './blocks/movimiento.js';
import { cambiarVelocidad } from './blocks/velocidad.js';
import { leerDistancia, detectarObstaculo } from './blocks/sensor.js';
import { moverMotorGrados } from './blocks/motor_grados.js';
import { esperarSegundos } from './blocks/tiempo.js';


Blockly.common.defineBlocksWithJsonArray([
  moverRobot, 
  cambiarVelocidad,
  leerDistancia, 
  detectarObstaculo,
  moverMotorGrados,
  esperarSegundos
]);

const workspace = Blockly.inject('blocklyDiv', {
  toolbox: {
    kind: 'flyoutToolbox',
    contents: [
      { kind: 'block', type: 'controls_if' },
      { kind: 'block', type: 'controls_repeat_ext' },
      { kind: 'block', type: 'math_number' },
      { kind: 'block', type: 'text_print' },
      { kind: 'block', type: 'mover_motores' },
      { kind: 'block', type: 'cambiar_velocidad' },
      { kind: 'block', type: 'mover_motor_grados' },
      { kind: 'block', type: 'esperar_segundos' },
      { kind: 'block', type: 'leer_distancia' },
      { kind: 'block', type: 'detectar_obstaculo' }
    ]
  }
});

export default workspace;