# ROBOKID
## Sistema de Control de Robótica para Niños
Aplicación Android que permite programar robots mediante un editor visual de bloques. El usuario compone programas arrastrando bloques en una interfaz basada en **Blockly**, que genera código **C++** compatible con Arduino. El código se envía a un servidor en la nube que lo compila haciendo uso de la herramienta **Arduino CLI** y devuelve el binario compatible con el robot, que la app carga en él por cable o Wifi.

---
 
## Requisitos previos
 
### Para el workspace de Blockly
- Node.js 20 o superior
- npm
 
### Para el servidor de compilación
- Node.js 20 o superior
- npm
- Docker (para desarrollo local)
 
### Para la app Flutter
- Flutter SDK
- Android Studio
- Dispositivo o emulador Android
 
---

## Flujo de compilación
 
1. El usuario compone un programa con bloques en Blockly
2. Blockly genera el código C++ correspondiente
3. Flutter recibe el código a través del JavaScriptChannel
4. Flutter envía el código al servidor mediante una petición `POST /compile`
5. El servidor ejecuta Arduino CLI y devuelve el binario `.hex`
6. Flutter carga el binario en el robot por USB o BLE
 
---
