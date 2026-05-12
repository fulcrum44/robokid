import * as Blockly from 'blockly';

export const temaClaro = Blockly.Theme.defineTheme('robokid-light', {
  base: Blockly.Themes.Classic,
  fontStyle: { family: 'Outfit', weight: '500', size: 12 },
  componentStyles: {
    workspaceBackgroundColour: '#f5f5f8',
    toolboxBackgroundColour: '#3f3e3e',
    toolboxForegroundColour: '#ffffff',
    flyoutBackgroundColour: '#16213e',
    flyoutForegroundColour: '#ffffff',
    flyoutOpacity: 0.95,
    scrollbarColour: 'rgb(85, 84, 84)',
  },
});

export const temaOscuro = Blockly.Theme.defineTheme('robokid-dark', {
  base: Blockly.Themes.Classic,
  fontStyle: { family: 'Outfit', weight: '500', size: 12 },
  componentStyles: {
    workspaceBackgroundColour: '#242424',
    toolboxBackgroundColour: '#3f3e3e',
    toolboxForegroundColour: '#ffffff',
    flyoutBackgroundColour: '#151528',
    flyoutForegroundColour: '#ffffff',
    flyoutOpacity: 0.95,
    scrollbarColour: 'rgba(238, 237, 237, 0.81)',
  },
});