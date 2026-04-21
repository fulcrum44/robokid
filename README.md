# ROBOKID

## Sistema de Control de Robótica para Niños

Aplicación Android que permite programar robots mediante un editor visual de bloques. El usuario compone programas arrastrando bloques en una interfaz basada en **Blockly**, que genera código **C++** compatible con Arduino. El código se envía a un servidor de compilación que ejecuta **Arduino CLI** y devuelve el binario necesario para la placa Arduino de nuestro robot. La app carga el firmware en la placa conectada de forma inalámbrica mediante **OTA (Over The Air)**, además de estar preparada para cargar en Arduino D1 WiFi (ESP8266) que es la placa usada para el desarrollo, siendo de un proveedor externo de Arduino.

---

## Tecnologías utilizadas

| Tecnología | Ámbito |
|---|---|
| Flutter (Dart) | UI principal Android |
| Blockly (JavaScript) | Editor visual de bloques |
| Vite + npm | Build del workspace Blockly |
| webview_flutter | Integración JS ↔ Flutter |
| Arduino CLI | Compilación de código C++ en el servidor |
| Node.js + Express | Servidor de compilación |
| Docker | Contenedor del servidor de compilación |
| Firebase Auth | Autenticación de usuarios |
| Cloud Firestore | Base de datos (usuarios y proyectos) |

---

## Requisitos previos

### Para el workspace de Blockly
- Node.js 20 o superior
- npm

### Para el servidor de compilación
- Node.js 20 o superior
- npm
- Docker

### Para la app Flutter
- Flutter SDK
- Android Studio
- Dispositivo o emulador Android

---

## Puesta en marcha

### 1. Workspace de Blockly

```bash
cd blockly
npm install
npm run dev
```

El editor estará disponible en `http://localhost:5173`.

Para generar el build que usará Flutter:

```bash
npm run build
```

El resultado se genera en `blockly/dist/`. Se copiará a `app/assets/blockly/`.

### 2. Servidor de compilación

```bash
cd compilador_robokid
docker build -t compilador_robokid .
docker run -p 3000:3000 compilador_robokid
```

El servidor estará disponible en `http://localhost:3000`.

### 3. App Flutter

```bash
cd app
flutter pub get
flutter run
```

---

## Flujo de compilación y carga

1. El usuario compone un programa con bloques en Blockly
2. Blockly genera el código C++ correspondiente
3. Flutter recibe el código a través del JavaScriptChannel
4. Se inyecta automáticamente la plantilla OTA base al código
5. Flutter envía el código al servidor mediante una petición `POST /compile`
6. El servidor ejecuta Arduino CLI y devuelve el binario `.bin`
7. El dispositivo se conecta al punto de acceso WiFi de la placa
8. El binario se envía a la placa mediante HTTP POST al servidor OTA embebido

---

## Usuarios del sistema

- **Invitado** — puede usar el editor de bloques y compilar, pero no guardar proyectos en la nube
- **Registrado** — acceso completo, puede guardar y cargar proyectos desde Cloud Firestore
- **Robot (Arduino D1 WiFi)** — recibe el firmware por OTA y ejecuta el programa
