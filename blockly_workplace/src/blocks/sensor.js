export const leerDistancia = {
  "type": "leer_distancia",
  "message0": "Distancia del obstáculo (cm)",
  "output": "Number",
  "colour": 760,
  "tooltip": "Mide a cuántos centímetros está el objeto más cercano, como un murciélago"
};

export const detectarObstaculo = {
  "type": "detectar_obstaculo",
  "message0": "¿Hay algo a menos de %1 cm?",
  "args0": [
    {
      "type": "field_number",
      "name": "DISTANCIA",
      "value": 10,
      "min": 0
    }
  ],
  "output": "Boolean",
  "colour": 150,
  "tooltip": "Te avisa si el robot está a punto de chocar con algo"
};