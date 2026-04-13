export const cambiarVelocidad = {
  "type": "cambiar_velocidad",
  "message0": "Poner velocidad del robot al %1 %",
  "args0": [
    {
      "type": "field_number",
      "name": "VELOCIDAD",
      "value": 50,
      "min": 0,
      "max": 100
    }
  ],
  "previousStatement": null,
  "nextStatement": null,
  "colour": 20, 
  "tooltip": "Ajusta lo rápido que se mueve el robot (de 0 a 100)"
};