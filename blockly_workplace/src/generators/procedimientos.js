import { arduinoGenerator } from './arduino_generator.js';

function nombreSeguro(nombre) {
  return nombre
    .replace(/[^a-zA-Z0-9_]/g, '_')
    .replace(/^[0-9]/, '_$&');
}

arduinoGenerator.forBlock['procedures_defnoreturn'] = function(block, generator) {
  const nombre = nombreSeguro(block.getFieldValue('NAME'));
  const cuerpo = generator.statementToCode(block, 'STACK');

  arduinoGenerator.definitions_['proc_' + nombre] =
    'void ' + nombre + '() {\n' + cuerpo + '}';

  return '';
};

arduinoGenerator.forBlock['procedures_defreturn'] = function(block, generator) {
  const nombre = nombreSeguro(block.getFieldValue('NAME'));
  const cuerpo = generator.statementToCode(block, 'STACK');
  const retorno = generator.valueToCode(block, 'RETURN', generator.ORDER_NONE) || '0';

  arduinoGenerator.definitions_['proc_' + nombre] =
    'int ' + nombre + '() {\n' + cuerpo + '  return ' + retorno + ';\n}';

  return '';
};

arduinoGenerator.forBlock['procedures_callnoreturn'] = function(block) {
  const nombre = nombreSeguro(block.getFieldValue('NAME'));
  return nombre + '();\n';
};

arduinoGenerator.forBlock['procedures_callreturn'] = function(block) {
  const nombre = nombreSeguro(block.getFieldValue('NAME'));
  return [nombre + '()', arduinoGenerator.ORDER_ATOMIC];
};

arduinoGenerator.forBlock['procedures_ifreturn'] = function(block, generator) {
  const condicion = generator.valueToCode(block, 'CONDITION', generator.ORDER_NONE) || 'false';
  const valor = generator.valueToCode(block, 'VALUE', generator.ORDER_NONE) || '0';
  return 'if (' + condicion + ') {\n  return ' + valor + ';\n}\n';
};
