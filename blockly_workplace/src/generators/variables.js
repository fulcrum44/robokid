import { arduinoGenerator } from './arduino_generator.js';

function nombreSeguro(nombre) {
  return nombre
    .replace(/[^a-zA-Z0-9_]/g, '_')
    .replace(/^[0-9]/, '_$&');
}

arduinoGenerator.forBlock['variables_get'] = function(block) {
  const nombre = block.getField('VAR').getText();
  return [nombreSeguro(nombre), arduinoGenerator.ORDER_ATOMIC];
};

arduinoGenerator.forBlock['variables_set'] = function(block, generator) {
  const nombre = block.getField('VAR').getText();
  const valor = generator.valueToCode(block, 'VALUE', generator.ORDER_NONE) || '0';
  const varSegura = nombreSeguro(nombre);

  arduinoGenerator.definitions_['var_' + varSegura] = 'int ' + varSegura + ' = 0;';

  return varSegura + ' = ' + valor + ';\n';
};
