import * as Blockly from 'blockly';
import { arduinoGenerator } from './generators/arduino_generator.js';

import { moverRobot } from './blocks/movimiento.js';
import { cambiarVelocidad } from './blocks/velocidad.js';
import { leerDistancia, detectarObstaculo } from './blocks/sensor.js';
// import { moverMotorGrados } from './blocks/motor_grados.js';
import { esperarSegundos } from './blocks/tiempo.js';

import './generators/matematicas.js'
import './generators/control.js'
import './generators/robot.js'

import { temaClaro, temaOscuro } from './toolbox/themeModes.js';

Blockly.common.defineBlocksWithJsonArray([
  moverRobot, 
  cambiarVelocidad,
  leerDistancia, 
  detectarObstaculo,
  // moverMotorGrados,
  esperarSegundos
]);

const workspace = Blockly.inject('blocklyDiv', {
  toolbox: {
    kind: 'categoryToolbox',
    contents: [
      {
        kind: 'category', name: 'Movimiento', colour: '#FF6B35',
        contents: [
          { kind: 'block', type: 'mover_motores' },
          { kind: 'block', type: 'cambiar_velocidad' },
          // { kind: 'block', type: 'mover_motor_grados' },
        ]
      },
      {
        kind: 'category', name: 'Sensor', colour: '#00BCD4',
        contents: [
          { kind: 'block', type: 'leer_distancia' },
          { kind: 'block', type: 'detectar_obstaculo' },
        ]
      },
      {
        kind: 'category', name: 'Tiempo', colour: '#FF4081',
        contents: [
          { kind: 'block', type: 'esperar_segundos' },
        ]
      },
      {
        kind: 'category', name: 'Control', colour: '#4CAF50',
        contents: [
          { kind: 'block', type: 'controls_if' },
          { kind: 'block', type: 'controls_repeat_ext' },
        ]
      },
      {
        kind: 'category', name: 'Matemáticas', colour: '#FFC107',
        contents: [
          { kind: 'block', type: 'math_number' },
          { kind: 'block', type: 'math_arithmetic' },
        ]
      },
    ]
  },

  theme: temaClaro,
  horizontalLayout: true,
  toolboxPosition: 'start',
  trashcan: true,
  zoom: {
    controls: true, wheel: true,
    startScale: 0.7, maxScale: 1.5, minScale: 0.3, scaleSpeed: 1.1,
  },
  grid: { spacing: 25, length: 3, colour: '#777777', snap: true },
  move: { scrollbars: true, drag: true, wheel: true },
  renderer: 'zelos',
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


// funcion para cambiar el tema del workspace según ajustes de la app
window.setBlocklyTheme = function(mode) {
  if (mode === 'dark') {
    document.body.classList.add('dark-theme');
    workspace.setTheme(temaOscuro);
  } else {
    document.body.classList.remove('dark-theme');
    workspace.setTheme(temaClaro);
  }

  const gridPattern = workspace.getParentSvg().querySelector('.blocklyGridPattern');
  if (gridPattern) {
    const lines = gridPattern.querySelectorAll('line');
    const color = mode === 'dark' ? '#f1f1f1' : '#777777';
    lines.forEach(line => line.setAttribute('stroke', color));
  }
};