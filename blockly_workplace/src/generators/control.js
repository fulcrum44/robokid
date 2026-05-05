import { arduinoGenerator } from './arduino_generator.js';

arduinoGenerator.forBlock['controls_if'] = function(block, generator) {
  let code = '';
  let n = 0;
  while (block.getInput('IF' + n)) {
    const condition = generator.valueToCode(block, 'IF' + n, generator.ORDER_NONE) || 'false';
    const branch = generator.statementToCode(block, 'DO' + n);
    code += (n > 0 ? ' else ' : '') + 'if (' + condition + ') {\n' + branch + '}';
    n++;
  }
  if (block.getInput('ELSE')) {
    const branch = generator.statementToCode(block, 'ELSE');
    code += ' else {\n' + branch + '}';
  }
  return code + '\n';
};

arduinoGenerator.forBlock['controls_ifelse'] = arduinoGenerator.forBlock['controls_if'];

arduinoGenerator.forBlock['controls_repeat_ext'] = function(block, generator) {
  const repeats = generator.valueToCode(block, 'TIMES', generator.ORDER_NONE) || '0';
  const branch = generator.statementToCode(block, 'DO');
  return 'for (int i = 0; i < ' + repeats + '; i++) {\n' + branch + '}\n';
};

arduinoGenerator.forBlock['controls_whileUntil'] = function(block, generator) {
  const mode = block.getFieldValue('MODE');
  const condition = generator.valueToCode(block, 'BOOL', generator.ORDER_NONE) || 'false';
  const branch = generator.statementToCode(block, 'DO');
  if (mode === 'UNTIL') {
    return 'while (!(' + condition + ')) {\n' + branch + '}\n';
  }
  return 'while (' + condition + ') {\n' + branch + '}\n';
};