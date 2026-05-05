import { arduinoGenerator } from './arduino_generator.js';

arduinoGenerator.forBlock['math_number'] = function(block) {
  const num = Number(block.getFieldValue('NUM'));
  return [String(num), arduinoGenerator.ORDER_ATOMIC];
};

arduinoGenerator.forBlock['math_arithmetic'] = function(block, generator) {
  const ops = {
    ADD: [' + ', generator.ORDER_ATOMIC],
    MINUS: [' - ', generator.ORDER_ATOMIC],
    MULTIPLY: [' * ', generator.ORDER_ATOMIC],
    DIVIDE: [' / ', generator.ORDER_ATOMIC],
    POWER: [null, generator.ORDER_ATOMIC],
  };
  const tuple = ops[block.getFieldValue('OP')];
  const a = generator.valueToCode(block, 'A', tuple[1]) || '0';
  const b = generator.valueToCode(block, 'B', tuple[1]) || '0';
  if (block.getFieldValue('OP') === 'POWER') {
    return ['pow(' + a + ', ' + b + ')', generator.ORDER_ATOMIC];
  }
  return [a + tuple[0] + b, tuple[1]];
};