import * as Blockly from 'blockly';
import { moverRobot } from './blocks/movimiento.js';

Blockly.common.defineBlocksWithJsonArray([moverRobot]);

const workspace = Blockly.inject('blocklyDiv', {
  toolbox: {
    kind: 'flyoutToolbox',
    contents: [
      { kind: 'block', type: 'controls_if' },
      { kind: 'block', type: 'controls_repeat_ext' },
      { kind: 'block', type: 'math_number' },
      { kind: 'block', type: 'text_print' },
      { kind: 'block', type: 'mover_motores' }
    ]
  }
});

export default workspace;