export const moverRobot = {
  "type": "mover_motores",
  "message0": "Mover robot hacia %1",
  "args0": [
    {
      "type": "field_dropdown",
      "name": "DIRECCION",
      "options": [
        ["Adelante", "FORWARD"],
        ["Atrás", "BACKWARD"],
        ["Izquierda", "LEFT"],
        ["Derecha", "RIGHT"],
        ["Detener", "STOP"]
      ]
    }
  ],
  "previousStatement": null,
  "nextStatement": null,
  "colour": 120,
  "tooltip": "Controla los movimiento"
};