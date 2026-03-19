import * as Blockly from 'blockly';

const workspace = Blockly.inject('blocklyDiv', {
  toolbox: {
    kind: 'flyoutToolbox',
    contents: [
      { kind: 'block', type: 'controls_if' },
      { kind: 'block', type: 'controls_repeat_ext' },
      { kind: 'block', type: 'math_number' },
      { kind: 'block', type: 'text_print' },
    ]
  }
});

export default workspace;