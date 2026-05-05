import * as Blockly from 'blockly';
import { arduinoGenerator } from './generators/arduino_generator.js';

import { moverRobot } from './blocks/movimiento.js';
import { cambiarVelocidad } from './blocks/velocidad.js';
import { leerDistancia, detectarObstaculo } from './blocks/sensor.js';
import { moverMotorGrados } from './blocks/motor_grados.js';
import { esperarSegundos } from './blocks/tiempo.js';

import './generators/matematicas.js'
import './generators/control.js'
import './generators/robot.js'

Blockly.common.defineBlocksWithJsonArray([
  moverRobot, 
  cambiarVelocidad,
  leerDistancia, 
  detectarObstaculo,
  moverMotorGrados,
  esperarSegundos
]);

const temaClaro = Blockly.Theme.defineTheme('claro', {
  name: 'claro',
  base: Blockly.Themes.Classic,

  // Aspecto toolbox
  componentStyles: {
    toolboxBackgroundColour: '#2D2D2D',     // fondo oscuro del panel
    toolboxForegroundColour: '#FFFFFF',     // texto de categorías
    flyoutBackgroundColour: '#3D3D3D',      // fondo del desplegable
    flyoutForegroundColour: '#FFFFFF',      // texto dentro del desplegable
    flyoutOpacity: 0.95,
    scrollbarColour: '#555555',
    insertionMarkerColour: '#FFFFFF',
    insertionMarkerOpacity: 0.3,
  },

  // Fuente visualmente más atrayente para niños
  fontStyle: {
    family: 'Fredoka One, cursive',
    size: 13,
  },
});

const workspace = Blockly.inject('blocklyDiv', {
  toolbox: {
    kind: 'categoryToolbox',
    contents: [
      {
        kind: 'category',
        name: '🚗 Movimiento',
        colour: '#FF6B35',
        contents: [
          { kind: 'block', type: 'mover_motores' },
          { kind: 'block', type: 'cambiar_velocidad' },
        ]
      },
      {
        kind: 'category',
        name: '⚙️ Servo',
        colour: '#9B59B6',
        contents: [
          { kind: 'block', type: 'mover_motor_grados' },
        ]
      },
      {
        kind: 'category',
        name: '👁️ Sensores',
        colour: '#00BCD4',
        contents: [
          { kind: 'block', type: 'leer_distancia' },
          { kind: 'block', type: 'detectar_obstaculo' },
        ]
      },
      {
        kind: 'category',
        name: '⏱️ Tiempo',
        colour: '#FF4081',
        contents: [
          { kind: 'block', type: 'esperar_segundos' },
        ]
      },
      {
        kind: 'category',
        name: '🔁 Control',
        colour: '#4CAF50',
        contents: [
          { kind: 'block', type: 'controls_if' },
          { kind: 'block', type: 'controls_repeat_ext' },
        ]
      },
      {
        kind: 'category',
        name: '🔢 Matemáticas',
        colour: '#FFC107',
        contents: [
          { kind: 'block', type: 'math_number' },
        ]
      },
    ]
  },
  theme: temaClaro,
  scrollbars: true,
  trashcan: true,
  zoom: {
    controls: true,
    wheel: true,
    startScale: 1.0,
    maxScale: 2,
    minScale: 0.5,
  },
  grid: {
    spacing: 24,
    length: 4,
    colour: '#444',
    snap: true,
  },
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