import * as Blockly from 'blockly';
import { arduinoGenerator } from './generators/arduino_generator.js';

import { moverRobot } from './blocks/movimiento.js';
import { cambiarVelocidad } from './blocks/velocidad.js';
import { leerDistancia, detectarObstaculo } from './blocks/sensor.js';
import { moverMotorGrados } from './blocks/motor_grados.js';
import { esperarSegundos } from './blocks/tiempo.js';

import './generators/sensor_distancia.js';
import './generators/motores.js';
import './generators/tiempo.js';

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
  },
  scrollbars: true,
  trashcan: true,
});

// exponer workspace para acceso desde el webview
window.workspace = workspace;

// funciones puente para comunicacion con Flutter
window.requestCode = function() {
  const code = arduinoGenerator.workspaceToCode(workspace);
  try {
    FlutterChannel.postMessage(JSON.stringify({ type: 'arduinoCode', data: code }));
  } catch (e) {
    console.log('FlutterChannel no disponible:', code);
  }
};

window.requestWorkspaceState = function() {
  const state = Blockly.serialization.workspaces.save(workspace);
  try {
    FlutterChannel.postMessage(JSON.stringify({ type: 'workspaceState', data: JSON.stringify(state) }));
  } catch (e) {
    console.log('FlutterChannel no disponible');
  }
};

window.loadWorkspace = function(jsonString) {
  const state = JSON.parse(jsonString);
  Blockly.serialization.workspaces.load(state, workspace);
};

window.clearWorkspace = function() {
  workspace.clear();
};

// avisar a Flutter que Blockly ya cargo
try {
  FlutterChannel.postMessage(JSON.stringify({ type: 'blocklyReady' }));
} catch (e) {
  console.log('Blockly listo (sin FlutterChannel)');
}