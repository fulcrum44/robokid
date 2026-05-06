import * as Blockly from 'blockly';
import OTA_TEMPLATE from '../../../firmware/ota_bootloader.ino?raw';

export const arduinoGenerator = new Blockly.Generator('Arduino');

arduinoGenerator.ORDER_ATOMIC = 0;
arduinoGenerator.ORDER_NONE = 99;

// instanciamos la variable para almacenar los includes o variables locales usadas
arduinoGenerator.definitions_ = {};

// variable para guardar la configuración de bloques que se haye hecho en el editor de bloques
arduinoGenerator.setups_ = {};

arduinoGenerator.init = function(workspace) {
  arduinoGenerator.definitions_ = {};
  arduinoGenerator.setups_ = {};
  
  Object.getPrototypeOf(arduinoGenerator).init.call(this, workspace);
};

arduinoGenerator.scrub_ = function(block, code, thisOnly) {
  const nextBlock = block.nextConnection && block.nextConnection.targetBlock();
  if (nextBlock && !thisOnly) {
    return code + this.blockToCode(nextBlock);
  }
  return code;
};

// ensamblado de los bloques en un sketch unificado
arduinoGenerator.finish = function(code) {
  const includes = Object.values(this.definitions_).join('\n');
  const setups   = Object.values(this.setups_).join('\n  ');
  return `${OTA_TEMPLATE}
  ${includes}

void setup() {
  configurarOTA();
  esperarOTA();
  ${setups}
}

void loop() {
  ${code}
}
`;
};